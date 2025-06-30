package com.camoleze.examapi.dto;

import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@Builder
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class ExamStatistics {
    @EqualsAndHashCode.Include
    private Long examId;

    @EqualsAndHashCode.Include
    private String examTitle;

    @EqualsAndHashCode.Include
    private Integer totalParticipants;

    @EqualsAndHashCode.Include
    private Integer completedParticipants;

    @EqualsAndHashCode.Include
    private Double averageScore;

    @EqualsAndHashCode.Include
    private Double completionRate;

    @EqualsAndHashCode.Include
    private Integer totalQuestions;
}