
-- =====================================================
-- PROJETO: BUSCADOR DE LOJAS
-- BANCO DE DADOS COMPLETO
-- =====================================================

CREATE DATABASE IF NOT EXISTS buscador_lojas
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE buscador_lojas;


-- =====================================================
-- 1. CATEGORIAS PRINCIPAIS
-- =====================================================

CREATE TABLE IF NOT EXISTS categorias_loja (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE
);

INSERT IGNORE INTO categorias_loja (nome) VALUES
('Moda'),
('Casa e Decoração'),
('Eletrônicos'),
('Beleza'),
('Alimentos e Bebidas'),
('Esporte e Lazer');



-- =====================================================
-- 2. SUBCATEGORIAS
-- Cada subcategoria pertence a uma categoria principal
-- =====================================================

CREATE TABLE IF NOT EXISTS subcategorias (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_categoria_loja INT UNSIGNED NOT NULL,
    nome VARCHAR(80) NOT NULL,

    CONSTRAINT fk_subcategorias_categoria
        FOREIGN KEY (id_categoria_loja)
        REFERENCES categorias_loja(id)
        ON DELETE CASCADE,

    UNIQUE KEY uq_subcategoria (
        id_categoria_loja,
        nome
    )
);

INSERT IGNORE INTO subcategorias
(id_categoria_loja, nome)
VALUES
(1, 'Roupas'),
(1, 'Calçados'),
(1, 'Acessórios'),
(2, 'Sala'),
(2, 'Quarto'),
(2, 'Cozinha'),
(2, 'Banheiro'),
(2, 'Decoração'),
(3, 'Smartphones e Tablets'),
(3, 'Computadores e Notebooks'),
(3, 'Áudio e Vídeo'),
(3, 'Games'),
(4, 'Skincare'),
(4, 'Cabelos'),
(4, 'Maquiagem'),
(4, 'Perfumaria'),
(5, 'Mercearia'),
(5, 'Bebidas'),
(5, 'Laticínios e Frios'),
(5, 'Hortifrúti'),
(6, 'Fitness e Musculação'),
(6, 'Esportes Coletivos'),
(6, 'Camping e Aventura');

-- =====================================================
-- 3. LOJAS
-- =====================================================

CREATE TABLE IF NOT EXISTS lojas (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    origem ENUM('osm', 'cadastro')
        NOT NULL DEFAULT 'cadastro',
    osm_id VARCHAR(20) NULL UNIQUE,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT NULL,
    tipo VARCHAR(60) NOT NULL DEFAULT 'Loja Física',
    rua VARCHAR(150) NULL,
    cep CHAR(8) NULL,
    cidade VARCHAR(120) NULL,
    uf CHAR(2) NULL,
    lat DOUBLE NOT NULL,
    lon DOUBLE NOT NULL,
    site VARCHAR(400) NULL,
    horario VARCHAR(400) NULL,

    INDEX idx_lojas_coord (lat, lon),
    INDEX idx_lojas_cidade (cidade)
);


-- =====================================================
-- 4. RELACIONAMENTO ENTRE LOJAS E SUBCATEGORIAS
-- Uma loja pode possuir várias subcategorias
-- Uma subcategoria pode estar em várias lojas
-- =====================================================

CREATE TABLE IF NOT EXISTS lojas_subcategorias (
    id_loja INT UNSIGNED NOT NULL,
    id_subcategoria INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_loja, id_subcategoria),

    CONSTRAINT fk_lojas_subcategorias_loja
        FOREIGN KEY (id_loja)
        REFERENCES lojas(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_lojas_subcategorias_subcategoria
        FOREIGN KEY (id_subcategoria)
        REFERENCES subcategorias(id)
        ON DELETE CASCADE
);


-- =====================================================
-- 5. TELEFONES
-- Uma loja pode ter vários telefones
-- =====================================================

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


-- =====================================================
-- 6. PRODUTOS
-- Cada produto pode pertencer a uma subcategoria
-- =====================================================

CREATE TABLE IF NOT EXISTS produtos (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    id_loja INT UNSIGNED NOT NULL,
    id_subcategoria INT UNSIGNED NULL,
    nome VARCHAR(120) NOT NULL,
    descricao VARCHAR(400) NULL,
    preco DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_produtos_loja
        FOREIGN KEY (id_loja)
        REFERENCES lojas(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_produtos_subcategoria
        FOREIGN KEY (id_subcategoria)
        REFERENCES subcategorias(id)
        ON DELETE SET NULL
);

-- =====================================================
-- 1. INNER JOIN
-- =====================================================

-- 1.1. Mostrar categorias e suas subcategorias

SELECT
    c.id AS id_categoria,
    c.nome AS categoria,
    s.id AS id_subcategoria,
    s.nome AS subcategoria
FROM categorias_loja AS c
INNER JOIN subcategorias AS s
    ON c.id = s.id_categoria_loja;


-- 1.2. Mostrar lojas e suas subcategorias

SELECT
    l.id AS id_loja,
    l.nome AS loja,
    s.nome AS subcategoria
FROM lojas AS l
INNER JOIN lojas_subcategorias AS ls
    ON l.id = ls.id_loja
INNER JOIN subcategorias AS s
    ON ls.id_subcategoria = s.id;


-- 1.3. Mostrar lojas, categorias e subcategorias

SELECT
    l.nome AS loja,
    c.nome AS categoria,
    s.nome AS subcategoria
FROM lojas AS l
INNER JOIN lojas_subcategorias AS ls
    ON l.id = ls.id_loja
INNER JOIN subcategorias AS s
    ON ls.id_subcategoria = s.id
INNER JOIN categorias_loja AS c
    ON s.id_categoria_loja = c.id;


-- 1.4. Mostrar produtos, lojas e suas subcategorias

SELECT
    p.id AS id_produto,
    p.nome AS produto,
    p.preco,
    l.nome AS loja,
    s.nome AS subcategoria
FROM produtos AS p
INNER JOIN lojas AS l
    ON p.id_loja = l.id
LEFT JOIN subcategorias AS s
    ON p.id_subcategoria = s.id;


-- 1.5. Mostrar produtos, lojas, categorias e subcategorias

SELECT
    p.nome AS produto,
    p.preco,
    l.nome AS loja,
    c.nome AS categoria,
    s.nome AS subcategoria
FROM produtos AS p
INNER JOIN lojas AS l
    ON p.id_loja = l.id
LEFT JOIN subcategorias AS s
    ON p.id_subcategoria = s.id
LEFT JOIN categorias_loja AS c
    ON s.id_categoria_loja = c.id;


-- =====================================================
-- 2. LEFT JOIN
-- =====================================================

-- 2.1. Mostrar todas as categorias e suas subcategorias

SELECT
    c.nome AS categoria,
    s.nome AS subcategoria
FROM categorias_loja AS c
LEFT JOIN subcategorias AS s
    ON c.id = s.id_categoria_loja;


-- 2.2. Mostrar todas as lojas, mesmo sem subcategorias

SELECT
    l.id,
    l.nome AS loja,
    s.nome AS subcategoria
FROM lojas AS l
LEFT JOIN lojas_subcategorias AS ls
    ON l.id = ls.id_loja
LEFT JOIN subcategorias AS s
    ON ls.id_subcategoria = s.id;


-- 2.3. Mostrar todas as lojas e seus telefones

SELECT
    l.nome AS loja,
    t.numero AS telefone
FROM lojas AS l
LEFT JOIN telefones AS t
    ON l.id = t.id_loja;


-- 2.4. Mostrar todos os produtos, mesmo sem subcategoria

SELECT
    p.nome AS produto,
    p.preco,
    s.nome AS subcategoria
FROM produtos AS p
LEFT JOIN subcategorias AS s
    ON p.id_subcategoria = s.id;


-- 2.5. Mostrar todas as lojas, categorias, subcategorias e telefones

SELECT
    l.nome AS loja,
    c.nome AS categoria,
    s.nome AS subcategoria,
    t.numero AS telefone
FROM lojas AS l
LEFT JOIN lojas_subcategorias AS ls
    ON l.id = ls.id_loja
LEFT JOIN subcategorias AS s
    ON ls.id_subcategoria = s.id
LEFT JOIN categorias_loja AS c
    ON s.id_categoria_loja = c.id
LEFT JOIN telefones AS t
    ON l.id = t.id_loja;


-- =====================================================
-- 3. RIGHT JOIN
-- =====================================================

-- 3.1. Mostrar todas as categorias, mesmo sem lojas

SELECT
    c.nome AS categoria,
    s.nome AS subcategoria
FROM subcategorias AS s
RIGHT JOIN categorias_loja AS c
    ON s.id_categoria_loja = c.id;


-- 3.2. Mostrar todas as subcategorias, mesmo sem lojas

SELECT
    s.nome AS subcategoria,
    l.nome AS loja
FROM lojas_subcategorias AS ls
RIGHT JOIN subcategorias AS s
    ON ls.id_subcategoria = s.id
LEFT JOIN lojas AS l
    ON ls.id_loja = l.id;


-- =====================================================
-- 4. CROSS JOIN
-- =====================================================

-- 4.1. Combinar todas as lojas com todas as categorias

SELECT
    l.nome AS loja,
    c.nome AS categoria
FROM lojas AS l
CROSS JOIN categorias_loja AS c;


-- 4.2. Combinar todas as categorias com subcategorias
-- (combinações possíveis, não representa vínculos reais)

SELECT
    c.nome AS categoria,
    s.nome AS subcategoria
FROM categorias_loja AS c
CROSS JOIN subcategorias AS s;


-- =====================================================
-- 5. SELF JOIN
-- =====================================================

-- 5.1. Encontrar lojas que ficam na mesma cidade

SELECT
    l1.nome AS loja_1,
    l2.nome AS loja_2,
    l1.cidade
FROM lojas AS l1
INNER JOIN lojas AS l2
    ON l1.cidade = l2.cidade
    AND l1.id < l2.id;


-- =====================================================
-- 6. CONSULTAS PRINCIPAIS DO BUSCADOR
-- =====================================================

-- 6.1. Buscar lojas pela categoria principal

SELECT DISTINCT
    l.id,
    l.nome AS loja,
    c.nome AS categoria,
    l.rua,
    l.cidade,
    l.uf,
    l.lat,
    l.lon
FROM lojas AS l
INNER JOIN lojas_subcategorias AS ls
    ON l.id = ls.id_loja
INNER JOIN subcategorias AS s
    ON ls.id_subcategoria = s.id
INNER JOIN categorias_loja AS c
    ON s.id_categoria_loja = c.id
WHERE c.nome = 'Moda';


-- 6.2. Buscar lojas pela subcategoria

SELECT
    l.id,
    l.nome AS loja,
    s.nome AS subcategoria,
    l.cidade,
    l.uf
FROM lojas AS l
INNER JOIN lojas_subcategorias AS ls
    ON l.id = ls.id_loja
INNER JOIN subcategorias AS s
    ON ls.id_subcategoria = s.id
WHERE s.nome = 'Calçados';


-- 6.3. Buscar lojas por categoria e subcategoria

SELECT
    l.id,
    l.nome AS loja,
    c.nome AS categoria,
    s.nome AS subcategoria,
    l.cidade
FROM lojas AS l
INNER JOIN lojas_subcategorias AS ls
    ON l.id = ls.id_loja
INNER JOIN subcategorias AS s
    ON ls.id_subcategoria = s.id
INNER JOIN categorias_loja AS c
    ON s.id_categoria_loja = c.id
WHERE c.nome = 'Moda'
AND s.nome = 'Calçados';


-- 6.4. Buscar produtos de uma loja específica

SELECT
    p.id,
    p.nome AS produto,
    p.descricao,
    p.preco,
    l.nome AS loja,
    s.nome AS subcategoria
FROM produtos AS p
INNER JOIN lojas AS l
    ON p.id_loja = l.id
LEFT JOIN subcategorias AS s
    ON p.id_subcategoria = s.id
WHERE l.id = 1;


-- 6.5. Buscar produtos por categoria principal

SELECT
    p.nome AS produto,
    p.preco,
    l.nome AS loja,
    c.nome AS categoria,
    s.nome AS subcategoria
FROM produtos AS p
INNER JOIN lojas AS l
    ON p.id_loja = l.id
INNER JOIN subcategorias AS s
    ON p.id_subcategoria = s.id
INNER JOIN categorias_loja AS c
    ON s.id_categoria_loja = c.id
WHERE c.nome = 'Moda';


-- 6.6. Buscar produtos por subcategoria

SELECT
    p.nome AS produto,
    p.preco,
    l.nome AS loja,
    s.nome AS subcategoria
FROM produtos AS p
INNER JOIN lojas AS l
    ON p.id_loja = l.id
INNER JOIN subcategorias AS s
    ON p.id_subcategoria = s.id
WHERE s.nome = 'Roupas';


-- 6.7. Buscar produtos por faixa de preço

SELECT
    p.nome AS produto,
    p.preco,
    l.nome AS loja,
    s.nome AS subcategoria
FROM produtos AS p
INNER JOIN lojas AS l
    ON p.id_loja = l.id
LEFT JOIN subcategorias AS s
    ON p.id_subcategoria = s.id
WHERE p.preco BETWEEN 50 AND 200
ORDER BY p.preco ASC;


-- 6.8. Buscar lojas por cidade

SELECT DISTINCT
    l.id,
    l.nome AS loja,
    l.cidade,
    l.uf,
    l.rua
FROM lojas AS l
WHERE l.cidade = 'Fortaleza';


-- 6.9. Buscar lojas com telefone e endereço

SELECT
    l.id,
    l.nome AS loja,
    l.rua,
    l.cidade,
    l.uf,
    t.numero AS telefone,
    l.site
FROM lojas AS l
LEFT JOIN telefones AS t
    ON l.id = t.id_loja;


-- 6.10. Buscar lojas por categoria e cidade

SELECT DISTINCT
    l.id,
    l.nome AS loja,
    c.nome AS categoria,
    l.cidade,
    l.uf
FROM lojas AS l
INNER JOIN lojas_subcategorias AS ls
    ON l.id = ls.id_loja
INNER JOIN subcategorias AS s
    ON ls.id_subcategoria = s.id
INNER JOIN categorias_loja AS c
    ON s.id_categoria_loja = c.id
WHERE c.nome = 'Moda'
AND l.cidade = 'Fortaleza';

