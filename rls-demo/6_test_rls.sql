SET ROLE app_user;

SET app.current_tenant_id = '1';
SELECT * FROM projects;

SET app.current_tenant_id = '2';
SELECT * FROM projects;

RESET ROLE;