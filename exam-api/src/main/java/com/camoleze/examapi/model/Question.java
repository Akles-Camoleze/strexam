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
@Table("questions")
public class Question {
    @Id
    private Long id;
    private Long examId;
    private String questionText;
    private QuestionType type;
    private Integer orderIndex;
    private Integer points;
    
    public enum QuestionType {
        MULTIPLE_CHOICE, TRUE_FALSE, SHORT_ANSWER
    }
}