package com.camoleze.examapi.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AnswerSubmissionRequest {
    @NotNull(message = "Session ID is required")
    private Long sessionId;
    
    @NotNull(message = "Question ID is required")
    private Long questionId;
    
    private Long answerId; // for multiple choice
    private String responseText; // for short answer
}