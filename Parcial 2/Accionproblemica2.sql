CREATE DATABASE DiscografiaDB;
GO
USE DiscografiaDB;
GO
DROP TABLE IF EXISTS Album;
DROP TABLE IF EXISTS Cancion;
DROP TABLE IF EXISTS CancionCompositor;
DROP TABLE IF EXISTS Compositor;
DROP TABLE IF EXISTS Formato;
DROP TABLE IF EXISTS Grabacion;
DROP TABLE IF EXISTS Idioma;
DROP TABLE IF EXISTS Interpretacion;
DROP TABLE IF EXISTS Interprete;
DROP TABLE IF EXISTS Medio;
DROP TABLE IF EXISTS Pais;
DROP TABLE IF EXISTS Ritmo;
DROP TABLE IF EXISTS Tipo;
GO
-- 2. Creación de tablas

-- Tabla Tipo (de Intérprete)
CREATE TABLE Tipo (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL
);

-- Tabla Pais
CREATE TABLE Pais (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL
);

-- Tabla Ritmo
CREATE TABLE Ritmo (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL
);

-- Tabla Formato
CREATE TABLE Formato (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL
);

-- Tabla Medio
CREATE TABLE Medio (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL
);

-- Tabla Idioma
CREATE TABLE Idioma (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(50) NOT NULL
);

-- Tabla Interprete
CREATE TABLE Interprete (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    IdTipoInterprete INT NOT NULL,
    IdPais INT NOT NULL,
    Foto VARBINARY(MAX),
    FOREIGN KEY (IdTipoInterprete) REFERENCES Tipo(Id),
    FOREIGN KEY (IdPais) REFERENCES Pais(Id)
);

-- Tabla Compositor
CREATE TABLE Compositor (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    IdPais INT NOT NULL,
    FOREIGN KEY (IdPais) REFERENCES Pais(Id)
);

-- Tabla Cancion
CREATE TABLE Cancion (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Titulo VARCHAR(200) NOT NULL,
    IdIdioma INT NOT NULL,
    FOREIGN KEY (IdIdioma) REFERENCES Idioma(Id)
);

-- Tabla Album
CREATE TABLE Album (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(200) NOT NULL,
    IdRegistro INT, 
    IdMedio INT NOT NULL,
    FOREIGN KEY (IdMedio) REFERENCES Medio(Id)
);

-- Tabla Grabacion (Tabla de Hechos para las grabaciones)
CREATE TABLE Grabacion (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdAlbum INT NOT NULL,
    IdFormato INT NOT NULL,
    FOREIGN KEY (IdAlbum) REFERENCES Album(Id),
    FOREIGN KEY (IdFormato) REFERENCES Formato(Id)
);

-- Tablas de relación N:M

-- Tabla Interpretacion (Relación entre Interprete, Cancion y Ritmo)
CREATE TABLE Interpretacion (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdInterprete INT NOT NULL,
    IdCancion INT NOT NULL,
    Duracion TIME, -- Duración de la interpretación de la canción
    IdRitmo INT NOT NULL,
    FOREIGN KEY (IdInterprete) REFERENCES Interprete(Id),
    FOREIGN KEY (IdCancion) REFERENCES Cancion(Id),
    FOREIGN KEY (IdRitmo) REFERENCES Ritmo(Id)
);

-- Tabla CancionCompositor (Relación entre Cancion y Compositor)
CREATE TABLE CancionCompositor (
    IdCancion INT NOT NULL,
    IdCompositor INT NOT NULL,
    PRIMARY KEY (IdCancion, IdCompositor),
    FOREIGN KEY (IdCancion) REFERENCES Cancion(Id),
    FOREIGN KEY (IdCompositor) REFERENCES Compositor(Id)
);
-- 1. Inserción en tablas de catálogo (lookup tables)
INSERT INTO Pais (Nombre) VALUES ('Colombia'), ('España'), ('México'), ('Puerto Rico'), ('Argentina');
INSERT INTO Tipo (Nombre) VALUES ('Solista'), ('Grupo');
INSERT INTO Ritmo (Nombre) VALUES ('Balada'), ('Salsa'), ('Rock'), ('Pop'), ('Vallenato');
INSERT INTO Idioma (Nombre) VALUES ('Español'), ('Inglés');
INSERT INTO Formato (Nombre) VALUES ('CD'), ('Vinilo'), ('Digital'), ('Casete');
INSERT INTO Medio (Nombre) VALUES ('Físico'), ('Digital');
GO

-- 2. Inserción de Compositores e Intérpretes
INSERT INTO Compositor (Nombre, IdPais) VALUES 
('Juan Esteban Aristizábal Vásquez (JUANES)', 1), -- ID 1, País Colombia
('José Alfredo Jiménez', 3),                   -- ID 2, País México
('Augusto Algueró', 2),                        -- ID 3, País España
('Shakira Mebarak', 1);                         -- ID 4, País Colombia

INSERT INTO Interprete (Nombre, IdTipoInterprete, IdPais) VALUES
('JUANES', 1, 1),                              -- ID 1, Solista de Colombia
('El Gran Combo de Puerto Rico', 2, 4),        -- ID 2, Grupo de Puerto Rico
('Rocío Dúrcal', 1, 2),                        -- ID 3, Solista de España
('Shakira', 1, 1),                             -- ID 4, Solista de Colombia
('La Malagueña Interpretes Varios', 2, 3),     -- ID 5, Grupo de México
('Charles Chaplin', 1, 5);                     -- ID 6, Solista (para Candilejas)

-- 3. Inserción de Canciones
INSERT INTO Cancion (Titulo, IdIdioma) VALUES
('La Camisa Negra', 1),   -- ID 1 (Compuesta por Juanes)
('A Dios le Pido', 1),    -- ID 2 (Compuesta por Juanes)
('Es Por Ti', 1),         -- ID 3 (Compuesta por Juanes)
('Lluvia', 1),            -- ID 4 (Para ejercicio 'b')
('Amor Eterno', 1),       -- ID 5 (Balada para ejercicio 'c')
('Candilejas', 1),        -- ID 6 (Para ejercicio 'e')
('Malagueña', 1);         -- ID 7 (Para ejercicio 'e')

-- 4. Relacionar Canciones con Compositores (CancionCompositor)
INSERT INTO CancionCompositor (IdCancion, IdCompositor) VALUES
(1, 1), -- La Camisa Negra por Juanes
(2, 1), -- A Dios le Pido por Juanes
(3, 1), -- Es Por Ti por Juanes
(4, 3), -- Lluvia por Augusto Algueró
(5, 4), -- Amor Eterno por Shakira
(6, 1), -- Candilejas, asumamos que la compone Juanes para el ejemplo
(7, 2); -- Malagueña por José Alfredo Jiménez

-- 5. Inserción de Álbumes, Medios y Formatos (Datos de ejemplo)
INSERT INTO Album (Nombre, IdRegistro, IdMedio) VALUES
('Mi Sangre', 12345, 1),  -- ID 1, Medio Físico
('Un Día Normal', 67890, 1); -- ID 2, Medio Físico

INSERT INTO Grabacion (IdAlbum, IdFormato) VALUES
(1, 1), -- Mi Sangre en CD
(2, 1); -- Un Día Normal en CD

-- 6. Inserción de Interpretaciones (clave para la mayoría de ejercicios)
INSERT INTO Interpretacion (IdInterprete, IdCancion, Duracion, IdRitmo) VALUES
-- Interpretaciones de Juanes (para ejercicio 'a' y 'f')
(1, 1, '00:03:36', 3), -- Juanes - La Camisa Negra - Rock
(1, 2, '00:03:25', 4), -- Juanes - A Dios le Pido - Pop
(1, 3, '00:04:10', 4), -- Juanes - Es Por Ti - Pop
-- Interpretaciones de Lluvia (para ejercicio 'b')
(3, 4, '00:03:30', 1), -- Rocío Dúrcal - Lluvia - Balada
-- Interpretación para ejercicio 'c' (Intérprete y compositor son la misma persona en ritmo Balada)
(4, 5, '00:04:00', 1), -- Shakira - Amor Eterno - Balada
-- Interpretaciones para ejercicio 'd' (Grupos de Salsa)
(2, 4, '00:05:15', 2), -- El Gran Combo - Lluvia - Salsa
-- Interpretaciones para ejercicio 'e'
(6, 6, '00:03:00', 1), -- Charles Chaplin - Candilejas - Balada
(5, 7, '00:03:45', 5), -- La Malagueña Interpretes Varios - Malagueña - Vallenato
(3, 7, '00:03:50', 1); -- Rocío Dúrcal - Malagueña - Balada

-----------

-- 3. Scripts para las consultas detalladas en el ejercicio

-- a. ¿Cuántas canciones ha compuesto "JUANES"? (Usando CHARINDEX)

SELECT
    C.Nombre AS Compositor,
    COUNT(CC.IdCancion) AS NumeroDeCancionesCompuestas
FROM
    Compositor AS C
JOIN
    CancionCompositor AS CC ON C.Id = CC.IdCompositor
WHERE
    CHARINDEX('JUANES', C.Nombre) > 0
GROUP BY
    C.Nombre;

-- b. ¿Qué interpretaciones se tienen de la canción "Lluvia" y en qué ritmos?
SELECT
    I.Nombre AS Interprete,
    C.Titulo AS Cancion,
    R.Nombre AS Ritmo,
    INTER.Duracion
FROM
    Interpretacion AS INTER
JOIN
    Interprete AS I ON INTER.IdInterprete = I.Id
JOIN
    Cancion AS C ON INTER.IdCancion = C.Id
JOIN
    Ritmo AS R ON INTER.IdRitmo = R.Id
WHERE
    C.Titulo = 'Lluvia';

-- c. ¿Qué canciones hay con el mismo Intérprete y Compositor del ritmo "Balada"?
-- Tener en cuenta que solo aplica para solistas y que el nombre del compositor
-- viene completo (nombre de pila y seudónimo) mientras que el del interprete es el
-- seudónimo solamente.

DECLARE @IdRitmoBalada INT;
SELECT @IdRitmoBalada = Id FROM Ritmo WHERE Nombre = 'Balada';

SELECT DISTINCT
    CA.Titulo AS Cancion,
    INT.Nombre AS Interprete,
    COMP.Nombre AS Compositor
FROM
    Cancion AS CA
JOIN
    CancionCompositor AS CACM ON CA.Id = CACM.IdCancion
JOIN
    Compositor AS COMP ON CACM.IdCompositor = COMP.Id
JOIN
    Interpretacion AS INTERP ON CA.Id = INTERP.IdCancion
JOIN
    Interprete AS INT ON INTERP.IdInterprete = INT.Id
JOIN
    Tipo AS TI ON INT.IdTipoInterprete = TI.Id
WHERE
    TI.Nombre = 'Solista' -- Solo aplica para solistas
    AND INTERP.IdRitmo = @IdRitmoBalada; -- Del ritmo "Balada"
  

-- d. ¿Listar los países que tienen grupos del ritmo "Salsa"?
SELECT DISTINCT
    P.Nombre AS Pais, I.Nombre
FROM
    Pais AS P
JOIN
    Interprete AS I ON P.Id = I.IdPais
JOIN
    Tipo AS T ON I.IdTipoInterprete = T.Id
JOIN
    Interpretacion AS INTER ON I.Id = INTER.IdInterprete
JOIN
    Ritmo AS R ON INTER.IdRitmo = R.Id
WHERE
    T.Nombre = 'Grupo' -- Tipo de intérprete "Grupo"
    AND R.Nombre = 'Salsa'; -- Del ritmo "Salsa"

-- e. ¿Quiénes interpretan las canciones "Candilejas" y "Malagueña"?
SELECT DISTINCT
    I.Nombre AS Interprete,
    C.Titulo AS Cancion
FROM
    Interprete AS I
JOIN
    Interpretacion AS INTER ON I.Id = INTER.IdInterprete
JOIN
    Cancion AS C ON INTER.IdCancion = C.Id
WHERE
    C.Titulo IN ('Candilejas', 'Malagueña');

-- f. Listar artistas que son intérpretes y compositores a la vez y con cuantas canciones compuestas e interpretadas
SELECT
    I.Nombre AS NombreArtista,
    COUNT(DISTINCT CC.IdCancion) AS CancionesCompuestas,
    COUNT(DISTINCT INTER.IdCancion) AS CancionesInterpretadas
FROM
    Interprete AS I
JOIN
    Compositor AS C ON C.Nombre LIKE '%' + I.Nombre  + '%'
LEFT JOIN
    CancionCompositor AS CC ON C.Id = CC.IdCompositor
LEFT JOIN
    Interpretacion AS INTER ON I.Id = INTER.IdInterprete
GROUP BY
    I.Nombre
HAVING
    COUNT(DISTINCT CC.IdCancion) > 0 AND COUNT(DISTINCT INTER.IdCancion) > 0;
    
-- =====================================================================
-- BORRAR BDD
-- =====================================================================


--USE master;
--GO
--ALTER DATABASE DiscografiaDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--GO
--DROP DATABASE DiscografiaDB
--GO