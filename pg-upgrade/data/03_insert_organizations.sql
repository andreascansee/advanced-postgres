INSERT INTO organizations (name) VALUES
  ('Axon Solutions'),
  ('Veritas Technologies'),
  ('Novacore Systems')
ON CONFLICT (name) DO NOTHING;