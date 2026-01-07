-- -----------------------------------------------------
-- Database: piscoboxdb
-- Purpose: Simple CRUD demo using PHP + MySQLi
-- -----------------------------------------------------

-- Create database
CREATE DATABASE IF NOT EXISTS piscoboxdb
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Select database
USE piscoboxdb;

-- -----------------------------------------------------
-- Table structure for table `videogames`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS videogames (
  id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique game identifier',
  title VARCHAR(100) NOT NULL COMMENT 'Game title',
  genre VARCHAR(50) NOT NULL COMMENT 'Game genre (e.g. RPG, Shooter, Adventure)',
  platform VARCHAR(50) NOT NULL COMMENT 'Platform (e.g. PC, Switch, PlayStation)',
  emoji VARCHAR(10) DEFAULT NULL COMMENT 'Emoji representing the game',
  price DECIMAL(6,2) DEFAULT NULL COMMENT 'Game price in USD',
  release_date DATE DEFAULT NULL COMMENT 'Release date of the game'
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Stores video game information for the CRUD demo';
