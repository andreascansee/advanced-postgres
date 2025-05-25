-- Axon Solutions
INSERT INTO memberships (user_id, org_id, role) VALUES
  (1, 1, 'admin'),   -- Emma Liu
  (2, 1, 'member')  -- David Lee
ON CONFLICT (user_id, org_id) DO NOTHING;

-- Veritas Technologies
INSERT INTO memberships (user_id, org_id, role) VALUES
  (3, 2, 'admin'),   -- Sofia Khan
  (4, 2, 'member')  -- Marco Jansen
ON CONFLICT (user_id, org_id) DO NOTHING;

-- Novacore Systems
INSERT INTO memberships (user_id, org_id, role) VALUES
  (5, 3, 'admin')   -- Aline Martin
ON CONFLICT (user_id, org_id) DO NOTHING;