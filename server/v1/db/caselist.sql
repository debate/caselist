-- MySQL Script generated by MySQL Workbench
-- Fri 06 May 2022 08:57:23 AM MDT
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema caselist
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema caselist
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `caselist` ;
USE `caselist` ;

-- -----------------------------------------------------
-- Table `caselist`.`caselists`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `caselist`.`caselists` ;

CREATE TABLE IF NOT EXISTS `caselist`.`caselists` (
  `caselist_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(32) NOT NULL,
  `display_name` VARCHAR(127) NOT NULL,
  `year` INT NOT NULL,
  `event` VARCHAR(32) NULL,
  `level` VARCHAR(32) NULL COMMENT 'One of \"hs\" or \"college\"',
  `team_size` INT NULL,
  `archived` TINYINT(1) NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by_id` INT NULL,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by_id` INT NULL,
  PRIMARY KEY (`caselist_id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `caselist`.`schools`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `caselist`.`schools` ;

CREATE TABLE IF NOT EXISTS `caselist`.`schools` (
  `school_id` INT NOT NULL AUTO_INCREMENT,
  `caselist_id` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `display_name` VARCHAR(255) NULL,
  `state` VARCHAR(2) NULL,
  `chapter_id` INT NULL,
  `deleted` TINYINT(1) NULL DEFAULT 0,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by_id` INT NULL,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by_id` INT NULL,
  PRIMARY KEY (`school_id`),
  INDEX `school_fk_wiki_idx` (`caselist_id` ASC) VISIBLE,
  UNIQUE INDEX `school_caselist_uq` (`caselist_id` ASC, `name` ASC) VISIBLE,
  CONSTRAINT `school_fk_caselist`
    FOREIGN KEY (`caselist_id`)
    REFERENCES `caselist`.`caselists` (`caselist_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `caselist`.`teams`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `caselist`.`teams` ;

CREATE TABLE IF NOT EXISTS `caselist`.`teams` (
  `team_id` INT NOT NULL AUTO_INCREMENT,
  `school_id` INT NOT NULL,
  `name` VARCHAR(32) NOT NULL,
  `display_name` VARCHAR(255) NOT NULL,
  `notes` LONGTEXT NULL,
  `debater1_first` VARCHAR(255) NULL,
  `debater1_last` VARCHAR(255) NULL,
  `debater1_student_id` INT NULL,
  `debater2_first` VARCHAR(255) NULL,
  `debater2_last` VARCHAR(255) NULL,
  `debater2_student_id` INT NULL,
  `debater3_first` VARCHAR(255) NULL,
  `debater3_last` VARCHAR(255) NULL,
  `debater3_student_id` INT NULL,
  `debater4_first` VARCHAR(255) NULL,
  `debater4_last` VARCHAR(255) NULL,
  `debater4_student_id` INT NULL,
  `deleted` TINYINT(1) NULL DEFAULT 0,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by_id` INT NULL,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by_id` INT NULL,
  PRIMARY KEY (`team_id`),
  UNIQUE INDEX `team_school_code_uq` (`school_id` ASC, `name` ASC) VISIBLE,
  CONSTRAINT `team_fk_school`
    FOREIGN KEY (`school_id`)
    REFERENCES `caselist`.`schools` (`school_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `caselist`.`rounds`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `caselist`.`rounds` ;

CREATE TABLE IF NOT EXISTS `caselist`.`rounds` (
  `round_id` INT NOT NULL AUTO_INCREMENT,
  `team_id` INT NOT NULL,
  `side` VARCHAR(1) NOT NULL,
  `tournament` VARCHAR(255) NOT NULL,
  `round` VARCHAR(32) NOT NULL,
  `opponent` VARCHAR(255) NULL,
  `judge` VARCHAR(255) NULL,
  `report` LONGTEXT NULL,
  `opensource` VARCHAR(255) NULL,
  `tourn_id` INT NULL,
  `external_id` INT NULL,
  `deleted` TINYINT(1) NULL DEFAULT 0,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by_id` INT NULL,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by_id` INT NULL,
  PRIMARY KEY (`round_id`),
  INDEX `round_fk_team_idx` (`team_id` ASC) VISIBLE,
  CONSTRAINT `round_fk_team`
    FOREIGN KEY (`team_id`)
    REFERENCES `caselist`.`teams` (`team_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `caselist`.`cites`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `caselist`.`cites` ;

CREATE TABLE IF NOT EXISTS `caselist`.`cites` (
  `cite_id` INT NOT NULL AUTO_INCREMENT,
  `round_id` INT NOT NULL,
  `title` VARCHAR(127) NULL,
  `cites` LONGTEXT NULL,
  `deleted` TINYINT(1) NULL DEFAULT 0,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by_id` INT NULL,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by_id` INT NULL,
  PRIMARY KEY (`cite_id`),
  INDEX `cite_fk_round_idx` (`round_id` ASC) VISIBLE,
  CONSTRAINT `cite_fk_round`
    FOREIGN KEY (`round_id`)
    REFERENCES `caselist`.`rounds` (`round_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `caselist`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `caselist`.`users` ;

CREATE TABLE IF NOT EXISTS `caselist`.`users` (
  `user_id` INT NOT NULL,
  `email` VARCHAR(255) NULL,
  `display_name` VARCHAR(255) NULL,
  PRIMARY KEY (`user_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `caselist`.`sessions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `caselist`.`sessions` ;

CREATE TABLE IF NOT EXISTS `caselist`.`sessions` (
  `session_id` INT NOT NULL AUTO_INCREMENT,
  `token` VARCHAR(128) NOT NULL,
  `user_id` INT NOT NULL,
  `ip` VARCHAR(63) NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` TIMESTAMP NULL,
  PRIMARY KEY (`session_id`),
  INDEX `sessions_fk_users_idx` (`user_id` ASC) VISIBLE,
  CONSTRAINT `sessions_fk_users`
    FOREIGN KEY (`user_id`)
    REFERENCES `caselist`.`users` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `caselist`.`openev`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `caselist`.`openev` ;

CREATE TABLE IF NOT EXISTS `caselist`.`openev` (
  `openev_id` INT NOT NULL AUTO_INCREMENT,
  `path` VARCHAR(255) NOT NULL,
  `year` INT NOT NULL,
  `camp` VARCHAR(64) NOT NULL,
  `lab` VARCHAR(32) NULL,
  `tags` JSON NULL,
  `deleted` TINYINT(1) NULL DEFAULT 0,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by_id` INT NULL,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by_id` INT NULL,
  PRIMARY KEY (`openev_id`),
  UNIQUE INDEX `path_UNIQUE` (`path` ASC) VISIBLE,
  INDEX `openev_year` (`year` ASC) VISIBLE,
  INDEX `openev_camp` (`camp` ASC) VISIBLE);


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
