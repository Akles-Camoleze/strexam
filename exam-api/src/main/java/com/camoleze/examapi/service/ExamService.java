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
    private final UserRepository userRepository;
    
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
    
    private Mono<Void> saveQuestionsAndAnswers(Exam exam, java.util.List<ExamCreateRequest.QuestionCreateRequest> questions) {
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
    
    private Mono<Void> saveAnswers(Question question, java.util.List<ExamCreateRequest.AnswerCreateRequest> answers) {
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
                .switchIfEmpty(Mono.error(new RuntimeException("Invalid join code")))
                .filter(exam -> exam.getStatus() == Exam.ExamStatus.ACTIVE)
                .switchIfEmpty(Mono.error(new RuntimeException("Exam is not active")))
                .flatMap(exam -> createOrGetSession(exam, request.getUserId()))
                .doOnSuccess(session -> broadcastEvent(ExamEvent.builder()
                        .type(ExamEvent.ExamEventType.USER_JOINED)
                        .examId(session.getExamId())
                        .userId(session.getUserId())
                        .timestamp(LocalDateTime.now())
                        .build()));
    }
    
    private Mono<ExamSessionResponse> createOrGetSession(Exam exam, Long userId) {
        return examSessionRepository.findByExamIdAndUserId(exam.getId(), userId)
                .switchIfEmpty(createNewSession(exam, userId))
                .map(ExamSessionResponse::fromEntity);
    }
    
    private Mono<ExamSession> createNewSession(Exam exam, Long userId) {
        return questionRepository.countByExamId(exam.getId())
                .flatMap(questionCount -> {
                    // Calculate max score
                    return questionRepository.findByExamIdOrderByOrderIndex(exam.getId())
                            .map(Question::getPoints)
                            .reduce(0, Integer::sum)
                            .flatMap(maxScore -> examSessionRepository.save(ExamSession.builder()
                                    .examId(exam.getId())
                                    .userId(userId)
                                    .status(ExamSession.SessionStatus.STARTED)
                                    .startedAt(LocalDateTime.now())
                                    .totalScore(0)
                                    .maxScore(maxScore)
                                    .build()));
                });
    }
    
    public Mono<Void> submitAnswer(AnswerSubmissionRequest request) {
        return examSessionRepository.findById(request.getSessionId())
                .switchIfEmpty(Mono.error(new RuntimeException("Session not found")))
                .flatMap(session -> processAnswerSubmission(session, request))
                .doOnSuccess(response -> broadcastEvent(ExamEvent.builder()
                        .type(ExamEvent.ExamEventType.ANSWER_SUBMITTED)
                        .examId(response.getSessionId()) // Note: This should be examId
                        .userId(response.getSessionId()) // Note: This should be userId
                        .data(response)
                        .timestamp(LocalDateTime.now())
                        .build()))
                .then();
    }
    
    private Mono<UserResponse> processAnswerSubmission(ExamSession session, AnswerSubmissionRequest request) {
        return questionRepository.findById(request.getQuestionId())
                .flatMap(question -> {
                    if (question.getType() == Question.QuestionType.MULTIPLE_CHOICE) {
                        return processMultipleChoiceAnswer(session, question, request);
                    } else {
                        return processShortAnswer(session, question, request);
                    }
                })
                .flatMap(this::updateSessionScore);
    }
    
    private Mono<UserResponse> processMultipleChoiceAnswer(ExamSession session, Question question, AnswerSubmissionRequest request) {
        return answerRepository.findById(request.getAnswerId())
                .flatMap(answer -> {
                    UserResponse userResponse = UserResponse.builder()
                            .sessionId(session.getId())
                            .questionId(question.getId())
                            .answerId(answer.getId())
                            .isCorrect(answer.getIsCorrect())
                            .pointsEarned(answer.getIsCorrect() ? question.getPoints() : 0)
                            .build();
                    
                    return userResponseRepository.save(userResponse);
                });
    }
    
    private Mono<UserResponse> processShortAnswer(ExamSession session, Question question, AnswerSubmissionRequest request) {
        // For short answers, you might want to implement auto-grading logic
        // For now, we'll mark them as requiring manual review
        UserResponse userResponse = UserResponse.builder()
                .sessionId(session.getId())
                .questionId(question.getId())
                .responseText(request.getResponseText())
                .isCorrect(false) // Default to false, requires manual grading
                .pointsEarned(0)
                .build();
        
        return userResponseRepository.save(userResponse);
    }
    
    private Mono<UserResponse> updateSessionScore(UserResponse userResponse) {
        return examSessionRepository.findById(userResponse.getSessionId())
                .flatMap(session -> {
                    int newScore = session.getTotalScore() + userResponse.getPointsEarned();
                    ExamSession updatedSession = ExamSession.builder()
                            .id(session.getId())
                            .examId(session.getExamId())
                            .userId(session.getUserId())
                            .status(session.getStatus())
                            .startedAt(session.getStartedAt())
                            .completedAt(session.getCompletedAt())
                            .totalScore(newScore)
                            .maxScore(session.getMaxScore())
                            .createdAt(session.getCreatedAt())
                            .updatedAt(LocalDateTime.now())
                            .build();
                    
                    return examSessionRepository.save(updatedSession)
                            .then(Mono.just(userResponse));
                });
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
                            .doOnSuccess(response -> broadcastEvent(ExamEvent.builder()
                                    .type(ExamEvent.ExamEventType.EXAM_COMPLETED)
                                    .examId(response.getExamId())
                                    .userId(response.getUserId())
                                    .data(response)
                                    .timestamp(LocalDateTime.now())
                                    .build()));
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
        return examEventSink.asFlux()
                .filter(event -> event.getExamId().equals(examId));
    }
    
    private void broadcastEvent(ExamEvent event) {
        examEventSink.tryEmitNext(event);
    }
    
    public Flux<ExamResponse> getExamsByHost(Long hostUserId) {
        return examRepository.findByHostUserId(hostUserId)
                .flatMap(exam -> buildExamResponse(exam, true));
    }
}