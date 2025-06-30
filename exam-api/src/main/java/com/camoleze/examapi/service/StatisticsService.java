package com.camoleze.examapi.service;

import com.camoleze.examapi.dto.*;
import com.camoleze.examapi.model.ExamSession;
import com.camoleze.examapi.model.Question;
import com.camoleze.examapi.model.UserResponse;
import com.camoleze.examapi.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.Comparator;

@Service
@RequiredArgsConstructor
@Slf4j
public class StatisticsService {

    private final ExamRepository examRepository;
    private final QuestionRepository questionRepository;
    private final ExamSessionRepository examSessionRepository;
    private final UserResponseRepository userResponseRepository;
    private final UserRepository userRepository;

    public Flux<StatisticsResponse> getStatistics(Long examId) {
        return Mono.zip(
                        getExamStatistics(examId),
                        getQuestionStatistics(examId).collectList(),
                        getUserStatistics(examId).collectList()
                ).map(tuple -> StatisticsResponse.builder()
                        .examStatistics(tuple.getT1())
                        .questionStatistics(tuple.getT2())
                        .userStatistics(tuple.getT3())
                        .build())
                .flux();
    }

    private Mono<ExamStatistics> getExamStatistics(Long examId) {
        return examRepository.findById(examId)
                .flatMap(exam -> {
                    Mono<Long> totalParticipants = examSessionRepository.countParticipantsByExamId(examId);
                    Mono<Long> completedParticipants = examSessionRepository.countCompletedByExamId(examId);
                    Mono<Long> totalQuestions = questionRepository.countByExamId(examId);
                    Mono<Double> averageScore = calculateAverageScore(examId);

                    return Mono.zip(totalParticipants, completedParticipants, totalQuestions, averageScore)
                            .map(tuple -> {
                                long total = tuple.getT1();
                                Long completed = tuple.getT2();
                                Double completionRate = total > 0 ? (completed.doubleValue() / total) * 100 : 0.0;

                                return ExamStatistics.builder()
                                        .examId(examId)
                                        .examTitle(exam.getTitle())
                                        .totalParticipants((int) total)
                                        .completedParticipants(completed.intValue())
                                        .averageScore(tuple.getT4())
                                        .completionRate(completionRate)
                                        .totalQuestions(tuple.getT3().intValue())
                                        .build();
                            });
                });
    }

    private Mono<Double> calculateAverageScore(Long examId) {
        return examSessionRepository.findByExamId(examId)
                .filter(session -> session.getStatus().name().equals("COMPLETED"))
                .filter(session -> session.getMaxScore() != null && session.getMaxScore() > 0)
                .map(session -> (session.getTotalScore().doubleValue() / session.getMaxScore()) * 100)
                .reduce(0.0, Double::sum)
                .zipWith(examSessionRepository.countCompletedByExamId(examId))
                .map(tuple -> {
                    Double sum = tuple.getT1();
                    Long count = tuple.getT2();
                    return count > 0 ? sum / count : 0.0;
                });
    }

    public Flux<QuestionStatistics> getQuestionStatistics(Long examId) {
        return questionRepository.findByExamIdOrderByOrderIndex(examId)
                .flatMap(this::buildQuestionStatistics);
    }

    private Mono<QuestionStatistics> buildQuestionStatistics(Question question) {
        Mono<Long> totalResponses = userResponseRepository.countResponsesByExamIdAndQuestionId(
                question.getExamId(), question.getId());
        Mono<Long> correctResponses = userResponseRepository.countCorrectResponsesByExamIdAndQuestionId(
                question.getExamId(), question.getId());

        return Mono.zip(totalResponses, correctResponses)
                .map(tuple -> {
                    long total = tuple.getT1();
                    Long correct = tuple.getT2();
                    Double correctPercentage = total > 0 ? (correct.doubleValue() / total) * 100 : 0.0;

                    return QuestionStatistics.builder()
                            .questionId(question.getId())
                            .questionText(question.getQuestionText())
                            .totalResponses((int) total)
                            .correctResponses(correct.intValue())
                            .correctPercentage(correctPercentage)
                            .isMostDifficult(false)
                            .isMostCorrect(false)
                            .build();
                });
    }

    private Flux<UserStatistics> getUserStatistics(Long examId) {
        return examSessionRepository.findByExamId(examId).flatMap(this::buildUserStatistics);
    }

    private Mono<UserStatistics> buildUserStatistics(ExamSession session) {
        return userRepository.findById(session.getUserId()).flatMap(user -> {
            Mono<Long> questionsAnswered = userResponseRepository.countResponsesBySessionId(session.getId());
            Mono<Long> correctAnswers = userResponseRepository.findBySessionId(session.getId())
                    .filter(UserResponse::getIsCorrect)
                    .count();

            return Mono.zip(questionsAnswered, correctAnswers)
                    .map(tuple -> {
                        long answered = tuple.getT1();
                        Long correct = tuple.getT2();
                        Double currentPercentage = answered > 0 ? (correct.doubleValue() / answered) * 100 : 0.0;

                        return UserStatistics.builder()
                                .userId(user.getId())
                                .username(user.getUsername())
                                .fullName(user.getFullName())
                                .questionsAnswered((int) answered)
                                .correctAnswers(correct.intValue())
                                .currentPercentage(currentPercentage)
                                .totalScore(session.getTotalScore())
                                .maxScore(session.getMaxScore())
                                .status(session.getStatus().name())
                                .startedAt(session.getStartedAt())
                                .lastActivity(session.getUpdatedAt())
                                .build();
                    });
        });
    }

    public Flux<QuestionStatistics> getMostDifficultQuestions(Long examId, Integer limit) {
        return getQuestionStatistics(examId)
                .filter(stats -> stats.getTotalResponses() > 0)
                .sort(Comparator.comparing(QuestionStatistics::getCorrectPercentage))
                .take(limit != null ? limit : 5)
                .map(stats -> QuestionStatistics.builder()
                        .questionId(stats.getQuestionId())
                        .questionText(stats.getQuestionText())
                        .totalResponses(stats.getTotalResponses())
                        .correctResponses(stats.getCorrectResponses())
                        .correctPercentage(stats.getCorrectPercentage())
                        .isMostDifficult(true)
                        .isMostCorrect(false)
                        .build());
    }

    public Flux<QuestionStatistics> getMostCorrectQuestions(Long examId, Integer limit) {
        return getQuestionStatistics(examId)
                .filter(stats -> stats.getTotalResponses() > 0)
                .sort(Comparator.comparing(QuestionStatistics::getCorrectPercentage).reversed())
                .take(limit != null ? limit : 5)
                .map(stats -> QuestionStatistics.builder()
                        .questionId(stats.getQuestionId())
                        .questionText(stats.getQuestionText())
                        .totalResponses(stats.getTotalResponses())
                        .correctResponses(stats.getCorrectResponses())
                        .correctPercentage(stats.getCorrectPercentage())
                        .isMostDifficult(false)
                        .isMostCorrect(true)
                        .build());
    }

    public Flux<UserStatistics> getTopPerformers(Long examId, Integer limit) {
        return getUserStatistics(examId)
                .filter(stats -> stats.getQuestionsAnswered() > 0)
                .sort(Comparator.comparing(UserStatistics::getTotalScore).reversed()
                        .thenComparing(UserStatistics::getCurrentPercentage).reversed()
                        .thenComparing(UserStatistics::getQuestionsAnswered).reversed())
                .take(limit != null ? limit : 10);
    }

    public Mono<Double> getExamProgress(Long sessionId) {
        return examSessionRepository.findById(sessionId)
                .flatMap(session -> {
                    Mono<Long> totalQuestions = questionRepository.countByExamId(session.getExamId());
                    Mono<Long> answeredQuestions = userResponseRepository.countResponsesBySessionId(sessionId);

                    return Mono.zip(totalQuestions, answeredQuestions)
                            .map(tuple -> {
                                long total = tuple.getT1();
                                Long answered = tuple.getT2();
                                return total > 0 ? (answered.doubleValue() / total) * 100 : 0.0;
                            });
                });
    }
}