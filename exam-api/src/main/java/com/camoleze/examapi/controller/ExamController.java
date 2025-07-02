package com.camoleze.examapi.controller;

import com.camoleze.examapi.dto.*;
import com.camoleze.examapi.service.ExamService;
import com.camoleze.examapi.service.StatisticsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
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

    @GetMapping("/participant/{userId}")
    public Flux<ExamResponse> getExamsByParticipant(@PathVariable("userId") Long userId) {
        log.info("Getting exams for participant {}", userId);
        return examService.getExamsByParticipant(userId);
    }

    @GetMapping("/participant/{userId}/sessions")
    public Flux<ExamSessionResponse> getSessionsByParticipant(@PathVariable("userId") Long userId) {
        log.info("Getting sessions for participant {}", userId);
        return examService.getSessionsByParticipant(userId);
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
        log.info("Submitting answer for session {} question {}", request.getSessionId(), request.getQuestionId());
        return examService.submitAnswer(request);
    }

    @PutMapping("/sessions/{sessionId}/complete")
    public Mono<ExamSessionResponse> completeExam(@PathVariable("sessionId") Long sessionId) {
        log.info("Completing exam session {}", sessionId);
        return examService.completeExam(sessionId);
    }

    @GetMapping(value = "/{examId}/statistics", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<StatisticsResponse> getExamStatistics(@PathVariable("examId") Long examId) {
        log.info("Starting SSE stream for exam statistics {}", examId);

        return Flux.merge(
                statisticsService.getStatistics(examId),
                examService.getExamEventStream(examId)
                        .filter(event -> event.getType() == ExamEvent.ExamEventType.STATISTICS_UPDATED)
                        .flatMap(event -> statisticsService.getStatistics(examId))
        );
    }

    @GetMapping(value = "/{examId}/statistics/difficult-questions", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<QuestionStatistics> getMostDifficultQuestions(
            @PathVariable("examId") Long examId,
            @RequestParam(defaultValue = "5", name = "limit") Integer limit
    ) {
        return Flux.merge(
                statisticsService.getMostDifficultQuestions(examId, limit),
                examService.getExamEventStream(examId)
                        .filter(event -> event.getType() == ExamEvent.ExamEventType.STATISTICS_UPDATED)
                        .flatMap(event -> statisticsService.getMostDifficultQuestions(examId, limit))
        );
    }

    @GetMapping(value = "/{examId}/statistics/correct-questions", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<QuestionStatistics> getMostCorrectQuestions(
            @PathVariable("examId") Long examId,
            @RequestParam(defaultValue = "5", name = "limit") Integer limit
    ) {
        return Flux.merge(
                statisticsService.getMostCorrectQuestions(examId, limit),
                examService.getExamEventStream(examId)
                        .filter(event -> event.getType() == ExamEvent.ExamEventType.STATISTICS_UPDATED)
                        .flatMap(event -> statisticsService.getMostCorrectQuestions(examId, limit))
        );
    }

    @GetMapping(value = "/{examId}/statistics/top-performers", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<UserStatistics> getTopPerformers(
            @PathVariable("examId") Long examId,
            @RequestParam(defaultValue = "10", name = "limit") Integer limit
    ) {
        return Flux.merge(
                statisticsService.getTopPerformers(examId, limit),
                examService.getExamEventStream(examId)
                        .filter(event -> event.getType() == ExamEvent.ExamEventType.STATISTICS_UPDATED)
                        .flatMap(event -> statisticsService.getTopPerformers(examId, limit))
        );
    }

    @GetMapping("/sessions/{sessionId}/progress")
    public Mono<Double> getExamProgress(@PathVariable("sessionId") Long sessionId) {
        log.info("Getting progress for session {}", sessionId);
        return statisticsService.getExamProgress(sessionId);
    }

    @GetMapping("/{examId}/sessions")
    public Flux<ExamSessionResponse> getSessionsByExam(@PathVariable("examId") Long examId) {
        log.info("Getting sessions for exam {}", examId);
        return examService.getSessionsByExam(examId);
    }

    @GetMapping("/sessions/{sessionId}/responses")
    public Flux<UserResponseDTO> getUserResponsesBySession(@PathVariable("sessionId") Long sessionId) {
        log.info("Getting user responses for session {}", sessionId);
        return examService.getUserResponsesBySession(sessionId);
    }

    @PutMapping("/responses/{responseId}/correct")
    public Mono<UserResponseDTO> updateShortAnswerCorrection(
            @PathVariable("responseId") Long responseId,
            @RequestParam("isCorrect") Boolean isCorrect) {
        log.info("Updating short answer correction for response {}, isCorrect: {}", responseId, isCorrect);
        return examService.updateShortAnswerCorrection(responseId, isCorrect);
    }
}
