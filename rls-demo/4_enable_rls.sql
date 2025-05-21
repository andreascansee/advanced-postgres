ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Optional: enforce for superusers
-- ALTER TABLE projects FORCE ROW LEVEL SECURITY;

-- Check
SELECT relname, relrowsecurity, relforcerowsecurity
FROM pg_class WHERE relname = 'projects';