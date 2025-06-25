package com.camoleze.examapi.controller;

import com.camoleze.examapi.dto.ExamEvent;
import com.camoleze.examapi.service.ExamService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;

import java.time.Duration;

@RestController
@RequestMapping("/api/stream")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class StreamController {
    
    private final ExamService examService;
    
    @GetMapping(value = "/exams/{examId}", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<ExamEvent> streamExamEvents(@PathVariable("examId") Long examId, @RequestParam Long userId) {
        log.info("User {} connecting to exam {} stream", userId, examId);
        
        return examService.getExamEventStream(examId)
                .doOnSubscribe(subscription -> 
                    log.info("User {} subscribed to exam {} stream", userId, examId))
                .doOnCancel(() -> 
                    log.info("User {} disconnected from exam {} stream", userId, examId))
                .doOnError(error -> 
                    log.error("Error in exam {} stream for user {}: {}", examId, userId, error.getMessage()))
                .onErrorResume(error -> {
                    log.error("Stream error for exam {} user {}: {}", examId, userId, error.getMessage());
                    return Flux.empty();
                })
                // Send keep-alive events every 30 seconds
                .mergeWith(Flux.interval(Duration.ofSeconds(30))
                        .map(tick -> ExamEvent.builder()
                                .type(ExamEvent.ExamEventType.TIME_WARNING)
                                .examId(examId)
                                .data("keep-alive")
                                .build()));
    }
    
    @GetMapping(value = "/exams", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<ExamEvent> streamAllExamEvents(@RequestParam Long userId) {
        log.info("User {} connecting to global exam stream", userId);
        
        return examService.getExamEventStream()
                .doOnSubscribe(subscription -> 
                    log.info("User {} subscribed to global exam stream", userId))
                .doOnCancel(() -> 
                    log.info("User {} disconnected from global exam stream", userId))
                .onErrorResume(error -> {
                    log.error("Global stream error for user {}: {}", userId, error.getMessage());
                    return Flux.empty();
                });
    }
}
