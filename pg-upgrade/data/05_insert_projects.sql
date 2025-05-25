INSERT INTO projects (org_id, name) VALUES
  (1, 'Client Portal Redesign'),     -- Axon
  (1, 'Internal Analytics Suite'),   -- Axon
  (2, 'Data Compliance Toolkit'),    -- Veritas
  (3, 'Device Provisioning App')    -- Novacore
ON CONFLICT (org_id, name) DO NOTHING;
