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
@Table("exams")
public class Exam {
    @Id
    private Long id;
    private String title;
    private String description;
    private Long hostUserId;
    private String joinCode;
    private ExamStatus status;
    private Integer timeLimit; // in minutes
    private Boolean allowRetake;
    
    @CreatedDate
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime updatedAt;
    
    public enum ExamStatus {
        DRAFT, ACTIVE, COMPLETED, CANCELLED
    }
}