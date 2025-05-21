DROP ROLE IF EXISTS app_user;
CREATE ROLE app_user LOGIN PASSWORD 'pass';

GRANT CONNECT ON DATABASE rls_demo TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT ON tenants, users, projects TO app_user;

\du app_user