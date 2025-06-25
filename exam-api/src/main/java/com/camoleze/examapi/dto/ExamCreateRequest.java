package com.camoleze.examapi.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;
import java.util.List;

@Data
public class ExamCreateRequest {
    @NotBlank(message = "Title is required")
    private String title;
    
    private String description;
    
    @NotNull(message = "Host user ID is required")
    private Long hostUserId;
    
    @Positive(message = "Time limit must be positive")
    private Integer timeLimit;
    
    private Boolean allowRetake = false;
    
    @NotNull(message = "Questions are required")
    private List<QuestionCreateRequest> questions;
    
    @Data
    public static class QuestionCreateRequest {
        @NotBlank(message = "Question text is required")
        private String questionText;
        
        @NotNull(message = "Question type is required")
        private String type; // MULTIPLE_CHOICE, TRUE_FALSE, SHORT_ANSWER
        
        private Integer points = 1;
        
        private List<AnswerCreateRequest> answers;
    }
    
    @Data
    public static class AnswerCreateRequest {
        @NotBlank(message = "Answer text is required")
        private String answerText;
        
        private Boolean isCorrect = false;
    }
}