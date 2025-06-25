package com.camoleze.examapi.repository;

import com.camoleze.examapi.model.UserResponse;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Repository
public interface UserResponseRepository extends R2dbcRepository<UserResponse, Long> {
    Flux<UserResponse> findBySessionId(Long sessionId);
    Mono<UserResponse> findBySessionIdAndQuestionId(Long sessionId, Long questionId);
    Flux<UserResponse> findByQuestionId(Long questionId);
    
    @Query("SELECT COUNT(*) FROM user_responses WHERE session_id = :sessionId")
    Mono<Long> countResponsesBySessionId(Long sessionId);
    
    @Query("""
        SELECT COUNT(*) FROM user_responses ur
        JOIN exam_sessions es ON ur.session_id = es.id
        WHERE es.exam_id = :examId AND ur.question_id = :questionId
        """)
    Mono<Long> countResponsesByExamIdAndQuestionId(Long examId, Long questionId);
    
    @Query("""
        SELECT COUNT(*) FROM user_responses ur
        JOIN exam_sessions es ON ur.session_id = es.id
        WHERE es.exam_id = :examId AND ur.question_id = :questionId AND ur.is_correct = true
        """)
    Mono<Long> countCorrectResponsesByExamIdAndQuestionId(Long examId, Long questionId);
}