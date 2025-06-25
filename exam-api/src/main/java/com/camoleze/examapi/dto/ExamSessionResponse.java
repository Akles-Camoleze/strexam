package com.camoleze.examapi.dto;

import com.camoleze.examapi.model.ExamSession;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class ExamSessionResponse {
    private Long id;
    private Long examId;
    private Long userId;
    private String status;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime startedAt;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime completedAt;
    private Integer totalScore;
    private Integer maxScore;
    private Double percentage;

    public static ExamSessionResponse fromEntity(ExamSession session) {
        Double percentage = null;
        if (session.getMaxScore() != null && session.getMaxScore() > 0) {
            percentage = (session.getTotalScore().doubleValue() / session.getMaxScore()) * 100;
        }

        return ExamSessionResponse.builder()
                .id(session.getId())
                .examId(session.getExamId())
                .userId(session.getUserId())
                .status(session.getStatus().name())
                .startedAt(session.getStartedAt())
                .completedAt(session.getCompletedAt())
                .totalScore(session.getTotalScore())
                .maxScore(session.getMaxScore())
                .percentage(percentage)
                .build();
    }
}