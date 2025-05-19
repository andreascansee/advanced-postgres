-- Setup
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- Schema
DROP SCHEMA IF EXISTS expense_demo CASCADE;
CREATE SCHEMA expense_demo;
SET default_tablespace = '';
SET default_table_access_method = heap;
SET search_path = expense_demo;

-- Users table
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    email TEXT NOT NULL UNIQUE
);

-- Expenses table
CREATE TABLE expenses (
    id INTEGER,
    user_id INTEGER REFERENCES users(id),
    amount NUMERIC(10, 2) NOT NULL,
    category TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT clock_timestamp(),
    PRIMARY KEY (id, user_id)
);

-- Insert test users
INSERT INTO users (id, email) VALUES
    (1, 'pennywise@example.com'),
    (2, 'buckaroo@example.com'),
    (3, 'centsible@example.com');

-- Insert test expenses
INSERT INTO expenses (id, user_id, amount, category, created_at) VALUES
    (1001, 1, 50.00, 'Groceries', '2023-11-15 18:49:14.84806+01'),
    (1002, 1, 25.00, 'Transport', '2023-11-15 19:00:00.00000+01'),
    (1003, 2, 15.50, 'Coffee',    '2023-11-15 19:10:00.00000+01'),
    (1004, 3, 199.99, 'Electronics', '2023-11-15 20:00:00.00000+01');