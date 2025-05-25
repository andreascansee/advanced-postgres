-- === Create PostgreSQL roles ===
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'analyst') THEN
    CREATE ROLE analyst LOGIN PASSWORD 'analyst123';
  END IF;

  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'developer') THEN
    CREATE ROLE developer LOGIN PASSWORD 'dev123';
  END IF;
END$$;