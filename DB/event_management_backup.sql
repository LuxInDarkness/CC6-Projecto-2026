-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: event_management
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `event_management`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `event_management` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `event_management`;

--
-- Table structure for table `albums`
--

DROP TABLE IF EXISTS `albums`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `albums` (
  `album_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(15) NOT NULL,
  `artist_id` bigint unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `release_date` date DEFAULT NULL,
  `catalog_number` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`album_id`),
  UNIQUE KEY `uq_albums_external_id` (`external_id`),
  UNIQUE KEY `uq_albums_catalog_number` (`catalog_number`),
  KEY `idx_albums_artist_title` (`artist_id`,`title`),
  CONSTRAINT `fk_albums_artist` FOREIGN KEY (`artist_id`) REFERENCES `artists` (`artist_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_albums_external_id` CHECK (regexp_like(`external_id`,_utf8mb4'^ALB[0-9]{12}$'))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Albums or music releases associated with artists.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `albums`
--

LOCK TABLES `albums` WRITE;
/*!40000 ALTER TABLE `albums` DISABLE KEYS */;
INSERT INTO `albums` VALUES (1,'ALB202610200001',1,'Greatest Hits','2026-12-05','EXR-2026-001','2026-10-21 00:54:01','2026-11-15 04:40:47'),(2,'ALB202610200002',1,'Night Drive','2027-03-15','EXR-2027-002','2026-10-21 00:54:01','2026-11-15 04:40:47'),(3,'ALB202610200003',2,'Luz de Ciudad','2026-11-20','AMG-2026-010','2026-10-21 00:54:01','2026-11-15 04:40:47'),(4,'ALB202611150001',3,'Example Album','2027-01-20','KNG-0042','2026-11-16 04:11:31','2026-11-16 04:11:31'),(5,'ALB202611150002',5,'Ghost Stories','2014-05-16',NULL,'2026-11-16 04:56:22','2026-11-16 04:56:22'),(6,'ALB202611150003',6,'Madrugada','2024-03-15',NULL,'2026-11-16 05:19:09','2026-11-16 05:19:09'),(7,'ALB202611160001',7,'Test Album','2027-03-20','TEST-001','2026-11-17 00:48:10','2026-11-17 00:48:10');
/*!40000 ALTER TABLE `albums` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_albums_external_id` BEFORE INSERT ON `albums` FOR EACH ROW BEGIN
    DECLARE v_external_id VARCHAR(15);

    IF NEW.external_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'albums.external_id is generated automatically.';
    END IF;

    CALL generate_entity_external_id('ALB', v_external_id);
    SET NEW.external_id = v_external_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_albums_external_id` BEFORE UPDATE ON `albums` FOR EACH ROW BEGIN
    IF NOT (NEW.external_id <=> OLD.external_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'albums.external_id cannot be changed.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `api_raw_data`
--

DROP TABLE IF EXISTS `api_raw_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_raw_data` (
  `raw_data_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `system_id` bigint unsigned NOT NULL,
  `entity_type` varchar(100) NOT NULL,
  `external_id` varchar(255) DEFAULT NULL,
  `operation` enum('IMPORT','EXPORT','CREATE','UPDATE','DELETE') NOT NULL,
  `payload` json NOT NULL,
  `received_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`raw_data_id`),
  KEY `idx_api_raw_system_entity` (`system_id`,`entity_type`,`external_id`),
  KEY `idx_api_raw_received` (`received_at`),
  CONSTRAINT `fk_api_raw_system` FOREIGN KEY (`system_id`) REFERENCES `external_systems` (`system_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Original JSON payloads received from or sent to external APIs for traceability and reprocessing.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_raw_data`
--

LOCK TABLES `api_raw_data` WRITE;
/*!40000 ALTER TABLE `api_raw_data` DISABLE KEYS */;
INSERT INTO `api_raw_data` VALUES (1,1,'CONTRACT','EXT-DISC-1001','IMPORT','{\"album_title\": \"Greatest Hits\", \"artist_name\": \"The Example Band\", \"contract_id\": \"EXT-DISC-1001\", \"release_date\": \"2026-12-05\", \"contract_terms\": \"External provider distribution terms.\"}','2026-10-20 14:00:00'),(2,2,'CONTRACT','EXT-MAN-2001','IMPORT','{\"contract_id\": \"EXT-MAN-2001\", \"release_date\": \"2026-11-15\", \"product_title\": \"Tour T-Shirt\", \"contract_terms\": \"External provider manufacturing terms.\", \"manufacturer_name\": \"ACME Manufacturing\"}','2026-10-20 14:05:00'),(3,3,'SITE','EXT-SITE-GT-001','IMPORT','{\"date\": \"2026-11-10\", \"price\": 2500.00, \"currency\": \"USD\", \"location_id\": \"EXT-SITE-GT-001\", \"location_name\": \"Grand Ballroom\"}','2026-10-20 14:10:00'),(4,8,'ARTIST_AVAILABILITY',NULL,'IMPORT','{\"data\": {\"artists\": [{\"id_artist\": \"KNG1\", \"main_genre\": \"Pop\", \"artist_name\": \"Madonna\", \"record_label\": \"King Label\", \"available_dates\": [\"16-11-2026\", \"17-11-2026\", \"18-11-2026\"]}, {\"id_artist\": \"KNG3\", \"main_genre\": \"Rock\", \"artist_name\": \"Coldplay\", \"record_label\": \"King Label\", \"available_dates\": [\"16-11-2026\", \"17-11-2026\", \"18-11-2026\"]}, {\"id_artist\": \"KNG5\", \"main_genre\": \"Rock\", \"artist_name\": \"Soda Stereo\", \"record_label\": \"King Label\", \"available_dates\": [\"16-11-2026\", \"17-11-2026\", \"18-11-2026\"]}, {\"id_artist\": \"KNG6\", \"main_genre\": \"Rock\", \"artist_name\": \"Nirvana\", \"record_label\": \"King Label\", \"available_dates\": [\"16-11-2026\", \"17-11-2026\", \"18-11-2026\"]}, {\"id_artist\": \"KNG8\", \"main_genre\": \"Electronic\", \"artist_name\": \"Tiësto\", \"record_label\": \"King Label\", \"available_dates\": [\"16-11-2026\", \"17-11-2026\", \"18-11-2026\"]}, {\"id_artist\": \"KNG10\", \"main_genre\": \"Latin\", \"artist_name\": \"Shakira\", \"record_label\": \"King Label\", \"available_dates\": [\"16-11-2026\", \"17-11-2026\", \"18-11-2026\"]}, {\"id_artist\": \"KNG11\", \"main_genre\": \"Rock\", \"artist_name\": \"Maná\", \"record_label\": \"King Label\", \"available_dates\": [\"16-11-2026\", \"17-11-2026\", \"18-11-2026\"]}, {\"id_artist\": \"KNG13\", \"main_genre\": \"Unknown\", \"artist_name\": \"Avatar\", \"record_label\": \"King Label\", \"available_dates\": [\"16-11-2026\", \"17-11-2026\"]}, {\"id_artist\": \"KNG12\", \"main_genre\": \"Latin\", \"artist_name\": \"Aventura\", \"record_label\": \"King Label\", \"available_dates\": [\"16-11-2026\", \"17-11-2026\", \"18-11-2026\"]}, {\"id_artist\": \"EMP1\", \"main_genre\": \"Rock\", \"artist_name\": \"Luna Roja\", \"record_label\": \"EMP Records Intl\", \"available_dates\": [\"16-11-2026\", \"17-11-2026\", \"18-11-2026\"]}, {\"id_artist\": \"EMP2\", \"main_genre\": \"Cumbia\", \"artist_name\": \"Los Vecinos\", \"record_label\": \"EMP Records Intl\", \"available_dates\": [\"16-11-2026\", \"17-11-2026\", \"18-11-2026\"]}]}, \"status\": \"success\", \"message\": \"Artist availability retrieved successfully.\"}','2026-11-17 03:08:14');
/*!40000 ALTER TABLE `api_raw_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_sync_log`
--

DROP TABLE IF EXISTS `api_sync_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_sync_log` (
  `sync_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `system_id` bigint unsigned NOT NULL,
  `entity_type` varchar(100) DEFAULT NULL,
  `entity_id` bigint unsigned DEFAULT NULL,
  `operation` enum('IMPORT','EXPORT','CREATE','UPDATE','DELETE') NOT NULL,
  `started_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` datetime DEFAULT NULL,
  `status` enum('PENDING','SUCCESS','FAILED','PARTIAL') NOT NULL DEFAULT 'PENDING',
  `error_message` text,
  `records_processed` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`sync_id`),
  KEY `idx_api_sync_log_system_date` (`system_id`,`started_at`),
  KEY `idx_api_sync_log_entity` (`entity_type`,`entity_id`),
  CONSTRAINT `fk_api_sync_log_system` FOREIGN KEY (`system_id`) REFERENCES `external_systems` (`system_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Audit log for imports, exports, and synchronization operations with external APIs.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_sync_log`
--

LOCK TABLES `api_sync_log` WRITE;
/*!40000 ALTER TABLE `api_sync_log` DISABLE KEYS */;
INSERT INTO `api_sync_log` VALUES (1,1,'CONTRACT',1,'IMPORT','2026-10-20 08:00:00','2026-10-20 08:00:02','SUCCESS',NULL,1),(2,2,'CONTRACT',3,'IMPORT','2026-10-20 08:05:00','2026-10-20 08:05:03','SUCCESS',NULL,1),(3,3,'SITE',1,'IMPORT','2026-10-20 08:10:00','2026-10-20 08:10:01','SUCCESS',NULL,1),(4,8,'ARTIST_AVAILABILITY',NULL,'IMPORT','2026-11-16 21:08:13','2026-11-16 21:08:14','SUCCESS',NULL,11),(5,8,'ARTIST_AVAILABILITY',NULL,'IMPORT','2026-11-16 23:25:12','2026-11-16 23:25:17','FAILED','HTTPConnectionPool(host=\'100.103.44.86\', port=4000): Max retries exceeded with url: /api/artists/availability?start_date=16-11-2026&end_date=18-11-2026 (Caused by ConnectTimeoutError(<HTTPConnection(host=\'100.103.44.86\', port=4000) at 0x1851ef51be0>, \'Connection to 100.103.44.86 timed out. (connect timeout=5.0)\'))',0);
/*!40000 ALTER TABLE `api_sync_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `artist_merchandise`
--

DROP TABLE IF EXISTS `artist_merchandise`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `artist_merchandise` (
  `artist_id` bigint unsigned NOT NULL,
  `merchandise_id` bigint unsigned NOT NULL,
  `authorization_status` enum('PENDING','APPROVED','REJECTED','EXPIRED') NOT NULL DEFAULT 'PENDING',
  `available_from` date DEFAULT NULL,
  `available_to` date DEFAULT NULL,
  PRIMARY KEY (`artist_id`,`merchandise_id`),
  KEY `fk_artist_merch_merch` (`merchandise_id`),
  CONSTRAINT `fk_artist_merch_artist` FOREIGN KEY (`artist_id`) REFERENCES `artists` (`artist_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_artist_merch_merch` FOREIGN KEY (`merchandise_id`) REFERENCES `merchandise` (`merchandise_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_artist_merch_dates` CHECK (((`available_to` is null) or (`available_from` is null) or (`available_to` >= `available_from`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Authorization and availability relationship between artists and merchandise.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `artist_merchandise`
--

LOCK TABLES `artist_merchandise` WRITE;
/*!40000 ALTER TABLE `artist_merchandise` DISABLE KEYS */;
INSERT INTO `artist_merchandise` VALUES (1,1,'APPROVED','2026-10-20','2027-04-30'),(1,2,'APPROVED','2026-10-20','2027-01-31'),(2,3,'PENDING','2026-11-01','2027-02-28');
/*!40000 ALTER TABLE `artist_merchandise` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `artists`
--

DROP TABLE IF EXISTS `artists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `artists` (
  `artist_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(15) NOT NULL,
  `party_id` bigint unsigned NOT NULL,
  `stage_name` varchar(255) NOT NULL,
  `legal_name` varchar(255) DEFAULT NULL,
  `country_code` char(2) DEFAULT NULL,
  `biography` text,
  `website` varchar(2048) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`artist_id`),
  UNIQUE KEY `uq_artists_party` (`party_id`),
  UNIQUE KEY `uq_artists_external_id` (`external_id`),
  CONSTRAINT `fk_artists_party` FOREIGN KEY (`party_id`) REFERENCES `parties` (`party_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_artists_external_id` CHECK (regexp_like(`external_id`,_utf8mb4'^ART[0-9]{12}$'))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Artist-specific data associated with a party.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `artists`
--

LOCK TABLES `artists` WRITE;
/*!40000 ALTER TABLE `artists` DISABLE KEYS */;
INSERT INTO `artists` VALUES (1,'ART202610200001',1,'The Example Band',NULL,'US','Independent alternative rock band used for API testing.','https://exampleband.test','2026-10-21 00:54:01','2026-11-15 04:40:47'),(2,'ART202610200002',2,'Luna Rivera','Luna Isabel Rivera','GT','Guatemalan solo artist used for API and event testing.','https://lunarivera.test','2026-10-21 00:54:01','2026-11-15 04:40:47'),(3,'ART202611150001',9,'Madonna',NULL,'UB',NULL,NULL,'2026-11-16 04:09:42','2026-11-16 04:10:39'),(4,'ART202611150002',10,'Shakira',NULL,'C1',NULL,NULL,'2026-11-16 04:09:42','2026-11-16 04:10:39'),(5,'ART202611150003',13,'Coldplay',NULL,NULL,NULL,NULL,'2026-11-16 04:56:01','2026-11-16 04:56:01'),(6,'ART202611150004',14,'Luna Roja',NULL,NULL,NULL,NULL,'2026-11-16 05:19:08','2026-11-16 05:19:09'),(7,'ART202611160001',15,'Test Artist','Artist Legal Name','GT','Updated biography.',NULL,'2026-11-17 00:46:06','2026-11-17 00:47:27');
/*!40000 ALTER TABLE `artists` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_artists_external_id` BEFORE INSERT ON `artists` FOR EACH ROW BEGIN
    DECLARE v_external_id VARCHAR(15);

    IF NEW.external_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'artists.external_id is generated automatically.';
    END IF;

    CALL generate_entity_external_id('ART', v_external_id);
    SET NEW.external_id = v_external_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_artists_external_id` BEFORE UPDATE ON `artists` FOR EACH ROW BEGIN
    IF NOT (NEW.external_id <=> OLD.external_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'artists.external_id cannot be changed.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add user',4,'add_user'),(14,'Can change user',4,'change_user'),(15,'Can delete user',4,'delete_user'),(16,'Can view user',4,'view_user'),(17,'Can add content type',5,'add_contenttype'),(18,'Can change content type',5,'change_contenttype'),(19,'Can delete content type',5,'delete_contenttype'),(20,'Can view content type',5,'view_contenttype'),(21,'Can add session',6,'add_session'),(22,'Can change session',6,'change_session'),(23,'Can delete session',6,'delete_session'),(24,'Can view session',6,'view_session');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$1000000$SjaFPAffUcckWZ3uGz38c6$zLcR5nbr7af1On60+ZuFhjhOf6mlsC3gz6gWw7HW9dk=','2026-11-16 21:30:40.383639',1,'michael','','','michael.barillas@galileo.edu',1,1,'2026-11-16 00:06:06.264289');
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`),
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contract_external_id_sequences`
--

DROP TABLE IF EXISTS `contract_external_id_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contract_external_id_sequences` (
  `prefix` char(3) NOT NULL,
  `sequence_date` date NOT NULL,
  `last_number` smallint unsigned NOT NULL,
  PRIMARY KEY (`prefix`,`sequence_date`),
  CONSTRAINT `chk_contract_external_id_prefix` CHECK ((`prefix` in (_utf8mb4'MAN',_utf8mb4'DIS'))),
  CONSTRAINT `chk_contract_external_id_sequence` CHECK ((`last_number` >= 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Tracks the per-day sequence used to generate 15-character public contract IDs.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contract_external_id_sequences`
--

LOCK TABLES `contract_external_id_sequences` WRITE;
/*!40000 ALTER TABLE `contract_external_id_sequences` DISABLE KEYS */;
INSERT INTO `contract_external_id_sequences` VALUES ('DIS','2026-10-20',2),('MAN','2026-10-20',2);
/*!40000 ALTER TABLE `contract_external_id_sequences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contracts`
--

DROP TABLE IF EXISTS `contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contracts` (
  `contract_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(15) NOT NULL,
  `contract_type` enum('DISCOGRAPHY','MANUFACTURING','MERCHANDISE','OTHER') NOT NULL,
  `status` enum('DRAFT','PENDING','APPROVED','REJECTED','CANCELLED','FINISHED') NOT NULL DEFAULT 'DRAFT',
  `site_id` bigint unsigned NOT NULL,
  `event_id` bigint unsigned NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `contract_terms` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`contract_id`),
  UNIQUE KEY `uq_contracts_external_id` (`external_id`),
  KEY `idx_contracts_type_status` (`contract_type`,`status`),
  KEY `idx_contracts_site` (`site_id`),
  KEY `idx_contracts_event` (`event_id`),
  KEY `fk_contracts_event_site` (`event_id`,`site_id`),
  CONSTRAINT `fk_contracts_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_contracts_event_site` FOREIGN KEY (`event_id`, `site_id`) REFERENCES `event_sites` (`event_id`, `site_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_contract_dates` CHECK (((`end_date` is null) or (`start_date` is null) or (`end_date` >= `start_date`))),
  CONSTRAINT `chk_contracts_external_id_format` CHECK (regexp_like(`external_id`,_utf8mb4'^(DIS|MAN|MCT|OTH)[0-9]{12}$')),
  CONSTRAINT `chk_contracts_external_id_type` CHECK ((((`contract_type` = _utf8mb4'DISCOGRAPHY') and (`external_id` like _utf8mb4'DIS%')) or ((`contract_type` = _utf8mb4'MANUFACTURING') and (`external_id` like _utf8mb4'MAN%')) or ((`contract_type` = _utf8mb4'MERCHANDISE') and (`external_id` like _utf8mb4'MCT%')) or ((`contract_type` = _utf8mb4'OTHER') and (`external_id` like _utf8mb4'OTH%'))))
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Common contract information shared by all specialized contract types.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contracts`
--

LOCK TABLES `contracts` WRITE;
/*!40000 ALTER TABLE `contracts` DISABLE KEYS */;
INSERT INTO `contracts` VALUES (1,'DIS202610200001','DISCOGRAPHY','APPROVED',1,1,'2026-10-01','2031-09-30','Example Records holds distribution rights for Greatest Hits for five years.','2026-10-21 00:54:01','2026-11-15 08:16:13'),(2,'DIS202610200002','DISCOGRAPHY','FINISHED',2,4,'2026-11-01','2030-10-31','Draft regional distribution agreement for Luz de Ciudad.','2026-10-21 00:54:01','2026-11-16 06:12:09'),(3,'MAN202610200001','MANUFACTURING','APPROVED',1,2,'2026-10-15','2027-04-30','ACME Manufacturing will produce branded tour shirts under agreed quality requirements.','2026-10-21 00:54:01','2026-11-15 08:16:13'),(4,'MAN202610200002','MANUFACTURING','DRAFT',3,5,'2026-10-20','2027-02-28','PromoWorks Guatemala will manufacture promotional mugs for venue campaigns.','2026-10-21 00:54:01','2026-11-15 08:16:13'),(5,'MCT202610200001','MERCHANDISE','APPROVED',4,3,'2026-10-20','2027-01-31','Artist authorizes the use and distribution of signed promotional posters for the event.','2026-10-21 00:54:01','2026-11-15 08:16:13'),(6,'MAN202611150001','MANUFACTURING','PENDING',2,6,'2027-03-01','2027-05-31','Manufacturing agreement for festival merchandise, with revisions.','2026-11-16 00:52:46','2026-11-17 03:46:31'),(7,'DIS202611150001','DISCOGRAPHY','PENDING',3,8,'2026-12-04','2026-12-04','Prueba de solicitud de evento con datos de prueba','2026-11-16 02:47:20','2026-11-16 02:47:20'),(8,'DIS202611150002','DISCOGRAPHY','APPROVED',1,7,'2026-11-16','2026-11-16','Solicitud de evento de prueba','2026-11-16 02:48:24','2026-11-17 03:46:49'),(9,'DIS202611150003','DISCOGRAPHY','APPROVED',3,9,'2026-12-04','2026-12-04','Prueba de solicitud de evento','2026-11-16 04:56:53','2026-11-16 04:58:04'),(10,'DIS202611150004','DISCOGRAPHY','PENDING',2,10,'2026-11-24','2026-11-24','Prueba de label EMP. Contrato de prueba, se puede borrar.','2026-11-16 05:19:10','2026-11-16 05:19:10'),(11,'DIS202611150005','DISCOGRAPHY','APPROVED',2,10,'2026-11-24','2026-11-24','Prueba de label EMP. Contrato de prueba, se puede borrar.','2026-11-16 05:19:16','2026-11-17 03:46:49'),(12,'DIS202611150006','DISCOGRAPHY','PENDING',2,10,'2026-11-22','2026-11-23','Prueba de label EMP: fechas fuera del evento. Se puede borrar.','2026-11-16 05:26:03','2026-11-16 05:26:03'),(13,'DIS202611160001','DISCOGRAPHY','PENDING',5,11,'2027-04-10','2027-04-10','Internal test terms.','2026-11-17 02:08:32','2026-11-17 02:08:52'),(15,'DIS202611160002','DISCOGRAPHY','DRAFT',2,4,'2026-11-16','2026-11-27','These are definitively accurate contract terms.','2026-11-17 04:24:57','2026-11-17 04:24:57');
/*!40000 ALTER TABLE `contracts` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_contracts_external_id` BEFORE INSERT ON `contracts` FOR EACH ROW BEGIN
    DECLARE v_prefix CHAR(3);
    DECLARE v_external_id VARCHAR(15);

    IF NEW.external_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'contracts.external_id is generated automatically.';
    END IF;

    SET v_prefix = CASE NEW.contract_type
        WHEN 'DISCOGRAPHY' THEN 'DIS'
        WHEN 'MANUFACTURING' THEN 'MAN'
        WHEN 'MERCHANDISE' THEN 'MCT'
        ELSE 'OTH'
    END;

    CALL generate_entity_external_id(v_prefix, v_external_id);
    SET NEW.external_id = v_external_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_contracts_booking_requirements` BEFORE INSERT ON `contracts` FOR EACH ROW BEGIN
    IF NEW.status = 'APPROVED'
       AND (NEW.start_date IS NULL OR NEW.end_date IS NULL) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'An APPROVED contract must have start_date and end_date.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `ai_contracts_create_booking` AFTER INSERT ON `contracts` FOR EACH ROW BEGIN
    IF NEW.status = 'APPROVED' THEN
        INSERT INTO event_bookings (
            event_id,
            site_id,
            start_date,
            end_date,
            status,
            agreed_price,
            currency,
            contract_id,
            notes
        )
        VALUES (
            NEW.event_id,
            NEW.site_id,
            NEW.start_date,
            NEW.end_date,
            'CONFIRMED',
            NULL,
            NULL,
            NEW.contract_id,
            'Automatically created from approved contract.'
        );
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_contracts_public_fields` BEFORE UPDATE ON `contracts` FOR EACH ROW BEGIN
    IF NOT (NEW.external_id <=> OLD.external_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'contracts.external_id cannot be changed.';
    END IF;

    IF NEW.contract_type <> OLD.contract_type THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'contracts.contract_type cannot be changed after creation.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_contracts_booking_requirements` BEFORE UPDATE ON `contracts` FOR EACH ROW BEGIN
    IF NEW.status = 'APPROVED'
       AND (NEW.start_date IS NULL OR NEW.end_date IS NULL) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'An APPROVED contract must have start_date and end_date.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `au_contracts_sync_booking` AFTER UPDATE ON `contracts` FOR EACH ROW BEGIN
    IF NEW.status = 'APPROVED' THEN

        IF EXISTS (
            SELECT 1
            FROM event_bookings
            WHERE contract_id = NEW.contract_id
        ) THEN

            UPDATE event_bookings
            SET event_id   = NEW.event_id,
                site_id    = NEW.site_id,
                start_date = NEW.start_date,
                end_date   = NEW.end_date,
                status     = 'CONFIRMED',
                notes      = 'Automatically synchronized from approved contract.'
            WHERE contract_id = NEW.contract_id;

        ELSE

            INSERT INTO event_bookings (
                event_id,
                site_id,
                start_date,
                end_date,
                status,
                agreed_price,
                currency,
                contract_id,
                notes
            )
            VALUES (
                NEW.event_id,
                NEW.site_id,
                NEW.start_date,
                NEW.end_date,
                'CONFIRMED',
                NULL,
                NULL,
                NEW.contract_id,
                'Automatically created from approved contract.'
            );

        END IF;

    ELSEIF NEW.status IN ('CANCELLED', 'REJECTED') THEN

        UPDATE event_bookings
        SET status = 'CANCELLED',
            notes = 'Automatically cancelled from contract status.'
        WHERE contract_id = NEW.contract_id
          AND status <> 'CANCELLED';

    ELSEIF NEW.status = 'FINISHED' THEN

        UPDATE event_bookings
        SET status = 'COMPLETED',
            notes = 'Automatically completed from finished contract.'
        WHERE contract_id = NEW.contract_id
          AND status <> 'COMPLETED';

    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `discography_contracts`
--

DROP TABLE IF EXISTS `discography_contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `discography_contracts` (
  `contract_id` bigint unsigned NOT NULL,
  `artist_id` bigint unsigned NOT NULL,
  `record_label_id` bigint unsigned DEFAULT NULL,
  `album_id` bigint unsigned NOT NULL,
  `release_date` date NOT NULL,
  PRIMARY KEY (`contract_id`),
  KEY `idx_disc_contract_artist` (`artist_id`),
  KEY `idx_disc_contract_label` (`record_label_id`),
  KEY `idx_disc_contract_album` (`album_id`),
  CONSTRAINT `fk_disc_contract_album` FOREIGN KEY (`album_id`) REFERENCES `albums` (`album_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_disc_contract_artist` FOREIGN KEY (`artist_id`) REFERENCES `artists` (`artist_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_disc_contract_contract` FOREIGN KEY (`contract_id`) REFERENCES `contracts` (`contract_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_disc_contract_label` FOREIGN KEY (`record_label_id`) REFERENCES `record_labels` (`record_label_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Discography-specific contract data linking a contract to an artist, album, and optional record label.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `discography_contracts`
--

LOCK TABLES `discography_contracts` WRITE;
/*!40000 ALTER TABLE `discography_contracts` DISABLE KEYS */;
INSERT INTO `discography_contracts` VALUES (1,1,1,1,'2026-12-05'),(2,2,2,3,'2026-11-20'),(7,1,NULL,1,'2013-05-17'),(8,1,NULL,1,'2015-10-02'),(9,5,NULL,5,'2014-05-16'),(10,6,NULL,6,'2024-03-15'),(11,6,NULL,6,'2024-03-15'),(12,6,NULL,6,'2026-11-24'),(13,7,NULL,7,'2027-04-20'),(15,5,1,5,'2026-11-18');
/*!40000 ALTER TABLE `discography_contracts` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_discography_contracts` BEFORE INSERT ON `discography_contracts` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_discography_contracts` BEFORE UPDATE ON `discography_contracts` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
INSERT INTO `django_admin_log` VALUES (1,'2026-11-16 21:35:59.289494','6','Last Test Site',1,'[{\"added\": {}}]',7,1),(2,'2026-11-16 21:36:33.424880','6','Last Test Site',2,'[{\"changed\": {\"fields\": [\"Status\"]}}]',7,1),(3,'2026-11-16 21:51:00.769757','12','Last Test Event',1,'[{\"added\": {}}, {\"added\": {\"name\": \"event sites\", \"object\": \"Last Test Event - Last Test Site\"}}]',9,1),(4,'2026-11-16 22:24:57.043920','15','DIS202611160002',1,'[{\"added\": {}}]',11,1);
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(3,'auth','group'),(2,'auth','permission'),(4,'auth','user'),(5,'contenttypes','contenttype'),(10,'core','apirawdata'),(8,'core','contracts'),(11,'core','discographycontractadminproxy'),(9,'core','events'),(7,'core','sites'),(6,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2026-11-16 00:04:45.211171'),(2,'auth','0001_initial','2026-11-16 00:04:45.535979'),(3,'admin','0001_initial','2026-11-16 00:04:45.616150'),(4,'admin','0002_logentry_remove_auto_add','2026-11-16 00:04:45.620068'),(5,'admin','0003_logentry_add_action_flag_choices','2026-11-16 00:04:45.623550'),(6,'contenttypes','0002_remove_content_type_name','2026-11-16 00:04:45.676641'),(7,'auth','0002_alter_permission_name_max_length','2026-11-16 00:04:45.712868'),(8,'auth','0003_alter_user_email_max_length','2026-11-16 00:04:45.728140'),(9,'auth','0004_alter_user_username_opts','2026-11-16 00:04:45.733249'),(10,'auth','0005_alter_user_last_login_null','2026-11-16 00:04:45.879678'),(11,'auth','0006_require_contenttypes_0002','2026-11-16 00:04:45.881163'),(12,'auth','0007_alter_validators_add_error_messages','2026-11-16 00:04:45.884462'),(13,'auth','0008_alter_user_username_max_length','2026-11-16 00:04:45.919604'),(14,'auth','0009_alter_user_last_name_max_length','2026-11-16 00:04:45.953186'),(15,'auth','0010_alter_group_name_max_length','2026-11-16 00:04:45.961510'),(16,'auth','0011_update_proxy_permissions','2026-11-16 00:04:45.965250'),(17,'auth','0012_alter_user_first_name_max_length','2026-11-16 00:04:45.998315'),(18,'sessions','0001_initial','2026-11-16 00:04:46.016908');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('1p5t5ofsg32tl5a23tu3n37sckax0vqo','.eJxVjEEOwiAQRe_C2hAo4DAu3fcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInERWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdjjPx83q4fwc19vqtvSMC6xKQ0jxYAwCUrHE8eJ8BlS-MFAFzVqzQ2DM6bdGXgsYUXVi8P88pN3I:1xT9u4:RcPUXUeGaYI8kNi6JIrR9PGV2t7F9Kxf8w3YKK2qxOQ','2026-11-30 21:30:40.386305');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entity_external_id_sequences`
--

DROP TABLE IF EXISTS `entity_external_id_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `entity_external_id_sequences` (
  `prefix` char(3) NOT NULL,
  `sequence_date` date NOT NULL,
  `last_number` smallint unsigned NOT NULL,
  PRIMARY KEY (`prefix`,`sequence_date`),
  CONSTRAINT `chk_external_id_sequence_number` CHECK ((`last_number` between 1 and 9999)),
  CONSTRAINT `chk_external_id_sequence_prefix` CHECK ((`prefix` in (_utf8mb4'PTY',_utf8mb4'ART',_utf8mb4'LBL',_utf8mb4'MFR',_utf8mb4'ALB',_utf8mb4'PRD',_utf8mb4'SIT',_utf8mb4'EVT',_utf8mb4'BKG',_utf8mb4'MER',_utf8mb4'DIS',_utf8mb4'MAN',_utf8mb4'MCT',_utf8mb4'OTH')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Daily counters used to generate immutable 15-character public external IDs.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entity_external_id_sequences`
--

LOCK TABLES `entity_external_id_sequences` WRITE;
/*!40000 ALTER TABLE `entity_external_id_sequences` DISABLE KEYS */;
INSERT INTO `entity_external_id_sequences` VALUES ('ALB','2026-10-20',3),('ALB','2026-11-15',3),('ALB','2026-11-16',1),('ART','2026-10-20',2),('ART','2026-11-15',4),('ART','2026-11-16',1),('BKG','2026-10-20',2),('BKG','2026-11-15',1),('BKG','2026-11-16',3),('DIS','2026-10-20',2),('DIS','2026-11-15',6),('DIS','2026-11-16',2),('EVT','2026-10-20',3),('EVT','2026-11-14',2),('EVT','2026-11-15',5),('EVT','2026-11-16',2),('LBL','2026-10-20',2),('MAN','2026-10-20',2),('MAN','2026-11-15',1),('MCT','2026-10-20',1),('MER','2026-10-20',3),('MFR','2026-10-20',2),('MFR','2026-11-15',2),('MFR','2026-11-16',2),('PRD','2026-10-20',4),('PRD','2026-11-15',2),('PRD','2026-11-16',8),('PTY','2026-10-20',8),('PTY','2026-11-15',6),('PTY','2026-11-16',3),('SIT','2026-10-20',4),('SIT','2026-11-16',2);
/*!40000 ALTER TABLE `entity_external_id_sequences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_bookings`
--

DROP TABLE IF EXISTS `event_bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_bookings` (
  `booking_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(15) NOT NULL,
  `event_id` bigint unsigned NOT NULL,
  `site_id` bigint unsigned NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('HOLD','CONFIRMED','CANCELLED','COMPLETED') NOT NULL DEFAULT 'HOLD',
  `agreed_price` decimal(12,2) DEFAULT NULL,
  `currency` char(3) DEFAULT NULL,
  `contract_id` bigint unsigned DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`booking_id`),
  UNIQUE KEY `uq_event_bookings_external_id` (`external_id`),
  UNIQUE KEY `uq_event_bookings_contract` (`contract_id`),
  KEY `idx_event_bookings_site_dates` (`site_id`,`start_date`,`end_date`,`status`),
  KEY `idx_event_bookings_event` (`event_id`),
  KEY `idx_event_bookings_contract` (`contract_id`),
  KEY `fk_event_booking_event_site` (`event_id`,`site_id`),
  CONSTRAINT `fk_event_booking_contract` FOREIGN KEY (`contract_id`) REFERENCES `contracts` (`contract_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_event_booking_event_site` FOREIGN KEY (`event_id`, `site_id`) REFERENCES `event_sites` (`event_id`, `site_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_event_booking_currency` CHECK (((`agreed_price` is null) or (`currency` is not null))),
  CONSTRAINT `chk_event_booking_dates` CHECK ((`end_date` >= `start_date`)),
  CONSTRAINT `chk_event_booking_price` CHECK (((`agreed_price` is null) or (`agreed_price` >= 0))),
  CONSTRAINT `chk_event_bookings_external_id` CHECK (regexp_like(`external_id`,_utf8mb4'^BKG[0-9]{12}$'))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Actual reservations of sites for events; kept separate from advertised site availability.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_bookings`
--

LOCK TABLES `event_bookings` WRITE;
/*!40000 ALTER TABLE `event_bookings` DISABLE KEYS */;
INSERT INTO `event_bookings` VALUES (1,'BKG202610200001',1,1,'2026-11-14','2026-11-14','CONFIRMED',3500.00,'USD',1,'Confirmed release-night booking.','2026-10-21 00:54:01','2026-11-15 04:40:47'),(2,'BKG202610200002',4,2,'2026-11-01','2030-10-31','COMPLETED',1700.00,'USD',2,'Automatically completed from finished contract.','2026-10-21 00:54:01','2026-11-16 06:12:09'),(3,'BKG202611150001',9,3,'2026-12-04','2026-12-04','CONFIRMED',NULL,NULL,9,'Automatically created from approved contract.','2026-11-16 04:58:04','2026-11-16 04:58:04'),(4,'BKG202611160001',11,5,'2027-04-15','2027-04-15','HOLD',2500.00,'USD',NULL,'Manual administrative hold.','2026-11-17 02:09:54','2026-11-17 02:09:54'),(5,'BKG202611160002',10,2,'2026-11-24','2026-11-24','CONFIRMED',NULL,NULL,11,'Automatically created from approved contract.','2026-11-17 03:46:49','2026-11-17 03:46:49'),(6,'BKG202611160003',7,1,'2026-11-16','2026-11-16','CONFIRMED',NULL,NULL,8,'Automatically created from approved contract.','2026-11-17 03:46:49','2026-11-17 03:46:49');
/*!40000 ALTER TABLE `event_bookings` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_event_bookings_no_overlap` BEFORE INSERT ON `event_bookings` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_event_bookings_external_id` BEFORE INSERT ON `event_bookings` FOR EACH ROW BEGIN
    DECLARE v_external_id VARCHAR(15);

    IF NEW.external_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'event_bookings.external_id is generated automatically.';
    END IF;

    CALL generate_entity_external_id('BKG', v_external_id);
    SET NEW.external_id = v_external_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_event_bookings_no_overlap` BEFORE UPDATE ON `event_bookings` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_event_bookings_external_id` BEFORE UPDATE ON `event_bookings` FOR EACH ROW BEGIN
    IF NOT (NEW.external_id <=> OLD.external_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'event_bookings.external_id cannot be changed.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `event_merchandise`
--

DROP TABLE IF EXISTS `event_merchandise`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_merchandise` (
  `event_id` bigint unsigned NOT NULL,
  `merchandise_id` bigint unsigned NOT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '0',
  `unit_price` decimal(12,2) NOT NULL,
  `currency` char(3) NOT NULL,
  `promotion_type` varchar(100) DEFAULT NULL,
  `status` enum('PLANNED','ORDERED','RECEIVED','DISTRIBUTING','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PLANNED',
  PRIMARY KEY (`event_id`,`merchandise_id`),
  KEY `fk_event_merch_merch` (`merchandise_id`),
  CONSTRAINT `fk_event_merch_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_event_merch_merch` FOREIGN KEY (`merchandise_id`) REFERENCES `merchandise` (`merchandise_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_event_merch_price` CHECK ((`unit_price` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Merchandise quantities, pricing, and promotional use for a specific event.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_merchandise`
--

LOCK TABLES `event_merchandise` WRITE;
/*!40000 ALTER TABLE `event_merchandise` DISABLE KEYS */;
INSERT INTO `event_merchandise` VALUES (1,1,250,25.00,'USD','SALE','ORDERED'),(1,2,100,0.00,'USD','GIVEAWAY','RECEIVED'),(3,3,150,10.00,'USD','GIVEAWAY','PLANNED');
/*!40000 ALTER TABLE `event_merchandise` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_participants`
--

DROP TABLE IF EXISTS `event_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_participants` (
  `event_participant_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `event_id` bigint unsigned NOT NULL,
  `party_id` bigint unsigned NOT NULL,
  `role` varchar(100) NOT NULL,
  `status` enum('INVITED','CONFIRMED','DECLINED','CANCELLED') NOT NULL DEFAULT 'INVITED',
  `notes` text,
  PRIMARY KEY (`event_participant_id`),
  UNIQUE KEY `uq_event_participant_role` (`event_id`,`party_id`,`role`),
  KEY `idx_event_participants_party` (`party_id`),
  CONSTRAINT `fk_event_participant_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_event_participant_party` FOREIGN KEY (`party_id`) REFERENCES `parties` (`party_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Artists, manufacturers, labels, organizers, sponsors, or other parties participating in an event.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_participants`
--

LOCK TABLES `event_participants` WRITE;
/*!40000 ALTER TABLE `event_participants` DISABLE KEYS */;
INSERT INTO `event_participants` VALUES (1,1,1,'ARTIST','CONFIRMED','Headline performer.'),(2,1,3,'RECORD_LABEL','CONFIRMED','Coordinates album promotion.'),(3,1,7,'ORGANIZER','CONFIRMED','Internal event organizer.'),(4,2,2,'ARTIST','CONFIRMED','Featured performer.'),(5,2,4,'RECORD_LABEL','INVITED','Label participation pending.'),(6,2,7,'ORGANIZER','CONFIRMED','Internal event organizer.'),(7,3,6,'MANUFACTURER','CONFIRMED','Provides promotional products.'),(8,3,7,'ORGANIZER','CONFIRMED','Internal event organizer.'),(9,3,8,'SPONSOR','INVITED','Potential event sponsor.');
/*!40000 ALTER TABLE `event_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `event_sites`
--

DROP TABLE IF EXISTS `event_sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_sites` (
  `event_id` bigint unsigned NOT NULL,
  `site_id` bigint unsigned NOT NULL,
  `role` varchar(100) NOT NULL DEFAULT 'MAIN',
  PRIMARY KEY (`event_id`,`site_id`),
  KEY `idx_event_sites_site` (`site_id`),
  CONSTRAINT `fk_event_sites_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_event_sites_site` FOREIGN KEY (`site_id`) REFERENCES `sites` (`site_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Many-to-many association between events and the sites used by each event.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_sites`
--

LOCK TABLES `event_sites` WRITE;
/*!40000 ALTER TABLE `event_sites` DISABLE KEYS */;
INSERT INTO `event_sites` VALUES (1,1,'MAIN'),(2,1,'MAIN'),(3,4,'MAIN'),(4,2,'MAIN'),(5,3,'MAIN'),(6,2,'MAIN'),(7,1,'MAIN'),(8,3,'MAIN'),(9,3,'MAIN'),(10,2,'MAIN'),(11,5,'MAIN'),(12,6,'MAIN');
/*!40000 ALTER TABLE `event_sites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `events` (
  `event_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(15) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `event_type` varchar(100) DEFAULT NULL,
  `status` enum('PLANNED','CONFIRMED','CANCELLED','COMPLETED') NOT NULL DEFAULT 'PLANNED',
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`event_id`),
  UNIQUE KEY `uq_events_external_id` (`external_id`),
  KEY `idx_events_dates` (`start_date`,`end_date`),
  KEY `idx_events_status` (`status`),
  CONSTRAINT `chk_event_dates` CHECK ((`end_date` >= `start_date`)),
  CONSTRAINT `chk_events_external_id` CHECK (regexp_like(`external_id`,_utf8mb4'^EVT[0-9]{12}$'))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Events organized or tracked by the system.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
INSERT INTO `events` VALUES (1,'EVT202610200001','Greatest Hits Release Night','Album release event featuring The Example Band.','CONCERT','CONFIRMED','2026-11-14','2026-11-14','2026-10-21 00:54:01','2026-11-15 04:40:47'),(2,'EVT202610200002','Luz de Ciudad Showcase','Promotional showcase featuring Luna Rivera.','SHOWCASE','PLANNED','2026-11-21','2026-11-21','2026-10-21 00:54:01','2026-11-15 04:40:47'),(3,'EVT202610200003','Venue Merch Promotion','Promotional campaign for branded merchandise.','PROMOTION','PLANNED','2026-12-05','2026-12-05','2026-10-21 00:54:01','2026-11-15 04:40:47'),(4,'EVT202611140001','Tried and True Filling','Just a filler event #1','CONCERT','CONFIRMED','2026-12-10','2026-12-11','2026-11-15 05:37:59','2026-11-15 05:37:59'),(5,'EVT202611140002','Tried and Failed Filling','Just a filler event #2','SHOWCASE','CONFIRMED','2026-12-15','2026-12-17','2026-11-15 05:37:59','2026-11-15 05:37:59'),(6,'EVT202611150001','Summer Festival 2027','Annual summer music festival','FESTIVAL','PLANNED','2027-06-10','2027-06-12','2026-11-15 23:42:36','2026-11-15 23:42:36'),(7,'EVT202611150002','Avicii – Stories',NULL,'Concert','PLANNED','2026-11-16','2026-11-16','2026-11-16 02:17:31','2026-11-16 02:17:31'),(8,'EVT202611150003','Daft Punk – Random Access Memories',NULL,'Concert','PLANNED','2026-12-04','2026-12-04','2026-11-16 02:47:20','2026-11-16 02:47:20'),(9,'EVT202611150004','Coldplay – Ghost Stories',NULL,'Concert','PLANNED','2026-12-04','2026-12-04','2026-11-16 04:56:52','2026-11-16 04:56:52'),(10,'EVT202611150005','Luna Roja – Madrugada (prueba EMP)',NULL,'Concert','PLANNED','2026-11-24','2026-11-24','2026-11-16 05:19:09','2026-11-16 05:19:09'),(11,'EVT202611160001','Internal CRUD Test Event','Test event','CONCERT','PLANNED','2027-04-10','2027-04-11','2026-11-17 01:05:27','2026-11-17 01:05:27'),(12,'EVT202611160002','Last Test Event','Jussssst one laaast test event','CONCERT','PLANNED','2026-11-17','2026-11-27','2026-11-17 03:51:01','2026-11-17 03:51:01');
/*!40000 ALTER TABLE `events` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_events_external_id` BEFORE INSERT ON `events` FOR EACH ROW BEGIN
    DECLARE v_external_id VARCHAR(15);

    IF NEW.external_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'events.external_id is generated automatically.';
    END IF;

    CALL generate_entity_external_id('EVT', v_external_id);
    SET NEW.external_id = v_external_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_events_external_id` BEFORE UPDATE ON `events` FOR EACH ROW BEGIN
    IF NOT (NEW.external_id <=> OLD.external_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'events.external_id cannot be changed.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `external_records`
--

DROP TABLE IF EXISTS `external_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `external_records` (
  `external_record_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `system_id` bigint unsigned NOT NULL,
  `entity_type` varchar(100) NOT NULL,
  `internal_id` bigint unsigned NOT NULL,
  `external_id` varchar(255) NOT NULL,
  `external_updated_at` datetime DEFAULT NULL,
  `last_synced_at` datetime DEFAULT NULL,
  `sync_status` enum('PENDING','SUCCESS','FAILED','SKIPPED') NOT NULL DEFAULT 'PENDING',
  PRIMARY KEY (`external_record_id`),
  UNIQUE KEY `uq_external_record_external` (`system_id`,`entity_type`,`external_id`),
  UNIQUE KEY `uq_external_record_internal` (`system_id`,`entity_type`,`internal_id`),
  KEY `idx_external_records_internal` (`entity_type`,`internal_id`),
  CONSTRAINT `fk_external_records_system` FOREIGN KEY (`system_id`) REFERENCES `external_systems` (`system_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Maps canonical internal entity IDs to identifiers used by external systems.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `external_records`
--

LOCK TABLES `external_records` WRITE;
/*!40000 ALTER TABLE `external_records` DISABLE KEYS */;
INSERT INTO `external_records` VALUES (1,1,'CONTRACT',1,'EXT-DISC-1001','2026-10-18 12:00:00','2026-10-20 08:00:00','SUCCESS'),(2,2,'CONTRACT',3,'EXT-MAN-2001','2026-10-19 09:30:00','2026-10-20 08:05:00','SUCCESS'),(3,3,'SITE',1,'EXT-SITE-GT-001','2026-10-20 07:00:00','2026-10-20 08:10:00','SUCCESS'),(4,4,'ARTIST',3,'KNG1',NULL,'2026-11-15 22:10:39','SUCCESS'),(5,4,'ARTIST',4,'KNG10',NULL,'2026-11-15 22:10:39','SUCCESS'),(6,4,'ALBUM',4,'ALBUM-42',NULL,'2026-11-15 22:11:31','SUCCESS'),(7,5,'MANUFACTURER',3,'MAN-B1',NULL,'2026-11-16 19:03:02','SUCCESS'),(8,5,'MANUFACTURER',4,'MAN-B2',NULL,'2026-11-16 19:03:02','SUCCESS'),(9,5,'PRODUCT',5,'B1-VINYL',NULL,'2026-11-16 19:44:30','SUCCESS'),(10,5,'PRODUCT',6,'B1-CD',NULL,'2026-11-16 19:44:30','SUCCESS'),(11,6,'ARTIST',5,'KNG3',NULL,'2026-11-15 22:56:01','SUCCESS'),(12,6,'ALBUM',5,'25',NULL,'2026-11-15 22:56:22','SUCCESS'),(13,7,'ARTIST',6,'EMP1',NULL,'2026-11-15 23:19:09','SUCCESS'),(14,7,'ALBUM',6,'1',NULL,'2026-11-15 23:19:09','SUCCESS'),(15,5,'MANUFACTURER',6,'MAN-B3',NULL,'2026-11-16 19:03:02','SUCCESS'),(16,5,'PRODUCT',8,'B1-CASSETTE',NULL,'2026-11-16 19:44:30','SUCCESS'),(17,5,'PRODUCT',9,'B2-SHIRT',NULL,'2026-11-16 19:44:30','SUCCESS'),(18,5,'PRODUCT',10,'B2-HOODIE',NULL,'2026-11-16 19:44:30','SUCCESS'),(19,5,'PRODUCT',11,'B2-CAP',NULL,'2026-11-16 19:44:30','SUCCESS'),(20,5,'PRODUCT',12,'B3-PIN',NULL,'2026-11-16 19:44:30','SUCCESS'),(21,5,'PRODUCT',13,'B3-POSTER',NULL,'2026-11-16 19:44:30','SUCCESS'),(22,5,'PRODUCT',14,'B3-STICKER',NULL,'2026-11-16 19:44:30','SUCCESS');
/*!40000 ALTER TABLE `external_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `external_systems`
--

DROP TABLE IF EXISTS `external_systems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `external_systems` (
  `system_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `base_url` varchar(2048) DEFAULT NULL,
  `system_type` varchar(100) DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`system_id`),
  UNIQUE KEY `uq_external_system_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='External APIs or systems from which canonical data may be imported or synchronized.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `external_systems`
--

LOCK TABLES `external_systems` WRITE;
/*!40000 ALTER TABLE `external_systems` DISABLE KEYS */;
INSERT INTO `external_systems` VALUES (1,'External Discography Provider','https://discography-provider.test/api','DISCOGRAPHY_API','ACTIVE','2026-10-21 00:54:01','2026-10-21 00:54:01'),(2,'External Manufacturing Provider','https://manufacturing-provider.test/api','MANUFACTURING_API','ACTIVE','2026-10-21 00:54:01','2026-10-21 00:54:01'),(3,'External Venue Provider','https://venue-provider.test/api','VENUE_API','ACTIVE','2026-10-21 00:54:01','2026-10-21 00:54:01'),(4,'records_gateway',NULL,'PARTNER_API','ACTIVE','2026-11-16 04:09:42','2026-11-16 04:09:42'),(5,'manufacturing_gateway',NULL,'PARTNER_API','ACTIVE','2026-11-16 04:12:33','2026-11-16 04:12:33'),(6,'KNG',NULL,'PARTNER_API','ACTIVE','2026-11-16 04:56:01','2026-11-16 04:56:01'),(7,'EMP',NULL,'PARTNER_API','ACTIVE','2026-11-16 05:19:08','2026-11-16 05:19:08'),(8,'Discography Gateway','http://100.103.44.86:4000','DISCOGRAPHY','ACTIVE','2026-11-17 02:57:52','2026-11-17 02:57:52'),(9,'Manufacturing Gateway','http://100.75.29.54/manufactura-middleware','MANUFACTURING','ACTIVE','2026-11-17 02:58:28','2026-11-17 02:58:28');
/*!40000 ALTER TABLE `external_systems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manufacturers`
--

DROP TABLE IF EXISTS `manufacturers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manufacturers` (
  `manufacturer_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(15) NOT NULL,
  `party_id` bigint unsigned NOT NULL,
  `manufacturer_type` varchar(100) DEFAULT NULL,
  `website` varchar(2048) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`manufacturer_id`),
  UNIQUE KEY `uq_manufacturers_party` (`party_id`),
  UNIQUE KEY `uq_manufacturers_external_id` (`external_id`),
  CONSTRAINT `fk_manufacturers_party` FOREIGN KEY (`party_id`) REFERENCES `parties` (`party_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_manufacturers_external_id` CHECK (regexp_like(`external_id`,_utf8mb4'^MFR[0-9]{12}$'))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Manufacturer-specific data associated with a party.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manufacturers`
--

LOCK TABLES `manufacturers` WRITE;
/*!40000 ALTER TABLE `manufacturers` DISABLE KEYS */;
INSERT INTO `manufacturers` VALUES (1,'MFR202610200001',5,'GENERAL_MERCHANDISE','https://acmemfg.test','2026-10-21 00:54:01','2026-11-15 04:40:47'),(2,'MFR202610200002',6,'PROMOTIONAL_PRODUCTS','https://promoworks.test','2026-10-21 00:54:01','2026-11-15 04:40:47'),(3,'MFR202611150001',11,'MUSIC_MEDIA',NULL,'2026-11-16 04:12:33','2026-11-17 01:03:02'),(4,'MFR202611150002',12,'APPAREL',NULL,'2026-11-16 04:12:33','2026-11-17 01:03:02'),(5,'MFR202611160001',16,'MEDIA',NULL,'2026-11-17 00:48:53','2026-11-17 00:48:53'),(6,'MFR202611160002',17,'MERCHANDISE',NULL,'2026-11-17 01:03:02','2026-11-17 01:03:02');
/*!40000 ALTER TABLE `manufacturers` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_manufacturers_external_id` BEFORE INSERT ON `manufacturers` FOR EACH ROW BEGIN
    DECLARE v_external_id VARCHAR(15);

    IF NEW.external_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'manufacturers.external_id is generated automatically.';
    END IF;

    CALL generate_entity_external_id('MFR', v_external_id);
    SET NEW.external_id = v_external_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_manufacturers_external_id` BEFORE UPDATE ON `manufacturers` FOR EACH ROW BEGIN
    IF NOT (NEW.external_id <=> OLD.external_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'manufacturers.external_id cannot be changed.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `manufacturing_contracts`
--

DROP TABLE IF EXISTS `manufacturing_contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `manufacturing_contracts` (
  `contract_id` bigint unsigned NOT NULL,
  `manufacturer_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `release_date` date NOT NULL,
  PRIMARY KEY (`contract_id`),
  KEY `idx_man_contract_manufacturer` (`manufacturer_id`),
  KEY `idx_man_contract_product` (`product_id`),
  CONSTRAINT `fk_man_contract_contract` FOREIGN KEY (`contract_id`) REFERENCES `contracts` (`contract_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_man_contract_manufacturer` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`manufacturer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_man_contract_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Manufacturing-specific contract data linking a contract to a manufacturer and product.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manufacturing_contracts`
--

LOCK TABLES `manufacturing_contracts` WRITE;
/*!40000 ALTER TABLE `manufacturing_contracts` DISABLE KEYS */;
INSERT INTO `manufacturing_contracts` VALUES (3,1,1,'2026-11-15'),(4,2,3,'2026-12-01'),(6,1,2,'2027-05-16');
/*!40000 ALTER TABLE `manufacturing_contracts` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_manufacturing_contracts` BEFORE INSERT ON `manufacturing_contracts` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_manufacturing_contracts` BEFORE UPDATE ON `manufacturing_contracts` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `merchandise`
--

DROP TABLE IF EXISTS `merchandise`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchandise` (
  `merchandise_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(15) NOT NULL,
  `artist_id` bigint unsigned DEFAULT NULL,
  `product_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `merchandise_type` varchar(100) DEFAULT NULL,
  `sku` varchar(100) DEFAULT NULL,
  `unit_price` decimal(12,2) DEFAULT NULL,
  `currency` char(3) DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','DISCONTINUED') NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`merchandise_id`),
  UNIQUE KEY `uq_merchandise_external_id` (`external_id`),
  UNIQUE KEY `uq_merchandise_sku` (`sku`),
  KEY `idx_merchandise_artist` (`artist_id`),
  KEY `idx_merchandise_product` (`product_id`),
  CONSTRAINT `fk_merchandise_artist` FOREIGN KEY (`artist_id`) REFERENCES `artists` (`artist_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_merchandise_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_merchandise_currency` CHECK (((`unit_price` is null) or (`currency` is not null))),
  CONSTRAINT `chk_merchandise_external_id` CHECK (regexp_like(`external_id`,_utf8mb4'^MER[0-9]{12}$')),
  CONSTRAINT `chk_merchandise_price` CHECK (((`unit_price` is null) or (`unit_price` >= 0)))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Merchandise that may be associated with an artist, a manufactured product, or both.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchandise`
--

LOCK TABLES `merchandise` WRITE;
/*!40000 ALTER TABLE `merchandise` DISABLE KEYS */;
INSERT INTO `merchandise` VALUES (1,'MER202610200001',1,1,'The Example Band Tour Shirt','Artist-branded tour shirt produced by ACME.','APPAREL','MERCH-TEB-001',25.00,'USD','ACTIVE','2026-10-21 00:54:01','2026-11-15 04:40:47'),(2,'MER202610200002',1,2,'Signed Greatest Hits Poster','Limited promotional poster intended for event promotion.','POSTER','MERCH-TEB-002',15.00,'USD','ACTIVE','2026-10-21 00:54:01','2026-11-15 04:40:47'),(3,'MER202610200003',2,3,'Luna Rivera Promotional Mug','Venue and artist co-branded promotional mug.','PROMOTIONAL','MERCH-LR-001',10.00,'USD','ACTIVE','2026-10-21 00:54:01','2026-11-15 04:40:47');
/*!40000 ALTER TABLE `merchandise` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_merchandise_external_id` BEFORE INSERT ON `merchandise` FOR EACH ROW BEGIN
    DECLARE v_external_id VARCHAR(15);

    IF NEW.external_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'merchandise.external_id is generated automatically.';
    END IF;

    CALL generate_entity_external_id('MER', v_external_id);
    SET NEW.external_id = v_external_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_merchandise_external_id` BEFORE UPDATE ON `merchandise` FOR EACH ROW BEGIN
    IF NOT (NEW.external_id <=> OLD.external_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'merchandise.external_id cannot be changed.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `merchandise_contracts`
--

DROP TABLE IF EXISTS `merchandise_contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchandise_contracts` (
  `contract_id` bigint unsigned NOT NULL,
  `artist_id` bigint unsigned NOT NULL,
  `merchandise_id` bigint unsigned NOT NULL,
  `event_id` bigint unsigned DEFAULT NULL,
  `quantity` int unsigned NOT NULL,
  `unit_price` decimal(12,2) NOT NULL,
  `currency` char(3) NOT NULL,
  `delivery_date` date DEFAULT NULL,
  PRIMARY KEY (`contract_id`),
  KEY `idx_merch_contract_artist` (`artist_id`),
  KEY `idx_merch_contract_merch` (`merchandise_id`),
  KEY `idx_merch_contract_event` (`event_id`),
  CONSTRAINT `fk_merch_contract_artist` FOREIGN KEY (`artist_id`) REFERENCES `artists` (`artist_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_merch_contract_contract` FOREIGN KEY (`contract_id`) REFERENCES `contracts` (`contract_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_merch_contract_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_merch_contract_merch` FOREIGN KEY (`merchandise_id`) REFERENCES `merchandise` (`merchandise_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_merch_contract_price` CHECK ((`unit_price` >= 0)),
  CONSTRAINT `chk_merch_contract_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Contracts granting or acquiring merchandise for an artist and optionally a specific event.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchandise_contracts`
--

LOCK TABLES `merchandise_contracts` WRITE;
/*!40000 ALTER TABLE `merchandise_contracts` DISABLE KEYS */;
INSERT INTO `merchandise_contracts` VALUES (5,1,2,1,100,8.00,'USD','2026-11-10');
/*!40000 ALTER TABLE `merchandise_contracts` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_merchandise_contracts` BEFORE INSERT ON `merchandise_contracts` FOR EACH ROW BEGIN
    DECLARE v_contract_type VARCHAR(30);

    SELECT contract_type
      INTO v_contract_type
      FROM contracts
     WHERE contract_id = NEW.contract_id;

    IF v_contract_type <> 'MERCHANDISE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contract type must be MERCHANDISE.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_merchandise_contracts` BEFORE UPDATE ON `merchandise_contracts` FOR EACH ROW BEGIN
    DECLARE v_contract_type VARCHAR(30);

    SELECT contract_type
      INTO v_contract_type
      FROM contracts
     WHERE contract_id = NEW.contract_id;

    IF v_contract_type <> 'MERCHANDISE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Contract type must be MERCHANDISE.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `parties`
--

DROP TABLE IF EXISTS `parties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parties` (
  `party_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(15) NOT NULL,
  `party_type` enum('ARTIST','RECORD_LABEL','MANUFACTURER','ORGANIZER','SPONSOR','SUPPLIER','OTHER') NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(320) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `website` varchar(2048) DEFAULT NULL,
  `address` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`party_id`),
  UNIQUE KEY `uq_parties_external_id` (`external_id`),
  KEY `idx_parties_type_name` (`party_type`,`name`),
  CONSTRAINT `chk_parties_external_id` CHECK (regexp_like(`external_id`,_utf8mb4'^PTY[0-9]{12}$'))
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Canonical person or organization that can participate in events or contracts.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parties`
--

LOCK TABLES `parties` WRITE;
/*!40000 ALTER TABLE `parties` DISABLE KEYS */;
INSERT INTO `parties` VALUES (1,'PTY202610200001','ARTIST','The Example Band','contact@exampleband.test','+1-555-0101','https://exampleband.test','Los Angeles, CA, USA','2026-10-21 00:54:01','2026-11-15 04:40:47'),(2,'PTY202610200002','ARTIST','Luna Rivera','booking@lunarivera.test','+502-5550-0102','https://lunarivera.test','Guatemala City, Guatemala','2026-10-21 00:54:01','2026-11-15 04:40:47'),(3,'PTY202610200003','RECORD_LABEL','Example Records','contracts@examplerecords.test','+1-555-0201','https://examplerecords.test','New York, NY, USA','2026-10-21 00:54:01','2026-11-15 04:40:47'),(4,'PTY202610200004','RECORD_LABEL','Aurora Music Group','legal@auroramusic.test','+502-5550-0202','https://auroramusic.test','Guatemala City, Guatemala','2026-10-21 00:54:01','2026-11-15 04:40:47'),(5,'PTY202610200005','MANUFACTURER','ACME Manufacturing','sales@acmemfg.test','+1-555-0301','https://acmemfg.test','Austin, TX, USA','2026-10-21 00:54:01','2026-11-15 04:40:47'),(6,'PTY202610200006','MANUFACTURER','PromoWorks Guatemala','orders@promoworks.test','+502-5550-0302','https://promoworks.test','Mixco, Guatemala','2026-10-21 00:54:01','2026-11-15 04:40:47'),(7,'PTY202610200007','ORGANIZER','Event Place Management','events@eventplace.test','+502-5550-0401','https://eventplace.test','Guatemala City, Guatemala','2026-10-21 00:54:01','2026-11-15 04:40:47'),(8,'PTY202610200008','SPONSOR','Central Beverage Co.','sponsorships@centralbeverage.test','+502-5550-0501','https://centralbeverage.test','Guatemala City, Guatemala','2026-10-21 00:54:01','2026-11-15 04:40:47'),(9,'PTY202611150001','ARTIST','Madonna',NULL,NULL,NULL,NULL,'2026-11-16 04:09:42','2026-11-16 04:09:42'),(10,'PTY202611150002','ARTIST','Shakira',NULL,NULL,NULL,NULL,'2026-11-16 04:09:42','2026-11-16 04:09:42'),(11,'PTY202611150003','MANUFACTURER','Manufactura B1',NULL,NULL,NULL,NULL,'2026-11-16 04:12:33','2026-11-17 01:03:01'),(12,'PTY202611150004','MANUFACTURER','Manufactura B2',NULL,NULL,NULL,NULL,'2026-11-16 04:12:33','2026-11-17 01:03:01'),(13,'PTY202611150005','ARTIST','Coldplay',NULL,NULL,NULL,NULL,'2026-11-16 04:56:01','2026-11-16 04:56:01'),(14,'PTY202611150006','ARTIST','Luna Roja',NULL,NULL,NULL,NULL,'2026-11-16 05:19:08','2026-11-16 05:19:08'),(15,'PTY202611160001','ARTIST','Test Artist','artist@example.com',NULL,'https://example.com',NULL,'2026-11-17 00:46:06','2026-11-17 00:46:06'),(16,'PTY202611160002','MANUFACTURER','Test Manufacturing Company','contact@example.com',NULL,NULL,NULL,'2026-11-17 00:48:53','2026-11-17 00:48:53'),(17,'PTY202611160003','MANUFACTURER','Manufactura B3',NULL,NULL,NULL,NULL,'2026-11-17 01:03:02','2026-11-17 01:03:02');
/*!40000 ALTER TABLE `parties` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_parties_external_id` BEFORE INSERT ON `parties` FOR EACH ROW BEGIN
    DECLARE v_external_id VARCHAR(15);

    IF NEW.external_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'parties.external_id is generated automatically.';
    END IF;

    CALL generate_entity_external_id('PTY', v_external_id);
    SET NEW.external_id = v_external_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_parties_external_id` BEFORE UPDATE ON `parties` FOR EACH ROW BEGIN
    IF NOT (NEW.external_id <=> OLD.external_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'parties.external_id cannot be changed.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(15) NOT NULL,
  `manufacturer_id` bigint unsigned NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `description` text,
  `sku` varchar(100) DEFAULT NULL,
  `product_type` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `uq_products_external_id` (`external_id`),
  UNIQUE KEY `uq_products_sku` (`sku`),
  KEY `idx_products_manufacturer_name` (`manufacturer_id`,`product_name`),
  CONSTRAINT `fk_products_manufacturer` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`manufacturer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_products_external_id` CHECK (regexp_like(`external_id`,_utf8mb4'^PRD[0-9]{12}$'))
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Products that can be produced by manufacturers and optionally used as merchandise.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'PRD202610200001',1,'Tour T-Shirt','Black cotton tour shirt with front and back print.','ACME-TSHIRT-001','APPAREL','2026-10-21 00:54:01','2026-11-15 04:40:47'),(2,'PRD202610200002',1,'Limited Edition Poster','Numbered full-color promotional concert poster.','ACME-POSTER-001','PRINT','2026-10-21 00:54:01','2026-11-15 04:40:47'),(3,'PRD202610200003',2,'Promotional Mug','Ceramic mug carrying event venue branding.','PW-MUG-001','PROMOTIONAL','2026-10-21 00:54:01','2026-11-15 04:40:47'),(4,'PRD202610200004',2,'Event Wristband','Reusable branded wristband for venue promotion.','PW-WRIST-001','ACCESSORY','2026-10-21 00:54:01','2026-11-15 04:40:47'),(5,'PRD202611150001',3,'Disco de vinilo',NULL,'B1-VINYL','VINYL','2026-11-16 04:14:39','2026-11-17 01:44:30'),(6,'PRD202611150002',3,'Disco compacto',NULL,'B1-CD','CD','2026-11-16 04:14:39','2026-11-17 01:44:30'),(7,'PRD202611160001',5,'12 inch Vinyl','Standard vinyl pressing','VINYL-12-001','VINYL','2026-11-17 01:04:47','2026-11-17 01:04:47'),(8,'PRD202611160002',3,'Cassette',NULL,'B1-CASSETTE','CASSETTE','2026-11-17 01:44:30','2026-11-17 01:44:30'),(9,'PRD202611160003',4,'Camisa',NULL,NULL,'SHIRT','2026-11-17 01:44:30','2026-11-17 01:44:30'),(10,'PRD202611160004',4,'Hoodie',NULL,NULL,'HOODIE','2026-11-17 01:44:30','2026-11-17 01:44:30'),(11,'PRD202611160005',4,'Gorra',NULL,NULL,'CAP','2026-11-17 01:44:30','2026-11-17 01:44:30'),(12,'PRD202611160006',6,'Pin',NULL,NULL,'PIN','2026-11-17 01:44:30','2026-11-17 01:44:30'),(13,'PRD202611160007',6,'Póster',NULL,NULL,'POSTER','2026-11-17 01:44:30','2026-11-17 01:44:30'),(14,'PRD202611160008',6,'Sticker',NULL,NULL,'STICKER','2026-11-17 01:44:30','2026-11-17 01:44:30');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_products_external_id` BEFORE INSERT ON `products` FOR EACH ROW BEGIN
    DECLARE v_external_id VARCHAR(15);

    IF NEW.external_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'products.external_id is generated automatically.';
    END IF;

    CALL generate_entity_external_id('PRD', v_external_id);
    SET NEW.external_id = v_external_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_products_external_id` BEFORE UPDATE ON `products` FOR EACH ROW BEGIN
    IF NOT (NEW.external_id <=> OLD.external_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'products.external_id cannot be changed.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `record_labels`
--

DROP TABLE IF EXISTS `record_labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `record_labels` (
  `record_label_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(15) NOT NULL,
  `party_id` bigint unsigned NOT NULL,
  `catalog_prefix` varchar(50) DEFAULT NULL,
  `website` varchar(2048) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`record_label_id`),
  UNIQUE KEY `uq_record_labels_party` (`party_id`),
  UNIQUE KEY `uq_record_labels_external_id` (`external_id`),
  CONSTRAINT `fk_record_labels_party` FOREIGN KEY (`party_id`) REFERENCES `parties` (`party_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_record_labels_external_id` CHECK (regexp_like(`external_id`,_utf8mb4'^LBL[0-9]{12}$'))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Record-label-specific data associated with a party.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `record_labels`
--

LOCK TABLES `record_labels` WRITE;
/*!40000 ALTER TABLE `record_labels` DISABLE KEYS */;
INSERT INTO `record_labels` VALUES (1,'LBL202610200001',3,'EXR','https://examplerecords.test','2026-10-21 00:54:01','2026-11-15 04:40:47'),(2,'LBL202610200002',4,'AMG','https://auroramusic.test','2026-10-21 00:54:01','2026-11-15 04:40:47');
/*!40000 ALTER TABLE `record_labels` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_record_labels_external_id` BEFORE INSERT ON `record_labels` FOR EACH ROW BEGIN
    DECLARE v_external_id VARCHAR(15);

    IF NEW.external_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'record_labels.external_id is generated automatically.';
    END IF;

    CALL generate_entity_external_id('LBL', v_external_id);
    SET NEW.external_id = v_external_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_record_labels_external_id` BEFORE UPDATE ON `record_labels` FOR EACH ROW BEGIN
    IF NOT (NEW.external_id <=> OLD.external_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'record_labels.external_id cannot be changed.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `site_availability`
--

DROP TABLE IF EXISTS `site_availability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_availability` (
  `availability_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `site_id` bigint unsigned NOT NULL,
  `date` date NOT NULL,
  `available` tinyint(1) NOT NULL DEFAULT '1',
  `price` decimal(12,2) DEFAULT NULL,
  `currency` char(3) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`availability_id`),
  UNIQUE KEY `uq_site_availability_date` (`site_id`,`date`),
  KEY `idx_site_availability_search` (`date`,`available`,`site_id`),
  CONSTRAINT `fk_site_availability_site` FOREIGN KEY (`site_id`) REFERENCES `sites` (`site_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_site_availability_price` CHECK (((`price` is null) or (`price` >= 0))),
  CONSTRAINT `chk_site_availability_priced_date` CHECK (((`available` = false) or ((`price` is not null) and (`currency` is not null))))
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Per-day site availability and daily price used by the availability API.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_availability`
--

LOCK TABLES `site_availability` WRITE;
/*!40000 ALTER TABLE `site_availability` DISABLE KEYS */;
INSERT INTO `site_availability` VALUES (1,1,'2026-11-10',1,2500.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(2,1,'2026-11-11',1,2500.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(3,1,'2026-11-12',1,2500.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(4,1,'2026-11-13',1,3000.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(5,1,'2026-11-14',1,3500.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(6,1,'2026-11-15',1,3000.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(7,1,'2026-11-16',1,2500.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(8,1,'2026-11-17',1,2500.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(9,1,'2026-11-18',1,2500.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(10,1,'2026-11-19',0,NULL,NULL,'2026-10-21 00:54:01','2026-10-21 00:54:01'),(11,2,'2026-11-20',1,1400.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(12,2,'2026-11-21',1,1700.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(13,2,'2026-11-22',1,1700.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(14,2,'2026-11-23',1,1400.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(15,2,'2026-11-24',1,1400.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(16,3,'2026-12-03',1,1800.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(17,3,'2026-12-04',1,1800.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(18,3,'2026-12-05',1,2200.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(19,3,'2026-12-06',1,2200.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(20,3,'2026-12-07',1,1800.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01'),(21,4,'2026-11-15',1,1000.00,'USD','2026-10-21 00:54:01','2026-10-21 00:54:01');
/*!40000 ALTER TABLE `site_availability` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sites`
--

DROP TABLE IF EXISTS `sites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sites` (
  `site_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `external_id` varchar(15) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `address` varchar(500) DEFAULT NULL,
  `city` varchar(150) DEFAULT NULL,
  `state` varchar(150) DEFAULT NULL,
  `country` varchar(150) DEFAULT NULL,
  `postal_code` varchar(30) DEFAULT NULL,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `capacity` int unsigned DEFAULT NULL,
  `site_type` varchar(100) DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','MAINTENANCE') NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`site_id`),
  UNIQUE KEY `uq_sites_external_id` (`external_id`),
  KEY `idx_sites_name` (`name`),
  KEY `idx_sites_location` (`country`,`state`,`city`),
  CONSTRAINT `chk_sites_external_id` CHECK (regexp_like(`external_id`,_utf8mb4'^SIT[0-9]{12}$')),
  CONSTRAINT `chk_sites_latitude` CHECK (((`latitude` is null) or (`latitude` between -(90) and 90))),
  CONSTRAINT `chk_sites_longitude` CHECK (((`longitude` is null) or (`longitude` between -(180) and 180)))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Physical event locations or venues managed by the system.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sites`
--

LOCK TABLES `sites` WRITE;
/*!40000 ALTER TABLE `sites` DISABLE KEYS */;
INSERT INTO `sites` VALUES (1,'SIT202610200001','Grand Ballroom','Large indoor event hall suitable for concerts and product launches.','100 Avenida Reforma','Guatemala City','Guatemala','Guatemala','01010',14.603700,-90.489300,1200,'BALLROOM','ACTIVE','2026-10-21 00:54:01','2026-11-15 04:40:47'),(2,'SIT202610200002','Rooftop Stage','Open-air rooftop venue for smaller evening performances.','25 Zona 10','Guatemala City','Guatemala','Guatemala','01010',14.596100,-90.511200,450,'OUTDOOR_STAGE','ACTIVE','2026-10-21 00:54:01','2026-11-15 04:40:47'),(3,'SIT202610200003','Conference Center','Flexible indoor space for corporate and promotional events.','500 Avenida Las Americas','Guatemala City','Guatemala','Guatemala','01013',14.588800,-90.521300,800,'CONFERENCE_CENTER','ACTIVE','2026-10-21 00:54:01','2026-11-15 04:40:47'),(4,'SIT202610200004','Warehouse Hall','Temporary event space currently under maintenance.','12 Calzada Roosevelt','Mixco','Guatemala','Guatemala','01057',14.634500,-90.600000,1800,'WAREHOUSE','MAINTENANCE','2026-10-21 00:54:01','2026-11-15 04:40:47'),(5,'SIT202611160001','Internal Test Venue','CRUD test',NULL,'Guatemala City',NULL,'Guatemala',NULL,NULL,NULL,1500,'ARENA','ACTIVE','2026-11-17 00:39:36','2026-11-17 00:39:36'),(6,'SIT202611160002','Last Test Site','A beautiful imaginary site with great views of your mind.','Some totally real address','Im City','Im State','Imaginery',NULL,NULL,NULL,1000,'Patio','ACTIVE','2026-11-17 03:35:59','2026-11-17 03:36:33');
/*!40000 ALTER TABLE `sites` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_sites_external_id` BEFORE INSERT ON `sites` FOR EACH ROW BEGIN
    DECLARE v_external_id VARCHAR(15);

    IF NEW.external_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sites.external_id is generated automatically.';
    END IF;

    CALL generate_entity_external_id('SIT', v_external_id);
    SET NEW.external_id = v_external_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_sites_external_id` BEFORE UPDATE ON `sites` FOR EACH ROW BEGIN
    IF NOT (NEW.external_id <=> OLD.external_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sites.external_id cannot be changed.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `v_discography_contract_details`
--

DROP TABLE IF EXISTS `v_discography_contract_details`;
/*!50001 DROP VIEW IF EXISTS `v_discography_contract_details`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_discography_contract_details` AS SELECT 
 1 AS `contract_id`,
 1 AS `contract_external_id`,
 1 AS `contract_type`,
 1 AS `status`,
 1 AS `site_id`,
 1 AS `site_external_id`,
 1 AS `site_name`,
 1 AS `start_date`,
 1 AS `end_date`,
 1 AS `contract_terms`,
 1 AS `release_date`,
 1 AS `artist_id`,
 1 AS `artist_external_id`,
 1 AS `artist_name`,
 1 AS `album_id`,
 1 AS `album_external_id`,
 1 AS `album_title`,
 1 AS `record_label_id`,
 1 AS `record_label_external_id`,
 1 AS `record_label_name`,
 1 AS `created_at`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_manufacturing_contract_details`
--

DROP TABLE IF EXISTS `v_manufacturing_contract_details`;
/*!50001 DROP VIEW IF EXISTS `v_manufacturing_contract_details`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_manufacturing_contract_details` AS SELECT 
 1 AS `contract_id`,
 1 AS `contract_external_id`,
 1 AS `contract_type`,
 1 AS `status`,
 1 AS `site_id`,
 1 AS `site_external_id`,
 1 AS `site_name`,
 1 AS `start_date`,
 1 AS `end_date`,
 1 AS `contract_terms`,
 1 AS `release_date`,
 1 AS `manufacturer_id`,
 1 AS `manufacturer_external_id`,
 1 AS `manufacturer_name`,
 1 AS `product_id`,
 1 AS `product_external_id`,
 1 AS `product_title`,
 1 AS `created_at`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_site_available_dates`
--

DROP TABLE IF EXISTS `v_site_available_dates`;
/*!50001 DROP VIEW IF EXISTS `v_site_available_dates`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_site_available_dates` AS SELECT 
 1 AS `availability_id`,
 1 AS `site_id`,
 1 AS `site_external_id`,
 1 AS `location_name`,
 1 AS `date`,
 1 AS `price`,
 1 AS `currency`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'event_management'
--

--
-- Dumping routines for database 'event_management'
--
/*!50003 DROP PROCEDURE IF EXISTS `generate_entity_external_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_entity_external_id`(
    IN p_prefix CHAR(3),
    OUT p_external_id VARCHAR(15)
)
BEGIN
    DECLARE v_date DATE;
    DECLARE v_number SMALLINT UNSIGNED;

    SET v_date = CURRENT_DATE();

    INSERT INTO entity_external_id_sequences (
        prefix,
        sequence_date,
        last_number
    )
    VALUES (
        p_prefix,
        v_date,
        1
    )
    ON DUPLICATE KEY UPDATE
        last_number = last_number + 1;

    SELECT last_number
      INTO v_number
      FROM entity_external_id_sequences
     WHERE prefix = p_prefix
       AND sequence_date = v_date;

    IF v_number > 9999 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'External ID daily sequence exceeded 9999.';
    END IF;

    SET p_external_id = CONCAT(
        p_prefix,
        DATE_FORMAT(v_date, '%Y%m%d'),
        LPAD(v_number, 4, '0')
    );
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `event_management`
--

USE `event_management`;

--
-- Final view structure for view `v_discography_contract_details`
--

/*!50001 DROP VIEW IF EXISTS `v_discography_contract_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_discography_contract_details` AS select `c`.`contract_id` AS `contract_id`,`c`.`external_id` AS `contract_external_id`,`c`.`contract_type` AS `contract_type`,`c`.`status` AS `status`,`c`.`site_id` AS `site_id`,`s`.`external_id` AS `site_external_id`,`s`.`name` AS `site_name`,`c`.`start_date` AS `start_date`,`c`.`end_date` AS `end_date`,`c`.`contract_terms` AS `contract_terms`,`dc`.`release_date` AS `release_date`,`dc`.`artist_id` AS `artist_id`,`a`.`external_id` AS `artist_external_id`,`a`.`stage_name` AS `artist_name`,`dc`.`album_id` AS `album_id`,`al`.`external_id` AS `album_external_id`,`al`.`title` AS `album_title`,`dc`.`record_label_id` AS `record_label_id`,`rl`.`external_id` AS `record_label_external_id`,`p`.`name` AS `record_label_name`,`c`.`created_at` AS `created_at`,`c`.`updated_at` AS `updated_at` from ((((((`contracts` `c` left join `sites` `s` on((`s`.`site_id` = `c`.`site_id`))) join `discography_contracts` `dc` on((`dc`.`contract_id` = `c`.`contract_id`))) join `artists` `a` on((`a`.`artist_id` = `dc`.`artist_id`))) join `albums` `al` on((`al`.`album_id` = `dc`.`album_id`))) left join `record_labels` `rl` on((`rl`.`record_label_id` = `dc`.`record_label_id`))) left join `parties` `p` on((`p`.`party_id` = `rl`.`party_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_manufacturing_contract_details`
--

/*!50001 DROP VIEW IF EXISTS `v_manufacturing_contract_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_manufacturing_contract_details` AS select `c`.`contract_id` AS `contract_id`,`c`.`external_id` AS `contract_external_id`,`c`.`contract_type` AS `contract_type`,`c`.`status` AS `status`,`c`.`site_id` AS `site_id`,`s`.`external_id` AS `site_external_id`,`s`.`name` AS `site_name`,`c`.`start_date` AS `start_date`,`c`.`end_date` AS `end_date`,`c`.`contract_terms` AS `contract_terms`,`mc`.`release_date` AS `release_date`,`mc`.`manufacturer_id` AS `manufacturer_id`,`m`.`external_id` AS `manufacturer_external_id`,`mp`.`name` AS `manufacturer_name`,`mc`.`product_id` AS `product_id`,`pr`.`external_id` AS `product_external_id`,`pr`.`product_name` AS `product_title`,`c`.`created_at` AS `created_at`,`c`.`updated_at` AS `updated_at` from (((((`contracts` `c` left join `sites` `s` on((`s`.`site_id` = `c`.`site_id`))) join `manufacturing_contracts` `mc` on((`mc`.`contract_id` = `c`.`contract_id`))) join `manufacturers` `m` on((`m`.`manufacturer_id` = `mc`.`manufacturer_id`))) join `parties` `mp` on((`mp`.`party_id` = `m`.`party_id`))) join `products` `pr` on((`pr`.`product_id` = `mc`.`product_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_site_available_dates`
--

/*!50001 DROP VIEW IF EXISTS `v_site_available_dates`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_site_available_dates` AS select `sa`.`availability_id` AS `availability_id`,`sa`.`site_id` AS `site_id`,`s`.`external_id` AS `site_external_id`,`s`.`name` AS `location_name`,`sa`.`date` AS `date`,`sa`.`price` AS `price`,`sa`.`currency` AS `currency` from (`site_availability` `sa` join `sites` `s` on((`s`.`site_id` = `sa`.`site_id`))) where ((`sa`.`available` = true) and (`s`.`status` = 'ACTIVE') and exists(select 1 from `event_bookings` `eb` where ((`eb`.`site_id` = `sa`.`site_id`) and (`eb`.`status` in ('HOLD','CONFIRMED')) and (`sa`.`date` between `eb`.`start_date` and `eb`.`end_date`))) is false) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-17  0:01:09
