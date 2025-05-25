-- === Grant privileges to PostgreSQL roles ===

-- Allow both to connect
GRANT CONNECT ON DATABASE appdb TO analyst, developer;

-- Analyst: read-only access
GRANT USAGE ON SCHEMA public TO analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;

-- Developer: full access
GRANT ALL ON SCHEMA public TO developer;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO developer;