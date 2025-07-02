package com.camoleze.examapi.service;

import com.camoleze.examapi.dto.*;
import com.camoleze.examapi.model.*;
import com.camoleze.examapi.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.core.publisher.Sinks;

import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

@Service
@RequiredArgsConstructor
@Slf4j
public class ExamService {

    private final ExamRepository examRepository;
    private final QuestionRepository questionRepository;
    private final AnswerRepository answerRepository;
    private final ExamSessionRepository examSessionRepository;
    private final UserResponseRepository userResponseRepository;

    private final Sinks.Many<ExamEvent> examEventSink = Sinks.many().multicast().onBackpressureBuffer();

    public Mono<ExamResponse> createExam(ExamCreateRequest request) {
        return examRepository.save(Exam.builder()
                        .title(request.getTitle())
                        .description(request.getDescription())
                        .hostUserId(request.getHostUserId())
                        .status(Exam.ExamStatus.DRAFT)
                        .timeLimit(request.getTimeLimit())
                        .allowRetake(request.getAllowRetake())
                        .build())
                .flatMap(savedExam -> saveQuestionsAndAnswers(savedExam, request.getQuestions())
                        .then(Mono.just(ExamResponse.fromEntity(savedExam))));
    }

    private Mono<Void> saveQuestionsAndAnswers(Exam exam, List<ExamCreateRequest.QuestionCreateRequest> questions) {
        AtomicInteger orderIndex = new AtomicInteger(0);

        return Flux.fromIterable(questions)
                .flatMap(questionReq -> {
                    Question question = Question.builder()
                            .examId(exam.getId())
                            .questionText(questionReq.getQuestionText())
                            .type(Question.QuestionType.valueOf(questionReq.getType()))
                            .orderIndex(orderIndex.getAndIncrement())
                            .points(questionReq.getPoints())
                            .build();

                    return questionRepository.save(question)
                            .flatMap(savedQuestion -> saveAnswers(savedQuestion, questionReq.getAnswers()));
                })
                .then();
    }

    private Mono<Void> saveAnswers(Question question, List<ExamCreateRequest.AnswerCreateRequest> answers) {
        if (answers == null || answers.isEmpty()) {
            return Mono.empty();
        }

        AtomicInteger orderIndex = new AtomicInteger(0);

        return Flux.fromIterable(answers)
                .map(answerReq -> Answer.builder()
                        .questionId(question.getId())
                        .answerText(answerReq.getAnswerText())
                        .isCorrect(answerReq.getIsCorrect())
                        .orderIndex(orderIndex.getAndIncrement())
                        .build())
                .flatMap(answerRepository::save)
                .then();
    }

    public Mono<ExamResponse> getExam(Long examId, Long requestingUserId) {
        return examRepository.findById(examId)
                .flatMap(exam -> {
                    boolean isHost = exam.getHostUserId().equals(requestingUserId);
                    return buildExamResponse(exam, isHost);
                });
    }

    private Mono<ExamResponse> buildExamResponse(Exam exam, boolean includeCorrectAnswers) {
        return questionRepository.findByExamIdOrderByOrderIndex(exam.getId())
                .flatMap(question -> buildQuestionResponse(question, includeCorrectAnswers))
                .collectList()
                .map(questions -> {
                    ExamResponse response = ExamResponse.fromEntity(exam);
                    response.setQuestions(questions);
                    return response;
                });
    }

    private Mono<QuestionResponse> buildQuestionResponse(Question question, boolean includeCorrectAnswers) {
        return answerRepository.findByQuestionIdOrderByOrderIndex(question.getId())
                .map(answer -> AnswerResponse.fromEntity(answer, includeCorrectAnswers))
                .collectList()
                .map(answers -> {
                    QuestionResponse response = QuestionResponse.fromEntity(question);
                    response.setAnswers(answers);
                    return response;
                });
    }

    public Mono<ExamSessionResponse> joinExam(ExamJoinRequest request) {
        return examRepository.findByJoinCode(request.getJoinCode())
                .switchIfEmpty(Mono.error(new RuntimeException("Código de inscrição inválido")))
                .filter(exam -> exam.getStatus() == Exam.ExamStatus.ACTIVE)
                .switchIfEmpty(Mono.error(new RuntimeException("O exame não está ativo")))
                .flatMap(exam -> examSessionRepository.findByExamIdAndUserIdOrderByCreatedAtDesc(exam.getId(), request.getUserId())
                        .next()
                        .flatMap(latestSession -> {
                            if (latestSession.getStatus().allowContinue()) {
                                return Mono.just(latestSession);
                            }

                            if (Boolean.TRUE.equals(exam.getAllowRetake())) {
                                return createNewSession(exam, request.getUserId());
                            } else {
                                return Mono.error(new RuntimeException("Sessão finalizada e retomadas não são permitidas"));
                            }
                        })
                        .switchIfEmpty(
                                createNewSession(exam, request.getUserId())
                        )
                        .map(ExamSessionResponse::fromEntity)
                        .doOnSuccess(session -> broadcastEvent(ExamEvent.builder()
                                .type(ExamEvent.ExamEventType.USER_JOINED)
                                .examId(session.getExamId())
                                .userId(session.getUserId())
                                .timestamp(LocalDateTime.now())
                                .build())
                        )
                );
    }

    private Mono<ExamSession> createNewSession(Exam exam, Long userId) {
        return questionRepository.countByExamId(exam.getId())
                .flatMap(questionCount -> questionRepository.findByExamIdOrderByOrderIndex(exam.getId())
                        .map(Question::getPoints)
                        .reduce(0, Integer::sum)
                        .flatMap(maxScore -> examSessionRepository.save(ExamSession.builder()
                                .examId(exam.getId())
                                .userId(userId)
                                .status(ExamSession.SessionStatus.STARTED)
                                .startedAt(LocalDateTime.now())
                                .totalScore(0)
                                .maxScore(maxScore)
                                .build())));
    }

    public Mono<Void> submitAnswer(AnswerSubmissionRequest request) {
        return examSessionRepository.findById(request.getSessionId())
                .switchIfEmpty(Mono.error(new RuntimeException("Session not found")))
                .flatMap(session -> processAnswerSubmission(session, request)
                        .doOnSuccess(response -> {
                            broadcastEvent(ExamEvent.builder()
                                    .type(ExamEvent.ExamEventType.ANSWER_SUBMITTED)
                                    .examId(session.getExamId())
                                    .userId(session.getUserId())
                                    .data(response)
                                    .timestamp(LocalDateTime.now())
                                    .build());

                            broadcastEvent(ExamEvent.builder()
                                    .type(ExamEvent.ExamEventType.STATISTICS_UPDATED)
                                    .examId(session.getExamId())
                                    .userId(session.getUserId())
                                    .data(null)
                                    .timestamp(LocalDateTime.now())
                                    .build());
                        }))
                .then();
    }

    private Mono<UserResponse> processAnswerSubmission(ExamSession session, AnswerSubmissionRequest request) {
        return questionRepository.findById(request.getQuestionId())
                .flatMap(question -> {
                    if (question.getType().isChoiceAnswer()) {
                        return processChoiceAnswer(session, question, request);
                    } else {
                        return processShortAnswer(session, question, request);
                    }
                });
    }

    private Mono<UserResponse> processChoiceAnswer(ExamSession session, Question question, AnswerSubmissionRequest request) {
        return answerRepository.findById(request.getAnswerId())
                .flatMap(answer -> userResponseRepository.findBySessionIdAndQuestionId(session.getId(), question.getId())
                        .flatMap(existing -> {
                            int oldPoints = existing.getPointsEarned();

                            existing.setAnswerId(answer.getId());
                            existing.setIsCorrect(answer.getIsCorrect());
                            existing.setPointsEarned(answer.getIsCorrect() ? question.getPoints() : 0);

                            int newPoints = existing.getPointsEarned();

                            return userResponseRepository.save(existing)
                                    .flatMap(savedResponse -> updateSessionScore(session, newPoints - oldPoints)
                                            .thenReturn(savedResponse)
                                    );
                        })
                        .switchIfEmpty(Mono.defer(() -> {
                            UserResponse newResponse = UserResponse.builder()
                                    .sessionId(session.getId())
                                    .questionId(question.getId())
                                    .answerId(answer.getId())
                                    .isCorrect(answer.getIsCorrect())
                                    .pointsEarned(answer.getIsCorrect() ? question.getPoints() : 0)
                                    .build();

                            return userResponseRepository.save(newResponse)
                                    .flatMap(savedResponse -> updateSessionScore(session, savedResponse.getPointsEarned()))
                                    .thenReturn(newResponse);
                        }))
                );

    }

    private Mono<UserResponse> processShortAnswer(ExamSession session, Question question, AnswerSubmissionRequest request) {
        return userResponseRepository.findBySessionIdAndQuestionId(session.getId(), question.getId())
                .flatMap(existing -> {
                    existing.setResponseText(request.getResponseText());
                    existing.setIsCorrect(false);
                    existing.setPointsEarned(0);
                    return userResponseRepository.save(existing);
                })
                .switchIfEmpty(
                        Mono.defer(() -> {
                            UserResponse newResponse = UserResponse.builder()
                                    .sessionId(session.getId())
                                    .questionId(question.getId())
                                    .responseText(request.getResponseText())
                                    .isCorrect(false)
                                    .pointsEarned(0)
                                    .build();
                            return userResponseRepository.save(newResponse);
                        })
                );
    }


    private Mono<Void> updateSessionScore(ExamSession session, int pointsDelta) {
        int newScore = session.getTotalScore() + pointsDelta;
        session.setTotalScore(newScore);
        session.setUpdatedAt(LocalDateTime.now());
        return examSessionRepository.save(session).then();
    }

    public Mono<ExamSessionResponse> completeExam(Long sessionId) {
        return examSessionRepository.findById(sessionId)
                .flatMap(session -> {
                    ExamSession completedSession = ExamSession.builder()
                            .id(session.getId())
                            .examId(session.getExamId())
                            .userId(session.getUserId())
                            .status(ExamSession.SessionStatus.COMPLETED)
                            .startedAt(session.getStartedAt())
                            .completedAt(LocalDateTime.now())
                            .totalScore(session.getTotalScore())
                            .maxScore(session.getMaxScore())
                            .createdAt(session.getCreatedAt())
                            .updatedAt(LocalDateTime.now())
                            .build();

                    return examSessionRepository.save(completedSession)
                            .map(ExamSessionResponse::fromEntity)
                            .doOnSuccess(response -> {
                                broadcastEvent(ExamEvent.builder()
                                        .type(ExamEvent.ExamEventType.EXAM_COMPLETED)
                                        .examId(response.getExamId())
                                        .userId(response.getUserId())
                                        .data(response)
                                        .timestamp(LocalDateTime.now())
                                        .build());

                                broadcastEvent(ExamEvent.builder()
                                        .type(ExamEvent.ExamEventType.STATISTICS_UPDATED)
                                        .examId(response.getExamId())
                                        .userId(response.getUserId())
                                        .data(null)
                                        .timestamp(LocalDateTime.now())
                                        .build());
                            });
                });
    }

    public Mono<Exam> activateExam(Long examId) {
        return examRepository.findById(examId)
                .map(exam -> Exam.builder()
                        .id(exam.getId())
                        .title(exam.getTitle())
                        .description(exam.getDescription())
                        .hostUserId(exam.getHostUserId())
                        .joinCode(exam.getJoinCode())
                        .status(Exam.ExamStatus.ACTIVE)
                        .timeLimit(exam.getTimeLimit())
                        .allowRetake(exam.getAllowRetake())
                        .createdAt(exam.getCreatedAt())
                        .updatedAt(LocalDateTime.now())
                        .build())
                .flatMap(examRepository::save);
    }

    public Flux<ExamEvent> getExamEventStream() {
        return examEventSink.asFlux();
    }

    public Flux<ExamEvent> getExamEventStream(Long examId) {
        return examEventSink.asFlux().filter(event -> event.getExamId().equals(examId));
    }

    public void broadcastEvent(ExamEvent event) {
        examEventSink.tryEmitNext(event);
    }

    public Flux<ExamResponse> getExamsByHost(Long hostUserId) {
        return examRepository.findByHostUserId(hostUserId)
                .flatMap(exam -> buildExamResponse(exam, true));
    }

    public Flux<ExamResponse> getExamsByParticipant(Long userId) {
        return examSessionRepository.findByUserId(userId)
                .flatMap(session -> examRepository.findById(session.getExamId()))
                .distinct()
                .flatMap(exam -> buildExamResponse(exam, false));
    }

    public Flux<ExamSessionResponse> getSessionsByExam(Long examId) {
        return examSessionRepository.findByExamId(examId)
                .map(ExamSessionResponse::fromEntity);
    }

    public Flux<ExamSessionResponse> getSessionsByParticipant(Long userId) {
        return examSessionRepository.findByUserId(userId)
                .map(ExamSessionResponse::fromEntity);
    }

    public Flux<UserResponseDTO> getUserResponsesBySession(Long sessionId) {
        return userResponseRepository.findBySessionId(sessionId)
                .flatMap(response -> questionRepository.findById(response.getQuestionId())
                        .flatMap(question -> {
                            if (response.getAnswerId() != null) {
                                return answerRepository.findById(response.getAnswerId())
                                        .map(answer -> UserResponseDTO.builder()
                                                .id(response.getId())
                                                .sessionId(response.getSessionId())
                                                .questionId(response.getQuestionId())
                                                .answerId(response.getAnswerId())
                                                .responseText(response.getResponseText())
                                                .isCorrect(response.getIsCorrect())
                                                .pointsEarned(response.getPointsEarned())
                                                .respondedAt(response.getRespondedAt())
                                                .questionText(question.getQuestionText())
                                                .questionType(question.getType().name())
                                                .questionPoints(question.getPoints())
                                                .answerText(answer.getAnswerText())
                                                .build());
                            } else {
                                return Mono.just(UserResponseDTO.builder()
                                        .id(response.getId())
                                        .sessionId(response.getSessionId())
                                        .questionId(response.getQuestionId())
                                        .answerId(response.getAnswerId())
                                        .responseText(response.getResponseText())
                                        .isCorrect(response.getIsCorrect())
                                        .pointsEarned(response.getPointsEarned())
                                        .respondedAt(response.getRespondedAt())
                                        .questionText(question.getQuestionText())
                                        .questionType(question.getType().name())
                                        .questionPoints(question.getPoints())
                                        .build());
                            }
                        }));
    }

    public Mono<UserResponseDTO> updateShortAnswerCorrection(Long responseId, Boolean isCorrect) {
        return userResponseRepository.findById(responseId)
                .flatMap(response -> {
                    if (response.getResponseText() == null || response.getResponseText().isEmpty()) {
                        return Mono.error(new RuntimeException("This is not a short answer response"));
                    }

                    return questionRepository.findById(response.getQuestionId())
                            .flatMap(question -> {
                                if (question.getType() != Question.QuestionType.SHORT_ANSWER) {
                                    return Mono.error(new RuntimeException("This question is not a short answer type"));
                                }

                                response.setIsCorrect(isCorrect);
                                response.setPointsEarned(isCorrect ? question.getPoints() : 0);

                                return userResponseRepository.save(response)
                                        .flatMap(savedResponse -> examSessionRepository.findById(response.getSessionId())
                                                .flatMap(session -> updateSessionScore(
                                                        session,
                                                        isCorrect ? question.getPoints() : -question.getPoints())
                                                        .then(savedResponse.getAnswerId() != null 
                                                            ? answerRepository.findById(savedResponse.getAnswerId())
                                                                .map(answer -> UserResponseDTO.builder()
                                                                    .id(savedResponse.getId())
                                                                    .sessionId(savedResponse.getSessionId())
                                                                    .questionId(savedResponse.getQuestionId())
                                                                    .answerId(savedResponse.getAnswerId())
                                                                    .responseText(savedResponse.getResponseText())
                                                                    .isCorrect(savedResponse.getIsCorrect())
                                                                    .pointsEarned(savedResponse.getPointsEarned())
                                                                    .respondedAt(savedResponse.getRespondedAt())
                                                                    .questionText(question.getQuestionText())
                                                                    .questionType(question.getType().name())
                                                                    .questionPoints(question.getPoints())
                                                                    .answerText(answer.getAnswerText())
                                                                    .build())
                                                            : Mono.just(UserResponseDTO.builder()
                                                                .id(savedResponse.getId())
                                                                .sessionId(savedResponse.getSessionId())
                                                                .questionId(savedResponse.getQuestionId())
                                                                .answerId(savedResponse.getAnswerId())
                                                                .responseText(savedResponse.getResponseText())
                                                                .isCorrect(savedResponse.getIsCorrect())
                                                                .pointsEarned(savedResponse.getPointsEarned())
                                                                .respondedAt(savedResponse.getRespondedAt())
                                                                .questionText(question.getQuestionText())
                                                                .questionType(question.getType().name())
                                                                .questionPoints(question.getPoints())
                                                                .build()))));
                            });
                });
    }
}
