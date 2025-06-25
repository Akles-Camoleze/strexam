package com.camoleze.examapi.service;

import com.camoleze.examapi.dto.*;
import com.camoleze.examapi.model.ExamSession;
import com.camoleze.examapi.model.Question;
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
    
    public Mono<StatisticsResponse> getStatistics(Long examId) {
        return Mono.zip(
                getExamStatistics(examId),
                getQuestionStatistics(examId).collectList(),
                getUserStatistics(examId).collectList()
        ).map(tuple -> StatisticsResponse.builder()
                .examStatistics(tuple.getT1())
                .questionStatistics(tuple.getT2())
                .userStatistics(tuple.getT3())
                .build());
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
                                Long total = tuple.getT1();
                                Long completed = tuple.getT2();
                                Double completionRate = total > 0 ? (completed.doubleValue() / total) * 100 : 0.0;
                                
                                return ExamStatistics.builder()
                                        .examId(examId)
                                        .examTitle(exam.getTitle())
                                        .totalParticipants(total.intValue())
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
    
    private Flux<QuestionStatistics> getQuestionStatistics(Long examId) {
        return questionRepository.findByExamIdOrderByOrderIndex(examId)
                .flatMap(this::buildQuestionStatistics)
                .collectList()
                .flatMapMany(questionStats -> {
                    // Mark most difficult and most correct questions
                    if (!questionStats.isEmpty()) {
                        QuestionStatistics mostDifficult = questionStats.stream()
                                .min(Comparator.comparing(QuestionStatistics::getCorrectPercentage))
                                .orElse(null);
                        
                        QuestionStatistics mostCorrect = questionStats.stream()
                                .max(Comparator.comparing(QuestionStatistics::getCorrectPercentage))
                                .orElse(null);
                        
                        if (mostDifficult != null) {
                            mostDifficult.setIsMostDifficult(true);
                        }
                        if (mostCorrect != null) {
                            mostCorrect.setIsMostCorrect(true);
                        }
                    }
                    
                    return Flux.fromIterable(questionStats);
                });
    }
    
    private Mono<QuestionStatistics> buildQuestionStatistics(Question question) {
        Mono<Long> totalResponses = userResponseRepository.countResponsesByExamIdAndQuestionId(
                question.getExamId(), question.getId());
        Mono<Long> correctResponses = userResponseRepository.countCorrectResponsesByExamIdAndQuestionId(
                question.getExamId(), question.getId());
        
        return Mono.zip(totalResponses, correctResponses)
                .map(tuple -> {
                    Long total = tuple.getT1();
                    Long correct = tuple.getT2();
                    Double correctPercentage = total > 0 ? (correct.doubleValue() / total) * 100 : 0.0;
                    
                    return QuestionStatistics.builder()
                            .questionId(question.getId())
                            .questionText(question.getQuestionText())
                            .totalResponses(total.intValue())
                            .correctResponses(correct.intValue())
                            .correctPercentage(correctPercentage)
                            .isMostDifficult(false)
                            .isMostCorrect(false)
                            .build();
                });
    }
    
    private Flux<UserStatistics> getUserStatistics(Long examId) {
        return examSessionRepository.findByExamId(examId)
                .flatMap(session -> buildUserStatistics(session));
    }
    
    private Mono<UserStatistics> buildUserStatistics(ExamSession session) {
        return userRepository.findById(session.getUserId())
                .flatMap(user -> {
                    Mono<Long> questionsAnswered = userResponseRepository.countResponsesBySessionId(session.getId());
                    Mono<Long> correctAnswers = userResponseRepository.findBySessionId(session.getId())
                            .filter(response -> response.getIsCorrect())
                            .count();
                    
                    return Mono.zip(questionsAnswered, correctAnswers)
                            .map(tuple -> {
                                Long answered = tuple.getT1();
                                Long correct = tuple.getT2();
                                Double currentPercentage = answered > 0 ? (correct.doubleValue() / answered) * 100 : 0.0;
                                
                                return UserStatistics.builder()
                                        .userId(user.getId())
                                        .username(user.getUsername())
                                        .fullName(user.getFullName())
                                        .questionsAnswered(answered.intValue())
                                        .correctAnswers(correct.intValue())
                                        .currentPercentage(currentPercentage)
                                        .status(session.getStatus().name())
                                        .startedAt(session.getStartedAt())
                                        .lastActivity(session.getUpdatedAt())
                                        .build();
                            });
                });
    }
    
    public Flux<QuestionStatistics> getMostDifficultQuestions(Long examId, Integer limit) {
        return getQuestionStatistics(examId)
                .sort(Comparator.comparing(QuestionStatistics::getCorrectPercentage))
                .take(limit != null ? limit : 5);
    }
    
    public Flux<QuestionStatistics> getMostCorrectQuestions(Long examId, Integer limit) {
        return getQuestionStatistics(examId)
                .sort(Comparator.comparing(QuestionStatistics::getCorrectPercentage).reversed())
                .take(limit != null ? limit : 5);
    }
    
    public Flux<UserStatistics> getTopPerformers(Long examId, Integer limit) {
        return getUserStatistics(examId)
                .sort(Comparator.comparing(UserStatistics::getCurrentPercentage).reversed())
                .take(limit != null ? limit : 10);
    }
    
    public Mono<Double> getExamProgress(Long sessionId) {
        return examSessionRepository.findById(sessionId)
                .flatMap(session -> {
                    Mono<Long> totalQuestions = questionRepository.countByExamId(session.getExamId());
                    Mono<Long> answeredQuestions = userResponseRepository.countResponsesBySessionId(sessionId);
                    
                    return Mono.zip(totalQuestions, answeredQuestions)
                            .map(tuple -> {
                                Long total = tuple.getT1();
                                Long answered = tuple.getT2();
                                return total > 0 ? (answered.doubleValue() / total) * 100 : 0.0;
                            });
                });
    }
}