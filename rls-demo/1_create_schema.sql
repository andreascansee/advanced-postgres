CREATE TABLE tenants (
    id serial PRIMARY KEY,
    name text NOT NULL
);

CREATE TABLE users (
    id serial PRIMARY KEY,
    email text UNIQUE NOT NULL,
    tenant_id int NOT NULL REFERENCES tenants(id)
);

CREATE TABLE projects (
    id serial PRIMARY KEY,
    name text NOT NULL,
    tenant_id int NOT NULL REFERENCES tenants(id)
);

\dt