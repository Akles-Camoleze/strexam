package com.camoleze.examapi.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

@Data
@Builder
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class UserStatistics {
    @EqualsAndHashCode.Include
    private Long userId;

    @EqualsAndHashCode.Include
    private String username;

    @EqualsAndHashCode.Include
    private String fullName;

    @EqualsAndHashCode.Include
    private Integer questionsAnswered;

    @EqualsAndHashCode.Include
    private Integer correctAnswers;

    @EqualsAndHashCode.Include
    private Double currentPercentage;

    @EqualsAndHashCode.Include
    private String status; // STARTED, IN_PROGRESS, COMPLETED

    @EqualsAndHashCode.Include
    private Integer totalScore;

    @EqualsAndHashCode.Include
    private Integer maxScore;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime startedAt;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime lastActivity;
}