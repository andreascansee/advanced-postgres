-- Axon Projects
INSERT INTO tasks (project_id, assignee_id, title, status) VALUES
  (1, 1, 'Design UI components', 'in_progress'),
  (1, 2, 'Implement auth flow', 'todo'),
  (2, 2, 'Integrate reporting backend', 'done')
ON CONFLICT (project_id, title) DO NOTHING;

-- Veritas Project
INSERT INTO tasks (project_id, assignee_id, title, status) VALUES
  (3, 3, 'Review legal checklist', 'in_progress'),
  (3, NULL, 'Add audit logging', 'todo')
ON CONFLICT (project_id, title) DO NOTHING;

-- Novacore Project
INSERT INTO tasks (project_id, assignee_id, title, status) VALUES
  (4, 5, 'Provision test devices', 'in_progress'),
  (4, NULL, 'Write usage documentation', 'todo')
ON CONFLICT (project_id, title) DO NOTHING;