--USE biblioteca;
--GO

-- Si no existe:
 CREATE DATABASE biblioteca;
 GO
 USE biblioteca;
 GO

DROP TABLE IF EXISTS PUBLICACION_DESCRIPTOR;
DROP TABLE IF EXISTS PUBLICACION_AUTOR;
DROP TABLE IF EXISTS PUBLICACION;
DROP TABLE IF EXISTS TIPO_PUBLICACION;
DROP TABLE IF EXISTS AUTOR;
DROP TABLE IF EXISTS EDITORIAL;
DROP TABLE IF EXISTS UBICACION;
DROP TABLE IF EXISTS DESCRIPTOR;
GO

-- =====================================================================
-- 1. CREACIÓN DE TABLAS PRINCIPALES
-- =====================================================================

CREATE TABLE TIPO_PUBLICACION (
    id_tipo_publicacion INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE UBICACION (
    id_ubicacion INT IDENTITY(1,1) PRIMARY KEY,
    pais VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    direccion VARCHAR(255)
);

CREATE TABLE EDITORIAL (
    id_editorial INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    id_ubicacion INT,
    CONSTRAINT fk_ubicacion FOREIGN KEY(id_ubicacion) REFERENCES UBICACION(id_ubicacion) ON DELETE SET NULL
);

CREATE TABLE AUTOR (
    id_autor INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    es_corporativo BIT NOT NULL DEFAULT 0
);

CREATE TABLE DESCRIPTOR (
    id_descriptor INT IDENTITY(1,1) PRIMARY KEY,
    termino VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE PUBLICACION (
    id_publicacion INT IDENTITY(1,1) PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    fecha_publicacion DATE,
    isbn VARCHAR(20),
    issn VARCHAR(20),
    volumen VARCHAR(50),
    id_tipo_publicacion INT NOT NULL,
    id_editorial INT,
    CONSTRAINT fk_tipo_publicacion FOREIGN KEY(id_tipo_publicacion) REFERENCES TIPO_PUBLICACION(id_tipo_publicacion),
    CONSTRAINT fk_editorial FOREIGN KEY(id_editorial) REFERENCES EDITORIAL(id_editorial) ON DELETE SET NULL
);
GO

-- =====================================================================
-- CREACIÓN DE ÍNDICES ÚNICOS
-- =====================================================================
CREATE UNIQUE INDEX UQ_PUBLICACION_ISBN ON PUBLICACION(isbn) WHERE isbn IS NOT NULL;
CREATE UNIQUE INDEX UQ_PUBLICACION_ISSN ON PUBLICACION(issn) WHERE issn IS NOT NULL;
GO

-- =====================================================================
-- 2. CREACIÓN DE TABLAS INTERMEDIAS
-- =====================================================================
CREATE TABLE PUBLICACION_AUTOR (
    id_publicacion INT,
    id_autor INT,
    PRIMARY KEY (id_publicacion, id_autor),
    CONSTRAINT fk_pa_publicacion FOREIGN KEY(id_publicacion) REFERENCES PUBLICACION(id_publicacion) ON DELETE CASCADE,
    CONSTRAINT fk_pa_autor FOREIGN KEY(id_autor) REFERENCES AUTOR(id_autor) ON DELETE CASCADE
);

CREATE TABLE PUBLICACION_DESCRIPTOR (
    id_publicacion INT,
    id_descriptor INT,
    PRIMARY KEY (id_publicacion, id_descriptor),
    CONSTRAINT fk_pd_publicacion FOREIGN KEY(id_publicacion) REFERENCES PUBLICACION(id_publicacion) ON DELETE CASCADE,
    CONSTRAINT fk_pd_descriptor FOREIGN KEY(id_descriptor) REFERENCES DESCRIPTOR(id_descriptor) ON DELETE CASCADE
);
GO

-- =====================================================================
-- 3. INSERCIÓN DE DATOS
-- =====================================================================
INSERT INTO TIPO_PUBLICACION (nombre) VALUES ('Libro'), ('Revista'), ('Tesis'), ('Periódico');
INSERT INTO UBICACION (pais, ciudad, direccion) VALUES ('Colombia', 'Bogotá', 'Calle Falsa 123'), ('España', 'Madrid', 'Avenida Siempre Viva 742');
INSERT INTO EDITORIAL (nombre, id_ubicacion) VALUES ('Editorial Planeta', 2), ('Publicaciones UNAL', 1);
INSERT INTO AUTOR (nombre, es_corporativo) VALUES ('Gabriel García Márquez', 0), ('Fernando Vallejo', 0), ('Universidad Nacional de Colombia', 1);
INSERT INTO DESCRIPTOR (termino) VALUES ('Realismo Mágico'), ('Bases de Datos'), ('Ingeniería de Software'), ('Literatura Colombiana');
GO

INSERT INTO PUBLICACION (titulo, fecha_publicacion, isbn, id_tipo_publicacion, id_editorial) VALUES ('Cien Años de Soledad', '1967-05-30', '978-0307474728', 1, 1);
INSERT INTO PUBLICACION (titulo, fecha_publicacion, issn, volumen, id_tipo_publicacion, id_editorial) VALUES ('Revista de Ingeniería', '2023-06-15', '1657-9263', 'Vol. 28, No. 2', 2, 2);
INSERT INTO PUBLICACION (titulo, fecha_publicacion, id_tipo_publicacion, id_editorial) VALUES ('Modelo Relacional para Sistemas Bibliográficos', '2024-01-20', 3, 2);
GO

INSERT INTO PUBLICACION_AUTOR (id_publicacion, id_autor) VALUES (1, 1), (2, 3), (3, 2);
INSERT INTO PUBLICACION_DESCRIPTOR (id_publicacion, id_descriptor) VALUES (1, 1), (1, 4), (2, 2), (2, 3), (3, 2);
GO

SELECT 'Base de datos para SQL Server creada y poblada con éxito.' AS "Estado";
GO

-- =====================================================================
-- 4. CONSULTAS DE VERIFICACIÓN DE DATOS
-- =====================================================================
GO
SELECT * FROM PUBLICACION;
GO

SELECT * FROM AUTOR;
GO

SELECT * FROM DESCRIPTOR;
GO

SELECT
    P.titulo AS 'Título de la Publicación',
    A.nombre AS 'Nombre del Autor'
FROM
    PUBLICACION AS P
INNER JOIN
    PUBLICACION_AUTOR AS PA ON P.id_publicacion = PA.id_publicacion
INNER JOIN
    AUTOR AS A ON PA.id_autor = A.id_autor
ORDER BY
    P.titulo;
GO

SELECT
    P.titulo AS 'Título de la Publicación',
    D.termino AS 'Descriptor'
FROM
    PUBLICACION AS P
INNER JOIN
    PUBLICACION_DESCRIPTOR AS PD ON P.id_publicacion = PD.id_publicacion
INNER JOIN
    DESCRIPTOR AS D ON PD.id_descriptor = D.id_descriptor
ORDER BY
    P.titulo;
GO

SELECT
    P.titulo AS 'Título',
    P.fecha_publicacion AS 'Fecha de Publicación',
    TP.nombre AS 'Tipo',
    E.nombre AS 'Editorial',
    A.nombre AS 'Autor'
FROM
    PUBLICACION AS P
LEFT JOIN
    TIPO_PUBLICACION AS TP ON P.id_tipo_publicacion = TP.id_tipo_publicacion
LEFT JOIN
    EDITORIAL AS E ON P.id_editorial = E.id_editorial
LEFT JOIN
    PUBLICACION_AUTOR AS PA ON P.id_publicacion = PA.id_publicacion
LEFT JOIN
    AUTOR AS A ON PA.id_autor = A.id_autor
ORDER BY
    P.titulo;
GO

-- =====================================================================
--5. BORRAR BDD
-- =====================================================================


--USE master;
--GO
--ALTER DATABASE biblioteca SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--GO
--DROP DATABASE biblioteca
--GO