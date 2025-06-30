package com.camoleze.examapi.dto;

import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;

@Data
@Builder
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class StatisticsResponse {
    @EqualsAndHashCode.Include
    private ExamStatistics examStatistics;

    @EqualsAndHashCode.Include
    private List<QuestionStatistics> questionStatistics;

    @EqualsAndHashCode.Include
    private List<UserStatistics> userStatistics;
}