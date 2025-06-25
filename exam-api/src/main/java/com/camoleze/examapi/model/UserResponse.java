package com.camoleze.examapi.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table("user_responses")
public class UserResponse {
    @Id
    private Long id;
    private Long sessionId;
    private Long questionId;
    private Long answerId;
    private String responseText;
    private Boolean isCorrect;
    private Integer pointsEarned;
    
    @CreatedDate
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime respondedAt;
}