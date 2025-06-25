package com.camoleze.examapi.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table("exam_sessions")
public class ExamSession {
    @Id
    private Long id;
    private Long examId;
    private Long userId;
    private SessionStatus status;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
    private Integer totalScore;
    private Integer maxScore;
    
    @CreatedDate
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime updatedAt;
    
    public enum SessionStatus {
        STARTED, IN_PROGRESS, COMPLETED, ABANDONED
    }
}