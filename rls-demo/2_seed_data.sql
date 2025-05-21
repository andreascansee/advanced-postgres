INSERT INTO tenants (name) VALUES
('LunarTech Labs'),
('Nebula Dynamics');

INSERT INTO users (email, tenant_id) VALUES
('ariella@lunartech.io', 1),
('dante@nebula-dynamics.com', 2),
('kai@lunartech.io', 1),
('zara@nebula-dynamics.com', 2);

INSERT INTO projects (name, tenant_id) VALUES
('Moonbase Alpha', 1),       -- LunarTech's flagship initiative
('ChronoLens', 2),           -- Nebula's time visualization tool
('Solar Weave', 1),          -- Experimental solar panel network
('Project Mirage', 2);       -- Secretive R&D project