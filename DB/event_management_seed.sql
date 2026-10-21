-- ============================================================
-- Event Management Database - Test Seed Data
-- Target: MySQL 8.0.16+
-- ============================================================

USE event_management;

START TRANSACTION;

-- ------------------------------------------------------------
-- RESET TEST DATA
-- Child tables are cleared before their parents.
-- ------------------------------------------------------------

DELETE FROM api_raw_data;
DELETE FROM api_sync_log;
DELETE FROM external_records;
DELETE FROM external_systems;

DELETE FROM merchandise_contracts;
DELETE FROM event_merchandise;
DELETE FROM artist_merchandise;
DELETE FROM merchandise;

DELETE FROM event_bookings;
DELETE FROM site_availability;
DELETE FROM event_participants;
DELETE FROM event_sites;
DELETE FROM events;
DELETE FROM sites;

DELETE FROM manufacturing_contracts;
DELETE FROM discography_contracts;
DELETE FROM contracts;

DELETE FROM products;
DELETE FROM albums;

DELETE FROM manufacturers;
DELETE FROM record_labels;
DELETE FROM artists;
DELETE FROM parties;

-- ------------------------------------------------------------
-- PARTIES
-- ------------------------------------------------------------

INSERT INTO parties (
    party_id, party_type, name, email, phone, website, address
) VALUES
    (1, 'ARTIST', 'The Example Band',
     'contact@exampleband.test', '+1-555-0101',
     'https://exampleband.test', 'Los Angeles, CA, USA'),

    (2, 'ARTIST', 'Luna Rivera',
     'booking@lunarivera.test', '+502-5550-0102',
     'https://lunarivera.test', 'Guatemala City, Guatemala'),

    (3, 'RECORD_LABEL', 'Example Records',
     'contracts@examplerecords.test', '+1-555-0201',
     'https://examplerecords.test', 'New York, NY, USA'),

    (4, 'RECORD_LABEL', 'Aurora Music Group',
     'legal@auroramusic.test', '+502-5550-0202',
     'https://auroramusic.test', 'Guatemala City, Guatemala'),

    (5, 'MANUFACTURER', 'ACME Manufacturing',
     'sales@acmemfg.test', '+1-555-0301',
     'https://acmemfg.test', 'Austin, TX, USA'),

    (6, 'MANUFACTURER', 'PromoWorks Guatemala',
     'orders@promoworks.test', '+502-5550-0302',
     'https://promoworks.test', 'Mixco, Guatemala'),

    (7, 'ORGANIZER', 'Event Place Management',
     'events@eventplace.test', '+502-5550-0401',
     'https://eventplace.test', 'Guatemala City, Guatemala'),

    (8, 'SPONSOR', 'Central Beverage Co.',
     'sponsorships@centralbeverage.test', '+502-5550-0501',
     'https://centralbeverage.test', 'Guatemala City, Guatemala');

-- ------------------------------------------------------------
-- ARTISTS
-- ------------------------------------------------------------

INSERT INTO artists (
    artist_id, party_id, stage_name, legal_name,
    country_code, biography, website
) VALUES
    (1, 1, 'The Example Band', NULL, 'US',
     'Independent alternative rock band used for API testing.',
     'https://exampleband.test'),

    (2, 2, 'Luna Rivera', 'Luna Isabel Rivera', 'GT',
     'Guatemalan solo artist used for API and event testing.',
     'https://lunarivera.test');

-- ------------------------------------------------------------
-- RECORD LABELS
-- ------------------------------------------------------------

INSERT INTO record_labels (
    record_label_id, party_id, catalog_prefix, website
) VALUES
    (1, 3, 'EXR', 'https://examplerecords.test'),
    (2, 4, 'AMG', 'https://auroramusic.test');

-- ------------------------------------------------------------
-- MANUFACTURERS
-- ------------------------------------------------------------

INSERT INTO manufacturers (
    manufacturer_id, party_id, manufacturer_type, website
) VALUES
    (1, 5, 'GENERAL_MERCHANDISE', 'https://acmemfg.test'),
    (2, 6, 'PROMOTIONAL_PRODUCTS', 'https://promoworks.test');

-- ------------------------------------------------------------
-- ALBUMS
-- ------------------------------------------------------------

INSERT INTO albums (
    album_id, artist_id, title, release_date, catalog_number
) VALUES
    (1, 1, 'Greatest Hits', '2026-12-05', 'EXR-2026-001'),
    (2, 1, 'Night Drive', '2027-03-15', 'EXR-2027-002'),
    (3, 2, 'Luz de Ciudad', '2026-11-20', 'AMG-2026-010');

-- ------------------------------------------------------------
-- PRODUCTS
-- ------------------------------------------------------------

INSERT INTO products (
    product_id, manufacturer_id, product_name,
    description, sku, product_type
) VALUES
    (1, 1, 'Tour T-Shirt',
     'Black cotton tour shirt with front and back print.',
     'ACME-TSHIRT-001', 'APPAREL'),

    (2, 1, 'Limited Edition Poster',
     'Numbered full-color promotional concert poster.',
     'ACME-POSTER-001', 'PRINT'),

    (3, 2, 'Promotional Mug',
     'Ceramic mug carrying event venue branding.',
     'PW-MUG-001', 'PROMOTIONAL'),

    (4, 2, 'Event Wristband',
     'Reusable branded wristband for venue promotion.',
     'PW-WRIST-001', 'ACCESSORY');

-- ------------------------------------------------------------
-- CONTRACTS
-- ------------------------------------------------------------

INSERT INTO contracts (
    contract_id, contract_type, status,
    start_date, end_date, contract_terms
) VALUES
    (1, 'DISCOGRAPHY', 'ACTIVE',
     '2026-10-01', '2031-09-30',
     'Example Records holds distribution rights for Greatest Hits for five years.'),

    (2, 'DISCOGRAPHY', 'DRAFT',
     '2026-11-01', '2030-10-31',
     'Draft regional distribution agreement for Luz de Ciudad.'),

    (3, 'MANUFACTURING', 'ACTIVE',
     '2026-10-15', '2027-04-30',
     'ACME Manufacturing will produce branded tour shirts under agreed quality requirements.'),

    (4, 'MANUFACTURING', 'DRAFT',
     '2026-10-20', '2027-02-28',
     'PromoWorks Guatemala will manufacture promotional mugs for venue campaigns.'),

    (5, 'MERCHANDISE', 'ACTIVE',
     '2026-10-20', '2027-01-31',
     'Artist authorizes the use and distribution of signed promotional posters for the event.');

-- ------------------------------------------------------------
-- DISCOGRAPHY CONTRACT DETAILS
-- ------------------------------------------------------------

INSERT INTO discography_contracts (
    contract_id, artist_id, record_label_id, album_id, release_date
) VALUES
    (1, 1, 1, 1, '2026-12-05'),
    (2, 2, 2, 3, '2026-11-20');

-- ------------------------------------------------------------
-- MANUFACTURING CONTRACT DETAILS
-- ------------------------------------------------------------

INSERT INTO manufacturing_contracts (
    contract_id, manufacturer_id, product_id, release_date
) VALUES
    (3, 1, 1, '2026-11-15'),
    (4, 2, 3, '2026-12-01');

-- ------------------------------------------------------------
-- SITES
-- ------------------------------------------------------------

INSERT INTO sites (
    site_id, name, description, address, city, state, country,
    postal_code, latitude, longitude, capacity, site_type, status
) VALUES
    (1, 'Grand Ballroom',
     'Large indoor event hall suitable for concerts and product launches.',
     '100 Avenida Reforma', 'Guatemala City', 'Guatemala', 'Guatemala',
     '01010', 14.603700, -90.489300, 1200, 'BALLROOM', 'ACTIVE'),

    (2, 'Rooftop Stage',
     'Open-air rooftop venue for smaller evening performances.',
     '25 Zona 10', 'Guatemala City', 'Guatemala', 'Guatemala',
     '01010', 14.596100, -90.511200, 450, 'OUTDOOR_STAGE', 'ACTIVE'),

    (3, 'Conference Center',
     'Flexible indoor space for corporate and promotional events.',
     '500 Avenida Las Americas', 'Guatemala City', 'Guatemala', 'Guatemala',
     '01013', 14.588800, -90.521300, 800, 'CONFERENCE_CENTER', 'ACTIVE'),

    (4, 'Warehouse Hall',
     'Temporary event space currently under maintenance.',
     '12 Calzada Roosevelt', 'Mixco', 'Guatemala', 'Guatemala',
     '01057', 14.634500, -90.600000, 1800, 'WAREHOUSE', 'MAINTENANCE');

-- ------------------------------------------------------------
-- EVENTS
-- ------------------------------------------------------------

INSERT INTO events (
    event_id, name, description, event_type,
    status, start_date, end_date
) VALUES
    (1, 'Greatest Hits Release Night',
     'Album release event featuring The Example Band.',
     'CONCERT', 'CONFIRMED', '2026-11-14', '2026-11-14'),

    (2, 'Luz de Ciudad Showcase',
     'Promotional showcase featuring Luna Rivera.',
     'SHOWCASE', 'PLANNED', '2026-11-21', '2026-11-21'),

    (3, 'Venue Merch Promotion',
     'Promotional campaign for branded merchandise.',
     'PROMOTION', 'PLANNED', '2026-12-05', '2026-12-05');

-- ------------------------------------------------------------
-- EVENT / SITE ASSOCIATIONS
-- ------------------------------------------------------------

INSERT INTO event_sites (
    event_id, site_id, role
) VALUES
    (1, 1, 'MAIN'),
    (2, 2, 'MAIN'),
    (3, 3, 'MAIN');

-- ------------------------------------------------------------
-- EVENT PARTICIPANTS
-- ------------------------------------------------------------

INSERT INTO event_participants (
    event_participant_id, event_id, party_id, role, status, notes
) VALUES
    (1, 1, 1, 'ARTIST', 'CONFIRMED', 'Headline performer.'),
    (2, 1, 3, 'RECORD_LABEL', 'CONFIRMED', 'Coordinates album promotion.'),
    (3, 1, 7, 'ORGANIZER', 'CONFIRMED', 'Internal event organizer.'),
    (4, 2, 2, 'ARTIST', 'CONFIRMED', 'Featured performer.'),
    (5, 2, 4, 'RECORD_LABEL', 'INVITED', 'Label participation pending.'),
    (6, 2, 7, 'ORGANIZER', 'CONFIRMED', 'Internal event organizer.'),
    (7, 3, 6, 'MANUFACTURER', 'CONFIRMED', 'Provides promotional products.'),
    (8, 3, 7, 'ORGANIZER', 'CONFIRMED', 'Internal event organizer.'),
    (9, 3, 8, 'SPONSOR', 'INVITED', 'Potential event sponsor.');

-- ------------------------------------------------------------
-- SITE AVAILABILITY
--
-- 2026-11-14 at site 1 is intentionally marked available here,
-- but the CONFIRMED booking below should remove it from /disponible.
--
-- 2026-11-21 at site 2 is also marked available here,
-- but a HOLD booking should remove it from /disponible.
--
-- Site 4 is MAINTENANCE, so it should never be returned.
-- ------------------------------------------------------------

INSERT INTO site_availability (
    availability_id, site_id, date, available, price, currency
) VALUES
    (1, 1, '2026-11-10', TRUE, 2500.00, 'USD'),
    (2, 1, '2026-11-11', TRUE, 2500.00, 'USD'),
    (3, 1, '2026-11-12', TRUE, 2500.00, 'USD'),
    (4, 1, '2026-11-13', TRUE, 3000.00, 'USD'),
    (5, 1, '2026-11-14', TRUE, 3500.00, 'USD'),
    (6, 1, '2026-11-15', TRUE, 3000.00, 'USD'),
    (7, 1, '2026-11-16', TRUE, 2500.00, 'USD'),
    (8, 1, '2026-11-17', TRUE, 2500.00, 'USD'),
    (9, 1, '2026-11-18', TRUE, 2500.00, 'USD'),
    (10, 1, '2026-11-19', FALSE, NULL, NULL),

    (11, 2, '2026-11-20', TRUE, 1400.00, 'USD'),
    (12, 2, '2026-11-21', TRUE, 1700.00, 'USD'),
    (13, 2, '2026-11-22', TRUE, 1700.00, 'USD'),
    (14, 2, '2026-11-23', TRUE, 1400.00, 'USD'),
    (15, 2, '2026-11-24', TRUE, 1400.00, 'USD'),

    (16, 3, '2026-12-03', TRUE, 1800.00, 'USD'),
    (17, 3, '2026-12-04', TRUE, 1800.00, 'USD'),
    (18, 3, '2026-12-05', TRUE, 2200.00, 'USD'),
    (19, 3, '2026-12-06', TRUE, 2200.00, 'USD'),
    (20, 3, '2026-12-07', TRUE, 1800.00, 'USD'),

    (21, 4, '2026-11-15', TRUE, 1000.00, 'USD');

-- ------------------------------------------------------------
-- EVENT BOOKINGS
-- ------------------------------------------------------------

INSERT INTO event_bookings (
    booking_id, event_id, site_id,
    start_date, end_date, status,
    agreed_price, currency, contract_id, notes
) VALUES
    (1, 1, 1,
     '2026-11-14', '2026-11-14', 'CONFIRMED',
     3500.00, 'USD', 1,
     'Confirmed release-night booking.'),

    (2, 2, 2,
     '2026-11-21', '2026-11-21', 'HOLD',
     1700.00, 'USD', 2,
     'Temporary hold pending final event confirmation.');

-- ------------------------------------------------------------
-- MERCHANDISE
-- ------------------------------------------------------------

INSERT INTO merchandise (
    merchandise_id, artist_id, product_id, name, description,
    merchandise_type, sku, unit_price, currency, status
) VALUES
    (1, 1, 1,
     'The Example Band Tour Shirt',
     'Artist-branded tour shirt produced by ACME.',
     'APPAREL', 'MERCH-TEB-001', 25.00, 'USD', 'ACTIVE'),

    (2, 1, 2,
     'Signed Greatest Hits Poster',
     'Limited promotional poster intended for event promotion.',
     'POSTER', 'MERCH-TEB-002', 15.00, 'USD', 'ACTIVE'),

    (3, 2, 3,
     'Luna Rivera Promotional Mug',
     'Venue and artist co-branded promotional mug.',
     'PROMOTIONAL', 'MERCH-LR-001', 10.00, 'USD', 'ACTIVE');

-- ------------------------------------------------------------
-- ARTIST MERCHANDISE
-- ------------------------------------------------------------

INSERT INTO artist_merchandise (
    artist_id, merchandise_id, authorization_status,
    available_from, available_to
) VALUES
    (1, 1, 'APPROVED', '2026-10-20', '2027-04-30'),
    (1, 2, 'APPROVED', '2026-10-20', '2027-01-31'),
    (2, 3, 'PENDING', '2026-11-01', '2027-02-28');

-- ------------------------------------------------------------
-- EVENT MERCHANDISE
-- ------------------------------------------------------------

INSERT INTO event_merchandise (
    event_id, merchandise_id, quantity,
    unit_price, currency, promotion_type, status
) VALUES
    (1, 1, 250, 25.00, 'USD', 'SALE', 'ORDERED'),
    (1, 2, 100, 0.00, 'USD', 'GIVEAWAY', 'RECEIVED'),
    (3, 3, 150, 10.00, 'USD', 'GIVEAWAY', 'PLANNED');

-- ------------------------------------------------------------
-- MERCHANDISE CONTRACT
-- ------------------------------------------------------------

INSERT INTO merchandise_contracts (
    contract_id, artist_id, merchandise_id, event_id,
    quantity, unit_price, currency, delivery_date
) VALUES
    (5, 1, 2, 1, 100, 8.00, 'USD', '2026-11-10');

-- ------------------------------------------------------------
-- EXTERNAL API SYSTEMS
-- ------------------------------------------------------------

INSERT INTO external_systems (
    system_id, name, base_url, system_type, status
) VALUES
    (1, 'External Discography Provider',
     'https://discography-provider.test/api',
     'DISCOGRAPHY_API', 'ACTIVE'),

    (2, 'External Manufacturing Provider',
     'https://manufacturing-provider.test/api',
     'MANUFACTURING_API', 'ACTIVE'),

    (3, 'External Venue Provider',
     'https://venue-provider.test/api',
     'VENUE_API', 'ACTIVE');

-- ------------------------------------------------------------
-- EXTERNAL RECORD MAPPINGS
-- ------------------------------------------------------------

INSERT INTO external_records (
    external_record_id, system_id, entity_type,
    internal_id, external_id, external_updated_at,
    last_synced_at, sync_status
) VALUES
    (1, 1, 'CONTRACT', 1, 'EXT-DISC-1001',
     '2026-10-18 12:00:00', '2026-10-20 08:00:00', 'SUCCESS'),

    (2, 2, 'CONTRACT', 3, 'EXT-MAN-2001',
     '2026-10-19 09:30:00', '2026-10-20 08:05:00', 'SUCCESS'),

    (3, 3, 'SITE', 1, 'EXT-SITE-GT-001',
     '2026-10-20 07:00:00', '2026-10-20 08:10:00', 'SUCCESS');

-- ------------------------------------------------------------
-- API SYNC LOG
-- ------------------------------------------------------------

INSERT INTO api_sync_log (
    sync_id, system_id, entity_type, entity_id,
    operation, started_at, completed_at,
    status, error_message, records_processed
) VALUES
    (1, 1, 'CONTRACT', 1, 'IMPORT',
     '2026-10-20 08:00:00', '2026-10-20 08:00:02',
     'SUCCESS', NULL, 1),

    (2, 2, 'CONTRACT', 3, 'IMPORT',
     '2026-10-20 08:05:00', '2026-10-20 08:05:03',
     'SUCCESS', NULL, 1),

    (3, 3, 'SITE', 1, 'IMPORT',
     '2026-10-20 08:10:00', '2026-10-20 08:10:01',
     'SUCCESS', NULL, 1);

-- ------------------------------------------------------------
-- RAW EXTERNAL PAYLOADS
-- ------------------------------------------------------------

INSERT INTO api_raw_data (
    raw_data_id, system_id, entity_type,
    external_id, operation, payload, received_at
) VALUES
    (
        1, 1, 'CONTRACT', 'EXT-DISC-1001', 'IMPORT',
        JSON_OBJECT(
            'contract_id', 'EXT-DISC-1001',
            'artist_name', 'The Example Band',
            'album_title', 'Greatest Hits',
            'release_date', '2026-12-05',
            'contract_terms', 'External provider distribution terms.'
        ),
        '2026-10-20 08:00:00'
    ),
    (
        2, 2, 'CONTRACT', 'EXT-MAN-2001', 'IMPORT',
        JSON_OBJECT(
            'contract_id', 'EXT-MAN-2001',
            'manufacturer_name', 'ACME Manufacturing',
            'product_title', 'Tour T-Shirt',
            'release_date', '2026-11-15',
            'contract_terms', 'External provider manufacturing terms.'
        ),
        '2026-10-20 08:05:00'
    ),
    (
        3, 3, 'SITE', 'EXT-SITE-GT-001', 'IMPORT',
        JSON_OBJECT(
            'location_id', 'EXT-SITE-GT-001',
            'location_name', 'Grand Ballroom',
            'date', '2026-11-10',
            'price', 2500.00,
            'currency', 'USD'
        ),
        '2026-10-20 08:10:00'
    );

COMMIT;

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

SELECT 'artists' AS table_name, COUNT(*) AS row_count FROM artists
UNION ALL
SELECT 'albums', COUNT(*) FROM albums
UNION ALL
SELECT 'manufacturers', COUNT(*) FROM manufacturers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'contracts', COUNT(*) FROM contracts
UNION ALL
SELECT 'sites', COUNT(*) FROM sites
UNION ALL
SELECT 'events', COUNT(*) FROM events
UNION ALL
SELECT 'site_availability', COUNT(*) FROM site_availability
UNION ALL
SELECT 'event_bookings', COUNT(*) FROM event_bookings
UNION ALL
SELECT 'merchandise', COUNT(*) FROM merchandise;

SELECT *
FROM v_discography_contract_details
ORDER BY contract_id;

SELECT *
FROM v_manufacturing_contract_details
ORDER BY contract_id;

-- Mirrors GET /disponible for the November test period.
SELECT
    sa.site_id AS location_id,
    s.name AS location_name,
    sa.date,
    sa.price,
    sa.currency
FROM site_availability sa
JOIN sites s
  ON s.site_id = sa.site_id
WHERE sa.available = TRUE
  AND s.status = 'ACTIVE'
  AND sa.date BETWEEN '2026-11-10' AND '2026-11-24'
  AND NOT EXISTS (
      SELECT 1
      FROM event_bookings eb
      WHERE eb.site_id = sa.site_id
        AND eb.status IN ('HOLD', 'CONFIRMED')
        AND sa.date BETWEEN eb.start_date AND eb.end_date
  )
ORDER BY sa.site_id, sa.date;
