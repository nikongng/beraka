-- Script SQL: création de la table apartments (supporte une ou plusieurs photos via JSONB)

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS apartments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  price integer NOT NULL,
  image_url jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Option alternative: table dédiée aux images d'appartement
-- CREATE TABLE IF NOT EXISTS apartment_images (
--   id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
--   apartment_id uuid NOT NULL REFERENCES apartments(id) ON DELETE CASCADE,
--   image_url text NOT NULL,
--   position integer NOT NULL DEFAULT 0,
--   created_at timestamptz NOT NULL DEFAULT now()
-- );
