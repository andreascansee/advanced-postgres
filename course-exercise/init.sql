-- Setup
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- Schema
DROP SCHEMA IF EXISTS course_platform CASCADE;
CREATE SCHEMA course_platform;
SET search_path = course_platform;

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    is_instructor BOOLEAN DEFAULT FALSE
);

-- Courses table
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    instructor_id INTEGER REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT clock_timestamp()
);

-- Enrollments table
CREATE TABLE enrollments (
    user_id INTEGER REFERENCES users(id),
    course_id INTEGER REFERENCES courses(id),
    enrolled_at TIMESTAMPTZ DEFAULT clock_timestamp(),
    PRIMARY KEY (user_id, course_id)
);

-- Insert sample users (non-generic)
INSERT INTO users (email, full_name, is_instructor) VALUES
    ('maria.rojas@learnhub.org', 'Maria Rojas', TRUE),
    ('li.wei@learnhub.org', 'Li Wei', TRUE),
    ('nina.martin@studentmail.com', 'Nina Martin', FALSE),
    ('tobias.schmidt@studentmail.com', 'Tobias Schmidt', FALSE),
    ('ayana.patel@studentmail.com', 'Ayana Patel', FALSE),
    ('diego.santana@studentmail.com', 'Diego Santana', FALSE);

-- Insert sample courses
INSERT INTO courses (title, description, instructor_id) VALUES
    ('Databases 101', 'Fundamentals of relational databases and SQL', 1),
    ('PostgreSQL for Developers', 'Effective use of PostgreSQL features', 1),
    ('Data Warehousing with PostgreSQL', 'Modeling and querying for analytics', 2),
    ('Real-Time Apps with Postgres', 'Triggers, LISTEN/NOTIFY, logical decoding', 2);

-- Insert sample enrollments
INSERT INTO enrollments (user_id, course_id) VALUES
    (3, 1),
    (3, 2),
    (4, 1),
    (4, 3),
    (5, 1),
    (5, 2),
    (5, 4),
    (6, 2),
    (6, 3);
