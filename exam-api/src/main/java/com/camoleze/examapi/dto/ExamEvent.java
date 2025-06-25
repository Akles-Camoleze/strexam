package com.camoleze.examapi.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamEvent {
    private ExamEventType type;
    private Long examId;
    private Long userId;
    private Object data;

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime timestamp;
    
    public enum ExamEventType {
        USER_JOINED,
        USER_LEFT,
        ANSWER_SUBMITTED,
        EXAM_COMPLETED,
        TIME_WARNING,
        EXAM_ENDED,
        STATISTICS_UPDATED
    }
}
