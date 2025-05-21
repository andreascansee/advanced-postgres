CREATE POLICY tenant_isolation ON projects
USING (tenant_id = current_setting('app.current_tenant_id')::int);

-- Check
SELECT * FROM pg_policies WHERE tablename = 'projects';