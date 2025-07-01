package com.camoleze.examapi.repository;

import com.camoleze.examapi.model.ExamSession;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;

@Repository
public interface ExamSessionRepository extends R2dbcRepository<ExamSession, Long> {
    Mono<ExamSession> findByExamIdAndUserId(Long examId, Long userId);
    Flux<ExamSession> findByExamIdAndUserIdOrderByCreatedAtDesc(Long examId, Long userId);
    Flux<ExamSession> findByExamId(Long examId);
    Flux<ExamSession> findByUserId(Long userId);
    
    @Query("SELECT COUNT(*) FROM exam_sessions WHERE exam_id = :examId")
    Mono<Long> countParticipantsByExamId(Long examId);
    
    @Query("SELECT COUNT(*) FROM exam_sessions WHERE exam_id = :examId AND status = 'COMPLETED'")
    Mono<Long> countCompletedByExamId(Long examId);
    
    @Query("""
        SELECT es.*, u.username, u.full_name 
        FROM exam_sessions es 
        JOIN users u ON es.user_id = u.id 
        WHERE es.exam_id = :examId
        """)
    Flux<ExamSession> findByExamIdWithUserInfo(Long examId);
}