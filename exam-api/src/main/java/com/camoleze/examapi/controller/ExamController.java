package com.camoleze.examapi.controller;

import com.camoleze.examapi.dto.*;
import com.camoleze.examapi.service.ExamService;
import com.camoleze.examapi.service.StatisticsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/exams")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class ExamController {
    
    private final ExamService examService;
    private final StatisticsService statisticsService;
    
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Mono<ExamResponse> createExam(@Valid @RequestBody ExamCreateRequest request) {
        log.info("Creating exam: {}", request.getTitle());
        return examService.createExam(request);
    }
    
    @GetMapping("/{examId}")
    public Mono<ExamResponse> getExam(@PathVariable("examId") Long examId, @RequestParam("userId") Long userId) {
        log.info("Getting exam {} for user {}", examId, userId);
        return examService.getExam(examId, userId);
    }
    
    @GetMapping("/host/{hostUserId}")
    public Flux<ExamResponse> getExamsByHost(@PathVariable("hostUserId") Long hostUserId) {
        log.info("Getting exams for host {}", hostUserId);
        return examService.getExamsByHost(hostUserId);
    }
    
    @PostMapping("/join")
    public Mono<ExamSessionResponse> joinExam(@Valid @RequestBody ExamJoinRequest request) {
        log.info("User {} joining exam with code {}", request.getUserId(), request.getJoinCode());
        return examService.joinExam(request);
    }
    
    @PutMapping("/{examId}/activate")
    public Mono<ExamResponse> activateExam(@PathVariable("examId") Long examId) {
        log.info("Activating exam {}", examId);
        return examService.activateExam(examId)
                .map(ExamResponse::fromEntity);
    }
    
    @PostMapping("/answer")
    public Mono<Void> submitAnswer(@Valid @RequestBody AnswerSubmissionRequest request) {
        log.info("Submitting answer for session {} question {}", 
                request.getSessionId(), request.getQuestionId());
        return examService.submitAnswer(request);
    }
    
    @PutMapping("/sessions/{sessionId}/complete")
    public Mono<ExamSessionResponse> completeExam(@PathVariable("sessionId") Long sessionId) {
        log.info("Completing exam session {}", sessionId);
        return examService.completeExam(sessionId);
    }
    
    @GetMapping("/{examId}/statistics")
    public Mono<StatisticsResponse> getExamStatistics(@PathVariable("examId") Long examId) {
        log.info("Getting statistics for exam {}", examId);
        return statisticsService.getStatistics(examId);
    }
    
    @GetMapping("/{examId}/statistics/difficult-questions")
    public Flux<QuestionStatistics> getMostDifficultQuestions(
            @PathVariable("examId") Long examId,
            @RequestParam(defaultValue = "5", name = "limit") Integer limit
    ) {
        log.info("Getting most difficult questions for exam {}", examId);
        return statisticsService.getMostDifficultQuestions(examId, limit);
    }
    
    @GetMapping("/{examId}/statistics/correct-questions")
    public Flux<QuestionStatistics> getMostCorrectQuestions(
            @PathVariable("examId") Long examId,
            @RequestParam(defaultValue = "5", name = "limit") Integer limit
    ) {
        log.info("Getting most correct questions for exam {}", examId);
        return statisticsService.getMostCorrectQuestions(examId, limit);
    }
    
    @GetMapping("/{examId}/statistics/top-performers")
    public Flux<UserStatistics> getTopPerformers(
            @PathVariable("examId") Long examId,
            @RequestParam(defaultValue = "10", name = "limit") Integer limit
    ) {
        log.info("Getting top performers for exam {}", examId);
        return statisticsService.getTopPerformers(examId, limit);
    }
    
    @GetMapping("/sessions/{sessionId}/progress")
    public Mono<Double> getExamProgress(@PathVariable("sessionId") Long sessionId) {
        log.info("Getting progress for session {}", sessionId);
        return statisticsService.getExamProgress(sessionId);
    }
}