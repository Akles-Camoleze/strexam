package com.camoleze.examapi.dto;

import com.camoleze.examapi.model.Question;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class QuestionResponse {
    private Long id;
    private String questionText;
    private String type;
    private Integer orderIndex;
    private Integer points;
    private List<AnswerResponse> answers;
    private QuestionStatistics statistics;
    
    public static QuestionResponse fromEntity(Question question) {
        return QuestionResponse.builder()
                .id(question.getId())
                .questionText(question.getQuestionText())
                .type(question.getType().name())
                .orderIndex(question.getOrderIndex())
                .points(question.getPoints())
                .build();
    }
}
