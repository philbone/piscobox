/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: piscoboxdb
-- ------------------------------------------------------
-- Server version 10.11.14-MariaDB-0+deb12u2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `videogames`
--

DROP TABLE IF EXISTS `videogames`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `videogames` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique game identifier',
  `title` varchar(100) NOT NULL COMMENT 'Game title',
  `genre` varchar(50) NOT NULL COMMENT 'Game genre (e.g. RPG, Shooter, Adventure)',
  `platform` varchar(50) NOT NULL COMMENT 'Platform (e.g. PC, Switch, PlayStation)',
  `emoji` varchar(10) DEFAULT NULL COMMENT 'Emoji representing the game',
  `price` decimal(6,2) DEFAULT NULL COMMENT 'Game price in USD',
  `release_date` date DEFAULT NULL COMMENT 'Release date of the game',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Stores video game information for the CRUD demo';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `videogames`
--

LOCK TABLES `videogames` WRITE;
/*!40000 ALTER TABLE `videogames` DISABLE KEYS */;
INSERT INTO `videogames` VALUES
(1,'Hitman Codename 47','suspense','PC, Xbox, PS1','𝄃𝄃𝄂𝄂𝄀𝄁𝄃𝄂𝄂𝄃',9.00,'2000-11-21'),
(2,'Grand Theft Auto V','Action-Adventure, Third-person shooter, Open world','PC, Xbox, PS','🚔',59.00,'2013-09-15'),
(3,'Pro Evolution Soccer 2018','Sports video game, football video game, sports','PS3, PS4, Xbox 360, Xbox One, Windows','⚽',19.00,'2017-09-12'),
(4,'Battlefield 3','First-person shooter',' PS3, Xbox 360, Windows','🪖',39.00,'2011-10-25'),
(5,'F1 2013','Formula 1 Racing Simulator','Windows, PS3, Xbox 360','🏎️',29.00,'2013-10-08'),
(6,'Borderlands 2','First-person shooter, action-RPG','Windows MacOSX N-Switch PS3-4 Vita Xbox 360-One','🔫',49.00,'2012-09-18');
/*!40000 ALTER TABLE `videogames` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-06 12:25:44
