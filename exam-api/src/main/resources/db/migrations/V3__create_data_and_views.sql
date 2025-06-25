-- V3__create_data_and_views.sql
-- Sample data and views for the exam application

-- Sample data for testing
INSERT INTO users (username, email, full_name)
VALUES ('teacher1', 'teacher@example.com', 'John Teacher'),
       ('student1', 'student1@example.com', 'Alice Student'),
       ('student2', 'student2@example.com', 'Bob Student')
    ON CONFLICT (username) DO NOTHING;

-- Views for statistics
CREATE OR REPLACE VIEW exam_statistics AS
SELECT e.id                                                                                         as exam_id,
       e.title,
       e.host_user_id,
       COUNT(DISTINCT es.user_id)                                                                   as total_participants,
       COUNT(DISTINCT CASE WHEN es.status = 'COMPLETED' THEN es.user_id END)                        as completed_participants,
       AVG(CASE
               WHEN es.status = 'COMPLETED'
                   THEN (es.total_score::float / es.max_score * 100) END)                           as average_score_percentage
FROM exams e
         LEFT JOIN exam_sessions es ON e.id = es.exam_id
GROUP BY e.id, e.title, e.host_user_id;

CREATE OR REPLACE VIEW question_statistics AS
SELECT q.id                                      as question_id,
       q.exam_id,
       q.question_text,
       COUNT(ur.id)                              as total_responses,
       COUNT(CASE WHEN ur.is_correct THEN 1 END) as correct_responses,
       CASE
           WHEN COUNT(ur.id) > 0 THEN
               (COUNT(CASE WHEN ur.is_correct THEN 1 END)::float / COUNT(ur.id) * 100)
           ELSE 0
           END                                   as correct_percentage
FROM questions q
         LEFT JOIN user_responses ur ON q.id = ur.question_id
GROUP BY q.id, q.exam_id, q.question_text;