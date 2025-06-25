package com.camoleze.examapi.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table("answers")
public class Answer {
    @Id
    private Long id;
    private Long questionId;
    private String answerText;
    private Boolean isCorrect;
    private Integer orderIndex;
}