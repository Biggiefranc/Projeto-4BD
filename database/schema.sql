-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Cliente` (
  `ID` INT NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  `senha` VARCHAR(45) NOT NULL,
  `rua` VARCHAR(45) NOT NULL,
  `num` INT NOT NULL,
  `bairro` VARCHAR(45) NOT NULL,
  `cidade` VARCHAR(45) NOT NULL,
  `CEP` INT NOT NULL,
  `logradouro` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Loja`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Loja` (
  `ID` INT NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `rua` VARCHAR(45) NOT NULL,
  `num` INT NOT NULL,
  `bairro` VARCHAR(45) NOT NULL,
  `cidade` VARCHAR(45) NOT NULL,
  `CEP` INT NOT NULL,
  `logradouro` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(45) NULL,
  `hor_atendimento` DATETIME NOT NULL,
  PRIMARY KEY (`ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Produto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Produto` (
  `nome` VARCHAR(45) NOT NULL,
  `descricao` VARCHAR(45) NOT NULL,
  `preco` INT NOT NULL,
  `ID_Loja` INT NOT NULL,
  PRIMARY KEY (`ID_Loja`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Categoria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Categoria` (
  `ID_Loja` INT NOT NULL,
  `ID_Cliente` INT NOT NULL,
  `graos_cereais` VARCHAR(45) NULL,
  `oleaginosas_sementes` VARCHAR(45) NULL,
  `ervas` VARCHAR(45) NULL,
  `temperos` VARCHAR(45) NULL,
  `especiarias` VARCHAR(45) NULL,
  `frutas_secas_desidratadas` VARCHAR(45) NULL,
  `adocantes` VARCHAR(45) NULL,
  `fontes_energias_naturais` VARCHAR(45) NULL,
  `chas` VARCHAR(45) NULL,
  `infusoes` VARCHAR(45) NULL,
  `suplementos_funcionais` VARCHAR(45) NULL,
  PRIMARY KEY (`ID_Loja`, `ID_Cliente`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Telefone`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Telefone` (
  `ID_Telefone` INT NOT NULL,
  `ID_Loja` INT NOT NULL,
  PRIMARY KEY (`ID_Telefone`, `ID_Loja`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
