package com.camoleze.examapi.repository;

import com.camoleze.examapi.model.Question;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Repository
public interface QuestionRepository extends R2dbcRepository<Question, Long> {
    Flux<Question> findByExamIdOrderByOrderIndex(Long examId);
    Mono<Long> countByExamId(Long examId);
}