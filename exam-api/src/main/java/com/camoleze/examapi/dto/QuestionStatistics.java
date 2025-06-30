package com.camoleze.examapi.dto;

import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@Builder
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class QuestionStatistics {
    @EqualsAndHashCode.Include
    private Long questionId;

    @EqualsAndHashCode.Include
    private String questionText;

    @EqualsAndHashCode.Include
    private Integer totalResponses;

    @EqualsAndHashCode.Include
    private Integer correctResponses;

    @EqualsAndHashCode.Include
    private Double correctPercentage;

    @EqualsAndHashCode.Include
    private Boolean isMostDifficult;

    @EqualsAndHashCode.Include
    private Boolean isMostCorrect;
}