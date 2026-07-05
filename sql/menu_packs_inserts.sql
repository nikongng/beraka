-- Script SQL: création de la table menu_packs + INSERTs pour les packs codés en dur

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS menu_packs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id text NOT NULL,
  tag text,
  title text NOT NULL,
  price_text text,
  price integer,
  price_note text,
  description text,
  includes jsonb,
  premium boolean DEFAULT false,
  image_url text,
  default_menu_pack text,
  default_event_type text,
  created_at timestamptz DEFAULT now()
);

INSERT INTO menu_packs (category_id, tag, title, price_text, price, price_note, description, includes, premium, image_url, default_menu_pack, default_event_type) VALUES
('mariage', 'mariage_1', 'Décoration Basique', '2 500 USD', 2500, '', 'Décoration basique pour mariage avec mise en place standard et ambiance élégante.',
  '["Nappes et housses de chaises assorties", "Centres de table simples", "Éclairage d’ambiance doux", "Décoration de la table d’honneur"]', false, 'assets/images/decosimple.jpg', 'Décoration Basique', 'Mariage'),
('mariage', 'mariage_2', 'Décoration Moyenne', '3 000 USD', 3000, '', 'Décoration moyenne pour mariage avec éléments floraux et mobilier décoratif.',
  '["Tout le pack Basique", "Arches florales ou structure de cérémonie", "Chemins de table et décorations supplémentaires", "Décoration de chaises et signalétique"]', false, 'assets/images/decomoyenne.png', 'Décoration Moyenne', 'Mariage'),
('mariage', 'mariage_3', 'Décoration VIP', '3 500 USD', 3500, '', 'Décoration VIP pour mariage avec touches luxueuses et mise en scène complète.',
  '["Tout le pack Moyenne", "Décoration florale premium", "Mobilier lounge et coin photo", "Installation personnalisée haut de gamme"]', true, 'assets/images/decoluxe.jpg', 'Décoration VIP', 'Mariage'),
('autres_ceremonies', 'autres_1', 'Réunion, conférence, formation', '250 USD', 250, '', 'Pack événementiel pour réunion, conférence ou formation avec matériel de base.',
  '["Tables et chaises pour participants", "Matériel de présentation (projecteur, écran)", "Sonorisation légère", "Aménagement de l’espace et accueil"]', false, 'assets/images/conference.jpg', 'Réunion/Conférence', 'Autres cérémonies'),
('autres_ceremonies', 'autres_2', 'Mariage coutumier (option A)', '170 USD', 170, '', 'Formule mariage coutumier pour samedi avec décor traditionnel et espace cérémonial.',
  '["Décoration adaptée aux traditions", "Installation de la scène cérémoniale", "Coin d’accueil et mobilier décoratif", "Éclairage chaleureux"]', false, 'assets/images/mariagecoutumier.jpg', 'Mariage coutumier A', 'Autres cérémonies'),
('autres_ceremonies', 'autres_3', 'Mariage coutumier (option B)', '150 USD', 150, '', 'Formule mariage coutumier pour vendredi et dimanche avec décoration simplifiée.',
  '["Décoration traditionnelle légère", "Coin cérémonie et tables de réception", "Éléments de décoration culturelle", "Accueil et signalétique"]', false, 'assets/images/mariagecoutumier.jfif', 'Mariage coutumier B', 'Autres cérémonies'),
('exterieur', 'exterieur_1', 'Décoration Basique', '500 USD', 500, '', 'Décoration basique pour espace extérieur avec ambiance naturelle.',
  '["Guirlandes lumineuses et lampions", "Mobilier de jardin simple", "Décoration de tables et chemins extérieurs", "Aménagement d’un espace cocktail"]', false, 'assets/images/decoexternebasique.jfif', 'Décoration Basique', 'Espace extérieur'),
('exterieur', 'exterieur_2', 'Décoration VIP', '850 USD', 850, '', 'Décoration VIP pour espace extérieur avec touches festives et élégantes.',
  '["Tout le pack Basique", "Décorations fleuries et luminaires premium", "Espace lounge extérieur", "Aménagement de piste et accueil VIP"]', true, 'assets/images/decoexterneluxe.jfif', 'Décoration VIP', 'Espace extérieur');
