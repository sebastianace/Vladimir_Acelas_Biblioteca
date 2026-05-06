-- ============================================================
--  SISTEMA DE BIBLIOTECA DIGITAL - ReadFlow
--  Versión SQLite (compatible con Programiz)
-- ============================================================

-- ------------------------------------------------------------
-- 1. TABLA: usuario
-- ------------------------------------------------------------
CREATE TABLE usuario (
    id_usuario     INTEGER      NOT NULL,
    nombre         VARCHAR(150) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    telefono       VARCHAR(20),
    fecha_registro DATE         NOT NULL,
    PRIMARY KEY (id_usuario)
);

-- ------------------------------------------------------------
-- 2. TABLA: libro
-- ------------------------------------------------------------
CREATE TABLE libro (
    ISBN    VARCHAR(20)  NOT NULL,
    titulo  VARCHAR(255) NOT NULL,
    anio    INTEGER,
    genero  VARCHAR(100),
    estado  VARCHAR(20)  NOT NULL DEFAULT 'disponible'
                         CHECK (estado IN ('disponible', 'prestado')),
    PRIMARY KEY (ISBN)
);

-- ------------------------------------------------------------
-- 3. TABLA: prestamo
-- ------------------------------------------------------------
CREATE TABLE prestamo (
    id_prestamo      INTEGER     NOT NULL,
    isbn_libro       VARCHAR(20) NOT NULL,
    id_usuario       INTEGER     NOT NULL,
    fecha_prestamo   DATE        NOT NULL,
    fecha_devolucion DATE,
    PRIMARY KEY (id_prestamo),
    FOREIGN KEY (isbn_libro) REFERENCES libro (ISBN),
    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

-- ------------------------------------------------------------
-- 4. TABLA: resena
-- ------------------------------------------------------------
CREATE TABLE resena (
    id_resena    INTEGER     NOT NULL,
    isbn_libro   VARCHAR(20) NOT NULL,
    id_usuario   INTEGER     NOT NULL,
    calificacion INTEGER     NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
    comentario   TEXT,
    fecha        DATE        NOT NULL,
    PRIMARY KEY (id_resena),
    FOREIGN KEY (isbn_libro) REFERENCES libro (ISBN),
    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

-- ------------------------------------------------------------
-- 5. TABLA: categoria
-- ------------------------------------------------------------
CREATE TABLE categoria (
    id_categoria INTEGER      NOT NULL,
    nombre       VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_categoria)
);

-- ------------------------------------------------------------
-- 6. TABLA: libro_categoria  (relación N:M)
-- ------------------------------------------------------------
CREATE TABLE libro_categoria (
    isbn_libro   VARCHAR(20) NOT NULL,
    id_categoria INTEGER     NOT NULL,
    PRIMARY KEY (isbn_libro, id_categoria),
    FOREIGN KEY (isbn_libro)   REFERENCES libro (ISBN),
    FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria)
);

-- ============================================================
--  DATOS DE PRUEBA
-- ============================================================

INSERT INTO usuario (id_usuario, nombre, email, telefono, fecha_registro) VALUES
    (1, 'Ana García',  'ana.garcia@email.com',  '3001234567', '2024-01-10'),
    (2, 'Luis Pérez',  'luis.perez@email.com',  '3109876543', '2024-02-15'),
    (3, 'María López', 'maria.lopez@email.com', '3205554433', '2024-03-20');

INSERT INTO libro (ISBN, titulo, anio, genero, estado) VALUES
    ('978-0-06-112008-4', 'Cien años de soledad', 1967, 'Novela',         'disponible'),
    ('978-0-7432-7356-5', 'El alquimista',        1988, 'Ficcion',        'disponible'),
    ('978-0-14-028329-7', 'El principito',        1943, 'Lit. infantil',  'prestado');

INSERT INTO categoria (id_categoria, nombre) VALUES
    (1, 'Literatura latinoamericana'),
    (2, 'Ficcion contemporanea'),
    (3, 'Clasicos universales');

INSERT INTO libro_categoria (isbn_libro, id_categoria) VALUES
    ('978-0-06-112008-4', 1),
    ('978-0-06-112008-4', 3),
    ('978-0-7432-7356-5', 2),
    ('978-0-14-028329-7', 3);

INSERT INTO prestamo (id_prestamo, isbn_libro, id_usuario, fecha_prestamo, fecha_devolucion) VALUES
    (1, '978-0-14-028329-7', 3, '2024-11-01', '2024-11-15'),
    (2, '978-0-06-112008-4', 1, '2024-11-10', NULL);

INSERT INTO resena (id_resena, isbn_libro, id_usuario, calificacion, comentario, fecha) VALUES
    (1, '978-0-06-112008-4', 1, 5, 'Una obra maestra de la literatura universal.', '2024-11-20'),
    (2, '978-0-7432-7356-5', 2, 4, 'Muy inspirador, lo recomiendo ampliamente.',  '2024-11-22'),
    (3, '978-0-14-028329-7', 3, 5, 'Un clasico que nunca pasa de moda.',           '2024-11-16');

-- ============================================================
--  CONSULTAS SQL
-- ============================================================

-- Consulta 1: Listar todos los libros disponibles
SELECT ISBN, titulo, anio, genero
FROM libro
WHERE estado = 'disponible';

-- Consulta 2: Préstamos activos con nombre de usuario y título del libro
SELECT
    p.id_prestamo,
    u.nombre         AS usuario,
    l.titulo         AS libro,
    p.fecha_prestamo,
    p.fecha_devolucion
FROM prestamo p
JOIN usuario u ON p.id_usuario = u.id_usuario
JOIN libro   l ON p.isbn_libro = l.ISBN
WHERE p.fecha_devolucion IS NULL;

-- Consulta 3: Reseñas con calificación mayor o igual a 4
SELECT
    u.nombre         AS usuario,
    l.titulo         AS libro,
    r.calificacion,
    r.comentario,
    r.fecha
FROM resena r
JOIN usuario u ON r.id_usuario = u.id_usuario
JOIN libro   l ON r.isbn_libro = l.ISBN
WHERE r.calificacion >= 4
ORDER BY r.calificacion DESC;