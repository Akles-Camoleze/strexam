package com.camoleze.examapi.repository;

import com.camoleze.examapi.model.Answer;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;

@Repository
public interface AnswerRepository extends R2dbcRepository<Answer, Long> {
    Flux<Answer> findByQuestionIdOrderByOrderIndex(Long questionId);
    Flux<Answer> findByQuestionIdAndIsCorrect(Long questionId, Boolean isCorrect);
}