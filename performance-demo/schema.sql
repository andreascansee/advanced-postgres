DROP DATABASE IF EXISTS teamhub_db;
CREATE DATABASE teamhub_db;

-- Now connect to it 
\c teamhub_db
-- ────────────────────────────────
-- Step 1: Drop existing tables
-- ────────────────────────────────
DROP TABLE IF EXISTS invoices, projects, members CASCADE;

-- ────────────────────────────────
-- Step 2: Create tables
-- ────────────────────────────────

CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT,
    joined_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    member_id INTEGER REFERENCES members(id),
    title TEXT,
    due_date DATE,
    completed BOOLEAN DEFAULT FALSE
);

CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    member_id INTEGER REFERENCES members(id),
    amount NUMERIC,
    paid BOOLEAN DEFAULT FALSE,
    issued_on DATE
);

-- ────────────────────────────────
-- Step 3: Insert demo members
-- ────────────────────────────────
-- Insert 100 realistic members
INSERT INTO members (email, full_name)
VALUES
  ('amy@teamhub.io', 'Amy Douglas'),
  ('ben@teamhub.io', 'Ben Tanaka'),
  ('claire@teamhub.io', 'Claire Nguyen'),
  ('daniel@teamhub.io', 'Daniel Schmidt'),
  ('emily@teamhub.io', 'Emily Costa'),
  ('frank@teamhub.io', 'Frank Meyer'),
  ('grace@teamhub.io', 'Grace Zhang'),
  ('henry@teamhub.io', 'Henry Kwan'),
  ('irene@teamhub.io', 'Irene Varga'),
  ('jack@teamhub.io', 'Jack Lemoine'),
  ('karen@teamhub.io', 'Karen Malik'),
  ('leo@teamhub.io', 'Leo Fischer'),
  ('maria@teamhub.io', 'Maria Espinoza'),
  ('nate@teamhub.io', 'Nate Reilly'),
  ('olivia@teamhub.io', 'Olivia Tran'),
  ('paul@teamhub.io', 'Paul Adebayo'),
  ('quinn@teamhub.io', 'Quinn Bellamy'),
  ('rachel@teamhub.io', 'Rachel Cohen'),
  ('sam@teamhub.io', 'Sam Hussein'),
  ('tina@teamhub.io', 'Tina Yamada'),
  ('ursula@teamhub.io', 'Ursula Novak'),
  ('vince@teamhub.io', 'Vince Gutierrez'),
  ('wendy@teamhub.io', 'Wendy Lang'),
  ('xander@teamhub.io', 'Xander Petrov'),
  ('yasmin@teamhub.io', 'Yasmin Ali'),
  ('zack@teamhub.io', 'Zack Laurent'),
  ('alina@teamhub.io', 'Alina Becker'),
  ('bruno@teamhub.io', 'Bruno Ortega'),
  ('celine@teamhub.io', 'Celine Tao'),
  ('diego@teamhub.io', 'Diego Romero'),
  ('elin@teamhub.io', 'Elin Åström'),
  ('fabian@teamhub.io', 'Fabian Nowak'),
  ('giulia@teamhub.io', 'Giulia Marino'),
  ('haris@teamhub.io', 'Haris Baig'),
  ('isabel@teamhub.io', 'Isabel Freitas'),
  ('jayden@teamhub.io', 'Jayden Clarke'),
  ('katja@teamhub.io', 'Katja Horvat'),
  ('lars@teamhub.io', 'Lars Jansen'),
  ('maya@teamhub.io', 'Maya Shukla'),
  ('noah@teamhub.io', 'Noah Kim'),
  ('ozan@teamhub.io', 'Ozan Demir'),
  ('petra@teamhub.io', 'Petra Novak'),
  ('raul@teamhub.io', 'Raul Sánchez'),
  ('sasha@teamhub.io', 'Sasha Levin'),
  ('tara@teamhub.io', 'Tara Bakshi'),
  ('umit@teamhub.io', 'Ümit Yilmaz'),
  ('violet@teamhub.io', 'Violet Hughes'),
  ('wes@teamhub.io', 'Wes Kruger'),
  ('xin@teamhub.io', 'Xin Liao'),
  ('yana@teamhub.io', 'Yana Petkova'),
  ('ziad@teamhub.io', 'Ziad Hossain'),
  ('albert@teamhub.io', 'Albert Reyes'),
  ('bianca@teamhub.io', 'Bianca Moretti'),
  ('colin@teamhub.io', 'Colin Russo'),
  ('daria@teamhub.io', 'Daria Kowalski'),
  ('emre@teamhub.io', 'Emre Aydın'),
  ('fiona@teamhub.io', 'Fiona McIntyre'),
  ('gustav@teamhub.io', 'Gustav Lindholm'),
  ('hana@teamhub.io', 'Hana Elbaz'),
  ('igor@teamhub.io', 'Igor Pavlov'),
  ('julia@teamhub.io', 'Julia Gálvez'),
  ('karim@teamhub.io', 'Karim El-Sayed'),
  ('lena@teamhub.io', 'Lena Schneider'),
  ('marko@teamhub.io', 'Marko Knežević'),
  ('nadia@teamhub.io', 'Nadia Rafiq'),
  ('omer@teamhub.io', 'Omer Safi'),
  ('pia@teamhub.io', 'Pia Sørensen'),
  ('quentin@teamhub.io', 'Quentin Baudet'),
  ('raj@teamhub.io', 'Raj Patel'),
  ('sara@teamhub.io', 'Sara Haddad'),
  ('tom@teamhub.io', 'Tom Becker'),
  ('ulrika@teamhub.io', 'Ulrika Larsson'),
  ('valentina@teamhub.io', 'Valentina Rossi'),
  ('will@teamhub.io', 'Will Thorne'),
  ('xenia@teamhub.io', 'Xenia Baranov'),
  ('yosef@teamhub.io', 'Yosef Nader'),
  ('zoe@teamhub.io', 'Zoe Murphy'),
  ('amir@teamhub.io', 'Amir Rezaei'),
  ('bella@teamhub.io', 'Bella Lin'),
  ('carlos@teamhub.io', 'Carlos Mendes'),
  ('daphne@teamhub.io', 'Daphne Boone'),
  ('eli@teamhub.io', 'Eli Cohen'),
  ('farah@teamhub.io', 'Farah Osman'),
  ('gavin@teamhub.io', 'Gavin Fielding'),
  ('haley@teamhub.io', 'Haley Ueno'),
  ('isak@teamhub.io', 'Isak Nilsson'),
  ('joana@teamhub.io', 'Joana Pereira'),
  ('kenji@teamhub.io', 'Kenji Watanabe'),
  ('leah@teamhub.io', 'Leah Stein'),
  ('milos@teamhub.io', 'Miloš Ristić'),
  ('nina@teamhub.io', 'Nina Popović'),
  ('oliver@teamhub.io', 'Oliver Brandt'),
  ('paula@teamhub.io', 'Paula Fernández'),
  ('ricardo@teamhub.io', 'Ricardo Silva'),
  ('sofia@teamhub.io', 'Sofia Duarte'),
  ('tim@teamhub.io', 'Tim Krause'),
  ('urs@teamhub.io', 'Urs Widmer'),
  ('vlad@teamhub.io', 'Vlad Ionescu'),
  ('wen@teamhub.io', 'Wen Zhao'),
  ('yuki@teamhub.io', 'Yuki Nakamura');

-- ────────────────────────────────
-- Step 4: Insert large project and invoice dataset
-- (500k+ total rows across tables)
-- ────────────────────────────────

-- Insert 300,000 projects (3k per member)
INSERT INTO projects (member_id, title, due_date, completed)
SELECT
  m.id,
  'Project #' || g,
  NOW() + (g % 100 || ' days')::INTERVAL,
  (RANDOM() > 0.8)
FROM generate_series(1, 3000) g
CROSS JOIN members m;

INSERT INTO invoices (member_id, amount, paid, issued_on)
SELECT
  m.id,
  ROUND((100 + RANDOM() * 900)::numeric, 2),
  (RANDOM() > 0.5),
  NOW() - ((RANDOM() * 720)::INT || ' days')::INTERVAL
FROM generate_series(1, 2000) g
CROSS JOIN members m;