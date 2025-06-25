package com.camoleze.examapi.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuestionStatistics {
    private Long questionId;
    private String questionText;
    private Integer totalResponses;
    private Integer correctResponses;
    private Double correctPercentage;
    private Boolean isMostDifficult;
    private Boolean isMostCorrect;
}