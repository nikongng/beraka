-- Migration: add human-friendly category column to menu_packs
ALTER TABLE IF EXISTS menu_packs
  ADD COLUMN IF NOT EXISTS category text;

-- Map existing category_id values to human-friendly category names
UPDATE menu_packs SET category =
  CASE
    WHEN category_id = 'mariage' THEN 'Mariage'
    WHEN category_id = 'autres_ceremonies' THEN 'Autres cérémonies'
    WHEN category_id = 'exterieur' THEN 'Espace extérieur'
    ELSE 'Tous'
  END
  WHERE category IS NULL OR category = '';

-- Optional index for category filtering
CREATE INDEX IF NOT EXISTS idx_menu_packs_category ON menu_packs (category);
