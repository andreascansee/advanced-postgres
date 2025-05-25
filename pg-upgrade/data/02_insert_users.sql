INSERT INTO users (email, name) VALUES
  ('emma.liu@axon.io', 'Emma Liu'),
  ('david.lee@axon.io', 'David Lee'),
  ('sofia.khan@veritas.tech', 'Sofia Khan'),
  ('marco.jansen@veritas.tech', 'Marco Jansen'),
  ('aline.martin@novacore.net', 'Aline Martin')
ON CONFLICT (email) DO NOTHING;