-- Event Management Database
-- Target: MySQL 8.0.16+
-- Purpose: Canonical storage for events, sites, contracts, merchandise,
--          and synchronized data from external APIs.

CREATE DATABASE IF NOT EXISTS event_management
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE event_management;

-- ============================================================
-- PARTY DOMAIN
-- ============================================================

CREATE TABLE IF NOT EXISTS parties (
    party_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    party_type ENUM(
        'ARTIST',
        'RECORD_LABEL',
        'MANUFACTURER',
        'ORGANIZER',
        'SPONSOR',
        'SUPPLIER',
        'OTHER'
    ) NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(320) NULL,
    phone VARCHAR(50) NULL,
    website VARCHAR(2048) NULL,
    address VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (party_id),
    INDEX idx_parties_type_name (party_type, name)
) ENGINE=InnoDB
  COMMENT='Canonical person or organization that can participate in events or contracts.';

CREATE TABLE IF NOT EXISTS artists (
    artist_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    party_id BIGINT UNSIGNED NOT NULL,
    stage_name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255) NULL,
    country_code CHAR(2) NULL,
    biography TEXT NULL,
    website VARCHAR(2048) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (artist_id),
    UNIQUE KEY uq_artists_party (party_id),
    CONSTRAINT fk_artists_party
        FOREIGN KEY (party_id) REFERENCES parties(party_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB
  COMMENT='Artist-specific data associated with a party.';

CREATE TABLE IF NOT EXISTS record_labels (
    record_label_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    party_id BIGINT UNSIGNED NOT NULL,
    catalog_prefix VARCHAR(50) NULL,
    website VARCHAR(2048) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (record_label_id),
    UNIQUE KEY uq_record_labels_party (party_id),
    CONSTRAINT fk_record_labels_party
        FOREIGN KEY (party_id) REFERENCES parties(party_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB
  COMMENT='Record-label-specific data associated with a party.';

CREATE TABLE IF NOT EXISTS manufacturers (
    manufacturer_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    party_id BIGINT UNSIGNED NOT NULL,
    manufacturer_type VARCHAR(100) NULL,
    website VARCHAR(2048) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (manufacturer_id),
    UNIQUE KEY uq_manufacturers_party (party_id),
    CONSTRAINT fk_manufacturers_party
        FOREIGN KEY (party_id) REFERENCES parties(party_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB
  COMMENT='Manufacturer-specific data associated with a party.';

-- ============================================================
-- CATALOG DOMAIN
-- ============================================================

CREATE TABLE IF NOT EXISTS albums (
    album_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    artist_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    release_date DATE NULL,
    catalog_number VARCHAR(100) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (album_id),
    UNIQUE KEY uq_albums_catalog_number (catalog_number),
    INDEX idx_albums_artist_title (artist_id, title),
    CONSTRAINT fk_albums_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  COMMENT='Albums or music releases associated with artists.';

CREATE TABLE IF NOT EXISTS products (
    product_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    manufacturer_id BIGINT UNSIGNED NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    sku VARCHAR(100) NULL,
    product_type VARCHAR(100) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id),
    UNIQUE KEY uq_products_sku (sku),
    INDEX idx_products_manufacturer_name (manufacturer_id, product_name),
    CONSTRAINT fk_products_manufacturer
        FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  COMMENT='Products that can be produced by manufacturers and optionally used as merchandise.';

-- ============================================================
-- CONTRACT DOMAIN
-- ============================================================

CREATE TABLE IF NOT EXISTS contracts (
    contract_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    contract_type ENUM(
        'DISCOGRAPHY',
        'MANUFACTURING',
        'MERCHANDISE',
        'OTHER'
    ) NOT NULL,
    status ENUM(
        'DRAFT',
        'ACTIVE',
        'SUSPENDED',
        'EXPIRED',
        'TERMINATED',
        'CANCELLED'
    ) NOT NULL DEFAULT 'DRAFT',
    start_date DATE NULL,
    end_date DATE NULL,
    contract_terms TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (contract_id),
    INDEX idx_contracts_type_status (contract_type, status),
    CONSTRAINT chk_contract_dates
        CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
) ENGINE=InnoDB
  COMMENT='Common contract information shared by all specialized contract types.';

CREATE TABLE IF NOT EXISTS discography_contracts (
    contract_id BIGINT UNSIGNED NOT NULL,
    artist_id BIGINT UNSIGNED NOT NULL,
    record_label_id BIGINT UNSIGNED NULL,
    album_id BIGINT UNSIGNED NOT NULL,
    release_date DATE NOT NULL,
    PRIMARY KEY (contract_id),
    INDEX idx_disc_contract_artist (artist_id),
    INDEX idx_disc_contract_label (record_label_id),
    INDEX idx_disc_contract_album (album_id),
    CONSTRAINT fk_disc_contract_contract
        FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_disc_contract_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_disc_contract_label
        FOREIGN KEY (record_label_id) REFERENCES record_labels(record_label_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_disc_contract_album
        FOREIGN KEY (album_id) REFERENCES albums(album_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  COMMENT='Discography-specific contract data linking a contract to an artist, album, and optional record label.';

CREATE TABLE IF NOT EXISTS manufacturing_contracts (
    contract_id BIGINT UNSIGNED NOT NULL,
    manufacturer_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    release_date DATE NOT NULL,
    PRIMARY KEY (contract_id),
    INDEX idx_man_contract_manufacturer (manufacturer_id),
    INDEX idx_man_contract_product (product_id),
    CONSTRAINT fk_man_contract_contract
        FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_man_contract_manufacturer
        FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_man_contract_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  COMMENT='Manufacturing-specific contract data linking a contract to a manufacturer and product.';

-- ============================================================
-- SITE AND EVENT DOMAIN
-- ============================================================

CREATE TABLE IF NOT EXISTS sites (
    site_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    address VARCHAR(500) NULL,
    city VARCHAR(150) NULL,
    state VARCHAR(150) NULL,
    country VARCHAR(150) NULL,
    postal_code VARCHAR(30) NULL,
    latitude DECIMAL(9,6) NULL,
    longitude DECIMAL(9,6) NULL,
    capacity INT UNSIGNED NULL,
    site_type VARCHAR(100) NULL,
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (site_id),
    INDEX idx_sites_name (name),
    INDEX idx_sites_location (country, state, city),
    CONSTRAINT chk_sites_latitude
        CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_sites_longitude
        CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
) ENGINE=InnoDB
  COMMENT='Physical event locations or venues managed by the system.';

CREATE TABLE IF NOT EXISTS events (
    event_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    event_type VARCHAR(100) NULL,
    status ENUM('PLANNED', 'CONFIRMED', 'CANCELLED', 'COMPLETED')
        NOT NULL DEFAULT 'PLANNED',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id),
    INDEX idx_events_dates (start_date, end_date),
    INDEX idx_events_status (status),
    CONSTRAINT chk_event_dates
        CHECK (end_date >= start_date)
) ENGINE=InnoDB
  COMMENT='Events organized or tracked by the system.';

CREATE TABLE IF NOT EXISTS event_sites (
    event_id BIGINT UNSIGNED NOT NULL,
    site_id BIGINT UNSIGNED NOT NULL,
    role VARCHAR(100) NOT NULL DEFAULT 'MAIN',
    PRIMARY KEY (event_id, site_id),
    INDEX idx_event_sites_site (site_id),
    CONSTRAINT fk_event_sites_event
        FOREIGN KEY (event_id) REFERENCES events(event_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_event_sites_site
        FOREIGN KEY (site_id) REFERENCES sites(site_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  COMMENT='Many-to-many association between events and the sites used by each event.';

CREATE TABLE IF NOT EXISTS event_participants (
    event_participant_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_id BIGINT UNSIGNED NOT NULL,
    party_id BIGINT UNSIGNED NOT NULL,
    role VARCHAR(100) NOT NULL,
    status ENUM('INVITED', 'CONFIRMED', 'DECLINED', 'CANCELLED')
        NOT NULL DEFAULT 'INVITED',
    notes TEXT NULL,
    PRIMARY KEY (event_participant_id),
    UNIQUE KEY uq_event_participant_role (event_id, party_id, role),
    INDEX idx_event_participants_party (party_id),
    CONSTRAINT fk_event_participant_event
        FOREIGN KEY (event_id) REFERENCES events(event_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_event_participant_party
        FOREIGN KEY (party_id) REFERENCES parties(party_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  COMMENT='Artists, manufacturers, labels, organizers, sponsors, or other parties participating in an event.';

CREATE TABLE IF NOT EXISTS site_availability (
    availability_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    site_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    available BOOLEAN NOT NULL DEFAULT TRUE,
    price DECIMAL(12,2) NULL,
    currency CHAR(3) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (availability_id),
    UNIQUE KEY uq_site_availability_date (site_id, date),
    INDEX idx_site_availability_search (date, available, site_id),
    CONSTRAINT fk_site_availability_site
        FOREIGN KEY (site_id) REFERENCES sites(site_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_site_availability_price
        CHECK (price IS NULL OR price >= 0),
    CONSTRAINT chk_site_availability_priced_date
        CHECK (available = FALSE OR (price IS NOT NULL AND currency IS NOT NULL))
) ENGINE=InnoDB
  COMMENT='Per-day site availability and daily price used by the availability API.';

CREATE TABLE IF NOT EXISTS event_bookings (
    booking_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_id BIGINT UNSIGNED NOT NULL,
    site_id BIGINT UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('HOLD', 'CONFIRMED', 'CANCELLED', 'COMPLETED')
        NOT NULL DEFAULT 'HOLD',
    agreed_price DECIMAL(12,2) NULL,
    currency CHAR(3) NULL,
    contract_id BIGINT UNSIGNED NULL,
    notes TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id),
    INDEX idx_event_bookings_site_dates (site_id, start_date, end_date, status),
    INDEX idx_event_bookings_event (event_id),
    INDEX idx_event_bookings_contract (contract_id),
    CONSTRAINT fk_event_booking_event_site
        FOREIGN KEY (event_id, site_id)
        REFERENCES event_sites(event_id, site_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_event_booking_contract
        FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_event_booking_dates
        CHECK (end_date >= start_date),
    CONSTRAINT chk_event_booking_price
        CHECK (agreed_price IS NULL OR agreed_price >= 0),
    CONSTRAINT chk_event_booking_currency
        CHECK (agreed_price IS NULL OR currency IS NOT NULL)
) ENGINE=InnoDB
  COMMENT='Actual reservations of sites for events; kept separate from advertised site availability.';

-- ============================================================
-- MERCHANDISE DOMAIN
-- ============================================================

CREATE TABLE IF NOT EXISTS merchandise (
    merchandise_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    artist_id BIGINT UNSIGNED NULL,
    product_id BIGINT UNSIGNED NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    merchandise_type VARCHAR(100) NULL,
    sku VARCHAR(100) NULL,
    unit_price DECIMAL(12,2) NULL,
    currency CHAR(3) NULL,
    status ENUM('ACTIVE', 'INACTIVE', 'DISCONTINUED')
        NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (merchandise_id),
    UNIQUE KEY uq_merchandise_sku (sku),
    INDEX idx_merchandise_artist (artist_id),
    INDEX idx_merchandise_product (product_id),
    CONSTRAINT fk_merchandise_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_merchandise_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_merchandise_price
        CHECK (unit_price IS NULL OR unit_price >= 0),
    CONSTRAINT chk_merchandise_currency
        CHECK (unit_price IS NULL OR currency IS NOT NULL)
) ENGINE=InnoDB
  COMMENT='Merchandise that may be associated with an artist, a manufactured product, or both.';

CREATE TABLE IF NOT EXISTS artist_merchandise (
    artist_id BIGINT UNSIGNED NOT NULL,
    merchandise_id BIGINT UNSIGNED NOT NULL,
    authorization_status ENUM('PENDING', 'APPROVED', 'REJECTED', 'EXPIRED')
        NOT NULL DEFAULT 'PENDING',
    available_from DATE NULL,
    available_to DATE NULL,
    PRIMARY KEY (artist_id, merchandise_id),
    CONSTRAINT fk_artist_merch_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_artist_merch_merch
        FOREIGN KEY (merchandise_id) REFERENCES merchandise(merchandise_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_artist_merch_dates
        CHECK (
            available_to IS NULL
            OR available_from IS NULL
            OR available_to >= available_from
        )
) ENGINE=InnoDB
  COMMENT='Authorization and availability relationship between artists and merchandise.';

CREATE TABLE IF NOT EXISTS event_merchandise (
    event_id BIGINT UNSIGNED NOT NULL,
    merchandise_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 0,
    unit_price DECIMAL(12,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    promotion_type VARCHAR(100) NULL,
    status ENUM(
        'PLANNED',
        'ORDERED',
        'RECEIVED',
        'DISTRIBUTING',
        'COMPLETED',
        'CANCELLED'
    ) NOT NULL DEFAULT 'PLANNED',
    PRIMARY KEY (event_id, merchandise_id),
    CONSTRAINT fk_event_merch_event
        FOREIGN KEY (event_id) REFERENCES events(event_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_event_merch_merch
        FOREIGN KEY (merchandise_id) REFERENCES merchandise(merchandise_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_event_merch_price
        CHECK (unit_price >= 0)
) ENGINE=InnoDB
  COMMENT='Merchandise quantities, pricing, and promotional use for a specific event.';

CREATE TABLE IF NOT EXISTS merchandise_contracts (
    contract_id BIGINT UNSIGNED NOT NULL,
    artist_id BIGINT UNSIGNED NOT NULL,
    merchandise_id BIGINT UNSIGNED NOT NULL,
    event_id BIGINT UNSIGNED NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    delivery_date DATE NULL,
    PRIMARY KEY (contract_id),
    INDEX idx_merch_contract_artist (artist_id),
    INDEX idx_merch_contract_merch (merchandise_id),
    INDEX idx_merch_contract_event (event_id),
    CONSTRAINT fk_merch_contract_contract
        FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_merch_contract_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_merch_contract_merch
        FOREIGN KEY (merchandise_id) REFERENCES merchandise(merchandise_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_merch_contract_event
        FOREIGN KEY (event_id) REFERENCES events(event_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_merch_contract_quantity
        CHECK (quantity > 0),
    CONSTRAINT chk_merch_contract_price
        CHECK (unit_price >= 0)
) ENGINE=InnoDB
  COMMENT='Contracts granting or acquiring merchandise for an artist and optionally a specific event.';

-- ============================================================
-- EXTERNAL API / INTEGRATION DOMAIN
-- ============================================================

CREATE TABLE IF NOT EXISTS external_systems (
    system_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    base_url VARCHAR(2048) NULL,
    system_type VARCHAR(100) NULL,
    status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (system_id),
    UNIQUE KEY uq_external_system_name (name)
) ENGINE=InnoDB
  COMMENT='External APIs or systems from which canonical data may be imported or synchronized.';

CREATE TABLE IF NOT EXISTS external_records (
    external_record_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    system_id BIGINT UNSIGNED NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    internal_id BIGINT UNSIGNED NOT NULL,
    external_id VARCHAR(255) NOT NULL,
    external_updated_at DATETIME NULL,
    last_synced_at DATETIME NULL,
    sync_status ENUM('PENDING', 'SUCCESS', 'FAILED', 'SKIPPED')
        NOT NULL DEFAULT 'PENDING',
    PRIMARY KEY (external_record_id),
    UNIQUE KEY uq_external_record_external (
        system_id, entity_type, external_id
    ),
    UNIQUE KEY uq_external_record_internal (
        system_id, entity_type, internal_id
    ),
    INDEX idx_external_records_internal (entity_type, internal_id),
    CONSTRAINT fk_external_records_system
        FOREIGN KEY (system_id) REFERENCES external_systems(system_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB
  COMMENT='Maps canonical internal entity IDs to identifiers used by external systems.';

CREATE TABLE IF NOT EXISTS api_sync_log (
    sync_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    system_id BIGINT UNSIGNED NOT NULL,
    entity_type VARCHAR(100) NULL,
    entity_id BIGINT UNSIGNED NULL,
    operation ENUM('IMPORT', 'EXPORT', 'CREATE', 'UPDATE', 'DELETE') NOT NULL,
    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED', 'PARTIAL') NOT NULL DEFAULT 'PENDING',
    error_message TEXT NULL,
    records_processed INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (sync_id),
    INDEX idx_api_sync_log_system_date (system_id, started_at),
    INDEX idx_api_sync_log_entity (entity_type, entity_id),
    CONSTRAINT fk_api_sync_log_system
        FOREIGN KEY (system_id) REFERENCES external_systems(system_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  COMMENT='Audit log for imports, exports, and synchronization operations with external APIs.';

CREATE TABLE IF NOT EXISTS api_raw_data (
    raw_data_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    system_id BIGINT UNSIGNED NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    external_id VARCHAR(255) NULL,
    operation ENUM('IMPORT', 'EXPORT', 'CREATE', 'UPDATE', 'DELETE') NOT NULL,
    payload JSON NOT NULL,
    received_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (raw_data_id),
    INDEX idx_api_raw_system_entity (system_id, entity_type, external_id),
    INDEX idx_api_raw_received (received_at),
    CONSTRAINT fk_api_raw_system
        FOREIGN KEY (system_id) REFERENCES external_systems(system_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  COMMENT='Original JSON payloads received from or sent to external APIs for traceability and reprocessing.';

-- ============================================================
-- CROSS-TABLE BUSINESS CONSISTENCY TRIGGERS
-- ============================================================

DELIMITER $$

DROP TRIGGER IF EXISTS bi_discography_contracts $$
CREATE TRIGGER bi_discography_contracts
BEFORE INSERT ON discography_contracts
FOR EACH ROW
BEGIN
    DECLARE v_contract_type VARCHAR(30);
    DECLARE v_album_artist BIGINT UNSIGNED;

    SELECT contract_type
      INTO v_contract_type
      FROM contracts
     WHERE contract_id = NEW.contract_id;

    IF v_contract_type <> 'DISCOGRAPHY' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contract type must be DISCOGRAPHY.';
    END IF;

    SELECT artist_id
      INTO v_album_artist
      FROM albums
     WHERE album_id = NEW.album_id;

    IF v_album_artist <> NEW.artist_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The selected album does not belong to the selected artist.';
    END IF;
END $$

DROP TRIGGER IF EXISTS bu_discography_contracts $$
CREATE TRIGGER bu_discography_contracts
BEFORE UPDATE ON discography_contracts
FOR EACH ROW
BEGIN
    DECLARE v_contract_type VARCHAR(30);
    DECLARE v_album_artist BIGINT UNSIGNED;

    SELECT contract_type
      INTO v_contract_type
      FROM contracts
     WHERE contract_id = NEW.contract_id;

    IF v_contract_type <> 'DISCOGRAPHY' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contract type must be DISCOGRAPHY.';
    END IF;

    SELECT artist_id
      INTO v_album_artist
      FROM albums
     WHERE album_id = NEW.album_id;

    IF v_album_artist <> NEW.artist_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The selected album does not belong to the selected artist.';
    END IF;
END $$

DROP TRIGGER IF EXISTS bi_manufacturing_contracts $$
CREATE TRIGGER bi_manufacturing_contracts
BEFORE INSERT ON manufacturing_contracts
FOR EACH ROW
BEGIN
    DECLARE v_contract_type VARCHAR(30);
    DECLARE v_product_manufacturer BIGINT UNSIGNED;

    SELECT contract_type
      INTO v_contract_type
      FROM contracts
     WHERE contract_id = NEW.contract_id;

    IF v_contract_type <> 'MANUFACTURING' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contract type must be MANUFACTURING.';
    END IF;

    SELECT manufacturer_id
      INTO v_product_manufacturer
      FROM products
     WHERE product_id = NEW.product_id;

    IF v_product_manufacturer <> NEW.manufacturer_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The selected product does not belong to the selected manufacturer.';
    END IF;
END $$

DROP TRIGGER IF EXISTS bu_manufacturing_contracts $$
CREATE TRIGGER bu_manufacturing_contracts
BEFORE UPDATE ON manufacturing_contracts
FOR EACH ROW
BEGIN
    DECLARE v_contract_type VARCHAR(30);
    DECLARE v_product_manufacturer BIGINT UNSIGNED;

    SELECT contract_type
      INTO v_contract_type
      FROM contracts
     WHERE contract_id = NEW.contract_id;

    IF v_contract_type <> 'MANUFACTURING' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contract type must be MANUFACTURING.';
    END IF;

    SELECT manufacturer_id
      INTO v_product_manufacturer
      FROM products
     WHERE product_id = NEW.product_id;

    IF v_product_manufacturer <> NEW.manufacturer_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The selected product does not belong to the selected manufacturer.';
    END IF;
END $$

DROP TRIGGER IF EXISTS bi_merchandise_contracts $$
CREATE TRIGGER bi_merchandise_contracts
BEFORE INSERT ON merchandise_contracts
FOR EACH ROW
BEGIN
    DECLARE v_contract_type VARCHAR(30);

    SELECT contract_type
      INTO v_contract_type
      FROM contracts
     WHERE contract_id = NEW.contract_id;

    IF v_contract_type <> 'MERCHANDISE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contract type must be MERCHANDISE.';
    END IF;
END $$

DROP TRIGGER IF EXISTS bu_merchandise_contracts $$
CREATE TRIGGER bu_merchandise_contracts
BEFORE UPDATE ON merchandise_contracts
FOR EACH ROW
BEGIN
    DECLARE v_contract_type VARCHAR(30);

    SELECT contract_type
      INTO v_contract_type
      FROM contracts
     WHERE contract_id = NEW.contract_id;

    IF v_contract_type <> 'MERCHANDISE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contract type must be MERCHANDISE.';
    END IF;
END $$

DROP TRIGGER IF EXISTS bi_event_bookings_no_overlap $$
CREATE TRIGGER bi_event_bookings_no_overlap
BEFORE INSERT ON event_bookings
FOR EACH ROW
BEGIN
    IF NEW.status IN ('HOLD', 'CONFIRMED')
       AND EXISTS (
            SELECT 1
              FROM event_bookings eb
             WHERE eb.site_id = NEW.site_id
               AND eb.status IN ('HOLD', 'CONFIRMED')
               AND NEW.start_date <= eb.end_date
               AND NEW.end_date >= eb.start_date
       )
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The site already has an overlapping active booking.';
    END IF;
END $$

DROP TRIGGER IF EXISTS bu_event_bookings_no_overlap $$
CREATE TRIGGER bu_event_bookings_no_overlap
BEFORE UPDATE ON event_bookings
FOR EACH ROW
BEGIN
    IF NEW.status IN ('HOLD', 'CONFIRMED')
       AND EXISTS (
            SELECT 1
              FROM event_bookings eb
             WHERE eb.site_id = NEW.site_id
               AND eb.booking_id <> NEW.booking_id
               AND eb.status IN ('HOLD', 'CONFIRMED')
               AND NEW.start_date <= eb.end_date
               AND NEW.end_date >= eb.start_date
       )
    THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The site already has an overlapping active booking.';
    END IF;
END $$

DELIMITER ;

-- ============================================================
-- API-FRIENDLY VIEWS
-- ============================================================

CREATE OR REPLACE VIEW v_discography_contract_details AS
SELECT
    c.contract_id,
    c.contract_type,
    c.status,
    c.start_date,
    c.end_date,
    c.contract_terms,
    dc.release_date,
    dc.artist_id,
    a.stage_name AS artist_name,
    dc.album_id,
    al.title AS album_title,
    dc.record_label_id,
    p.name AS record_label_name,
    c.created_at,
    c.updated_at
FROM contracts c
JOIN discography_contracts dc
  ON dc.contract_id = c.contract_id
JOIN artists a
  ON a.artist_id = dc.artist_id
JOIN albums al
  ON al.album_id = dc.album_id
LEFT JOIN record_labels rl
  ON rl.record_label_id = dc.record_label_id
LEFT JOIN parties p
  ON p.party_id = rl.party_id;

CREATE OR REPLACE VIEW v_manufacturing_contract_details AS
SELECT
    c.contract_id,
    c.contract_type,
    c.status,
    c.start_date,
    c.end_date,
    c.contract_terms,
    mc.release_date,
    mc.manufacturer_id,
    mp.name AS manufacturer_name,
    mc.product_id,
    pr.product_name AS product_title,
    c.created_at,
    c.updated_at
FROM contracts c
JOIN manufacturing_contracts mc
  ON mc.contract_id = c.contract_id
JOIN manufacturers m
  ON m.manufacturer_id = mc.manufacturer_id
JOIN parties mp
  ON mp.party_id = m.party_id
JOIN products pr
  ON pr.product_id = mc.product_id;

CREATE OR REPLACE VIEW v_site_available_dates AS
SELECT
    sa.availability_id,
    sa.site_id,
    s.name AS location_name,
    sa.date,
    sa.price,
    sa.currency
FROM site_availability sa
JOIN sites s
  ON s.site_id = sa.site_id
WHERE sa.available = TRUE
  AND s.status = 'ACTIVE'
  AND NOT EXISTS (
      SELECT 1
      FROM event_bookings eb
      WHERE eb.site_id = sa.site_id
        AND eb.status IN ('HOLD', 'CONFIRMED')
        AND sa.date BETWEEN eb.start_date AND eb.end_date
  );
