-- Migration: add weekend and price_various columns to menu_packs
ALTER TABLE IF EXISTS menu_packs
  ADD COLUMN IF NOT EXISTS saturday_price integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS fri_sun_price integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS price_various boolean DEFAULT false;

-- Optional: add indexes if needed
CREATE INDEX IF NOT EXISTS idx_menu_packs_saturday_price ON menu_packs (saturday_price);
CREATE INDEX IF NOT EXISTS idx_menu_packs_fri_sun_price ON menu_packs (fri_sun_price);
