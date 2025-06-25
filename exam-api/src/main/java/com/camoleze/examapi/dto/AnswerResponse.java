package com.camoleze.examapi.dto;

import com.camoleze.examapi.model.Answer;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AnswerResponse {
    private Long id;
    private String answerText;
    private Boolean isCorrect; // Only included for host users
    private Integer orderIndex;
    
    public static AnswerResponse fromEntity(Answer answer, boolean includeCorrectness) {
        return AnswerResponse.builder()
                .id(answer.getId())
                .answerText(answer.getAnswerText())
                .isCorrect(includeCorrectness ? answer.getIsCorrect() : null)
                .orderIndex(answer.getOrderIndex())
                .build();
    }
}