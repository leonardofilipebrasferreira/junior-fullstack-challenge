CREATE TABLE IF NOT EXISTS messages (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL
);

INSERT INTO messages (content)
SELECT 'Hello from PostgreSQL!'
WHERE NOT EXISTS (
  SELECT 1 FROM messages
);