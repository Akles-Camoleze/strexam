-- V1__create_schema.sql
-- Create tables for the exam application

-- Users table
CREATE TABLE IF NOT EXISTS users
(
    id         BIGSERIAL PRIMARY KEY,
    username   VARCHAR(50) UNIQUE  NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    full_name  VARCHAR(100)        NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- Exams table
CREATE TABLE IF NOT EXISTS exams
(
    id           BIGSERIAL PRIMARY KEY,
    title        VARCHAR(200)       NOT NULL,
    description  TEXT,
    host_user_id BIGINT             NOT NULL REFERENCES users (id),
    join_code    VARCHAR(10) UNIQUE NOT NULL,
    status       VARCHAR(20) DEFAULT 'DRAFT',
    time_limit   INTEGER, -- in minutes
    allow_retake BOOLEAN     DEFAULT FALSE,
    created_at   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
    );

-- Questions table
CREATE TABLE IF NOT EXISTS questions
(
    id            BIGSERIAL PRIMARY KEY,
    exam_id       BIGINT      NOT NULL REFERENCES exams (id) ON DELETE CASCADE,
    question_text TEXT        NOT NULL,
    type          VARCHAR(20) NOT NULL, -- MULTIPLE_CHOICE, TRUE_FALSE, SHORT_ANSWER
    order_index   INTEGER     NOT NULL,
    points        INTEGER DEFAULT 1
    );

-- Answers table (for multiple choice and true/false questions)
CREATE TABLE IF NOT EXISTS answers
(
    id          BIGSERIAL PRIMARY KEY,
    question_id BIGINT  NOT NULL REFERENCES questions (id) ON DELETE CASCADE,
    answer_text TEXT    NOT NULL,
    is_correct  BOOLEAN DEFAULT FALSE,
    order_index INTEGER NOT NULL
    );

-- Exam sessions table (tracks user participation in exams)
CREATE TABLE IF NOT EXISTS exam_sessions
(
    id           BIGSERIAL PRIMARY KEY,
    exam_id      BIGINT NOT NULL REFERENCES exams (id),
    user_id      BIGINT NOT NULL REFERENCES users (id),
    status       VARCHAR(20) DEFAULT 'STARTED', -- STARTED, IN_PROGRESS, COMPLETED, ABANDONED
    started_at   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    total_score  INTEGER     DEFAULT 0,
    max_score    INTEGER     DEFAULT 0,
    created_at   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (exam_id, user_id)                   -- One session per user per exam (unless retakes allowed)
    );

-- User responses table (stores answers submitted by users)
CREATE TABLE IF NOT EXISTS user_responses
(
    id            BIGSERIAL PRIMARY KEY,
    session_id    BIGINT NOT NULL REFERENCES exam_sessions (id) ON DELETE CASCADE,
    question_id   BIGINT NOT NULL REFERENCES questions (id),
    answer_id     BIGINT REFERENCES answers (id), -- for multiple choice
    response_text TEXT,                           -- for short answer
    is_correct    BOOLEAN   DEFAULT FALSE,
    points_earned INTEGER   DEFAULT 0,
    responded_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (session_id, question_id)              -- One response per question per session
    );

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_exams_host_user ON exams (host_user_id);
CREATE INDEX IF NOT EXISTS idx_exams_join_code ON exams (join_code);
CREATE INDEX IF NOT EXISTS idx_questions_exam ON questions (exam_id);
CREATE INDEX IF NOT EXISTS idx_answers_question ON answers (question_id);
CREATE INDEX IF NOT EXISTS idx_sessions_exam ON exam_sessions (exam_id);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON exam_sessions (user_id);
CREATE INDEX IF NOT EXISTS idx_responses_session ON user_responses (session_id);
CREATE INDEX IF NOT EXISTS idx_responses_question ON user_responses (question_id);