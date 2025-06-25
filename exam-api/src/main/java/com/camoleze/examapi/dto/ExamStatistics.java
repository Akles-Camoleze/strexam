package com.camoleze.examapi.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ExamStatistics {
    private Long examId;
    private String examTitle;
    private Integer totalParticipants;
    private Integer completedParticipants;
    private Double averageScore;
    private Double completionRate;
    private Integer totalQuestions;
}