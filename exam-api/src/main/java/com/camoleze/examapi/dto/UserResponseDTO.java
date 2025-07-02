package com.camoleze.examapi.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class UserResponseDTO {
    private Long id;
    private Long sessionId;
    private Long questionId;
    private Long answerId;
    private String responseText;
    private Boolean isCorrect;
    private Integer pointsEarned;
    private LocalDateTime respondedAt;
    
    // Additional fields for UI display
    private String questionText;
    private String questionType;
    private Integer questionPoints;
}