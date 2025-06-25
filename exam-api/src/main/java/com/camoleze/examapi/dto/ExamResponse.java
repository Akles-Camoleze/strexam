package com.camoleze.examapi.dto;

import com.camoleze.examapi.model.Exam;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class ExamResponse {
    private Long id;
    private String title;
    private String description;
    private String joinCode;
    private String status;
    private Integer timeLimit;
    private Boolean allowRetake;
    private Long hostUserId;
    private String hostUsername;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;
    private List<QuestionResponse> questions;
    private ExamStatistics statistics;
    
    public static ExamResponse fromEntity(Exam exam) {
        return ExamResponse.builder()
                .id(exam.getId())
                .title(exam.getTitle())
                .description(exam.getDescription())
                .joinCode(exam.getJoinCode())
                .status(exam.getStatus().name())
                .timeLimit(exam.getTimeLimit())
                .allowRetake(exam.getAllowRetake())
                .hostUserId(exam.getHostUserId())
                .createdAt(exam.getCreatedAt())
                .build();
    }
}