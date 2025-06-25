package com.camoleze.examapi.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Data
public class ExamJoinRequest {
    @NotBlank(message = "Join code is required")
    private String joinCode;
    
    @NotNull(message = "User ID is required")
    private Long userId;
}