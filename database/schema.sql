CREATE DATABASE IF NOT EXISTS buscador_lojas
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE buscador_lojas;

-- =====================================
-- TABELA LOJAS
-- =====================================

CREATE TABLE IF NOT EXISTS lojas (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    origem ENUM('osm','cadastro') NOT NULL DEFAULT 'cadastro',
    osm_id VARCHAR(20) NULL UNIQUE,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT NULL,
    tipo VARCHAR(60) NOT NULL DEFAULT 'Loja natural',
    rua VARCHAR(45),
    cep CHAR(8) NULL,
    cidade VARCHAR(120) NULL,
    uf CHAR(2) NULL,
    lat DOUBLE NOT NULL,
    lon DOUBLE NOT NULL,
    site VARCHAR(400) NULL,
    horario VARCHAR(400) NULL,

    INDEX idx_lojas_coord (lat, lon),
  

    CONSTRAINT fk_lojas_cep
        FOREIGN KEY (cep) REFERENCES ceps(cep)
);


-- =====================================
-- TABELA TELEFONES
-- =====================================

CREATE TABLE IF NOT EXISTS telefones (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_loja INT UNSIGNED NOT NULL,
    numero VARCHAR(40) NOT NULL,

    UNIQUE KEY uq_telefone (id_loja, numero),

    CONSTRAINT fk_telefones_loja
        FOREIGN KEY (id_loja)
        REFERENCES lojas(id)
        ON DELETE CASCADE
);


-- =====================================
-- TABELA CATEGORIAS_PRODUTOS
-- =====================================

CREATE TABLE IF NOT EXISTS categorias_prod (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE
);


INSERT IGNORE INTO categorias_prod (nome) VALUES
('Roupas femininas'),
('Roupas masculinas'),
('Calçados'),
('Acessorios'),
('Sala'), 
('Quarto'), 
('Cozinha'), 
('Banheiro'), 
('Smartphone/tablets'), 
('Computador/Notebook'), 
('Audio/Video'), 
('Games'), 
('Skincare'), 
('Cabelos'), 
('Maquiagem'), 
('Perfumaria'), 
('Mercearia'), 
('Bebidas'), 
('Laticínios/Frios'), 
('Hortifrúti'), 
('Fitness/Musculação'), 
('Esportes Coletivos'), 
('Camping/Aventura');




-- =====================================
-- TABELA PRODUTOS
-- =====================================

CREATE TABLE IF NOT EXISTS produtos (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_loja INT UNSIGNED NOT NULL,
    id_categoria INT UNSIGNED NULL,
    nome VARCHAR(120) NOT NULL,
    descricao VARCHAR(400) NULL,
    preco DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_produtos_loja
        FOREIGN KEY (id_loja)
        REFERENCES lojas(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_produtos_categoria
        FOREIGN KEY (id_categoria)
        REFERENCES categorias(id)
        ON DELETE SET NULL
);

-- =====================================
-- TABELA CATEGORIAS_LOJA
-- =====================================

CREATE TABLE IF NOT EXISTS categorias_Loja (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE
);

INSERT IGNORE INTO categorias_Loja (nome) VALUES
('Moda/vestuario'),
('Casa/decoração'), 
('Eletronicos/tecnologia'), 
('Beleza/cuidados pessoais'),
('Alimentos/bebidas'),
('Esporte e lazer'); 



