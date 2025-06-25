package com.camoleze.examapi.repository;

import com.camoleze.examapi.model.Exam;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Repository
public interface ExamRepository extends R2dbcRepository<Exam, Long> {
    Mono<Exam> findByJoinCode(String joinCode);
    Flux<Exam> findByHostUserId(Long hostUserId);
    Mono<Boolean> existsByJoinCode(String joinCode);
    
    @Query("SELECT * FROM exams WHERE status = 'ACTIVE'")
    Flux<Exam> findActiveExams();
}