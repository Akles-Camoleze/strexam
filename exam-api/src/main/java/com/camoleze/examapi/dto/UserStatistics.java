package com.camoleze.examapi.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class UserStatistics {
    private Long userId;
    private String username;
    private String fullName;
    private Integer questionsAnswered;
    private Integer correctAnswers;
    private Double currentPercentage;
    private String status; // STARTED, IN_PROGRESS, COMPLETED
    private Integer totalScore;
    private Integer maxScore;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime startedAt;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime lastActivity;
}