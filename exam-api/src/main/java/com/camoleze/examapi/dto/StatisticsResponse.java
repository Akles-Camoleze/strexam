package com.camoleze.examapi.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class StatisticsResponse {
    private ExamStatistics examStatistics;
    private List<QuestionStatistics> questionStatistics;
    private List<UserStatistics> userStatistics;
}