package com.camoleze.examapi.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.bind.support.WebExchangeBindException;
import reactor.core.publisher.Mono;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    
    @ExceptionHandler(RuntimeException.class)
    public Mono<ResponseEntity<Map<String, String>>> handleRuntimeException(RuntimeException ex) {
        log.error("Runtime exception: ", ex);
        Map<String, String> error = new HashMap<>();
        error.put("error", ex.getMessage());
        error.put("timestamp", java.time.Instant.now().toString());
        
        return Mono.just(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error));
    }
    
    @ExceptionHandler(WebExchangeBindException.class)
    public Mono<ResponseEntity<Map<String, Object>>> handleValidationException(WebExchangeBindException ex) {
        log.error("Validation exception: ", ex);
        Map<String, Object> error = new HashMap<>();
        error.put("error", "Validation failed");
        error.put("timestamp", java.time.Instant.now().toString());
        
        Map<String, String> fieldErrors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(fieldError -> 
            fieldErrors.put(fieldError.getField(), fieldError.getDefaultMessage()));
        
        error.put("fieldErrors", fieldErrors);
        
        return Mono.just(ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error));
    }
    
    @ExceptionHandler(Exception.class)
    public Mono<ResponseEntity<Map<String, String>>> handleGenericException(Exception ex) {
        log.error("Unexpected exception: ", ex);
        Map<String, String> error = new HashMap<>();
        error.put("error", "Internal server error");
        error.put("timestamp", java.time.Instant.now().toString());
        
        return Mono.just(ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error));
    }
}