CREATE DATABASE DivisionPolitica;
GO
 
USE DivisionPolitica;
GO
 
CREATE TABLE Continente (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(100) NOT NULL
);
 
CREATE TABLE TipoRegion (
    Id int IDENTITY(1,1) PRIMARY KEY,
    TipoRegion varchar(100) NOT NULL
);
 
CREATE TABLE Pais (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(100) NOT NULL,
    IdContinente int FOREIGN KEY REFERENCES Continente(Id),
    IdTipoRegion int FOREIGN KEY REFERENCES TipoRegion(Id),
    Moneda varchar(50) NULL
);
 
CREATE TABLE Region (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(100) NOT NULL,
    Area float NULL,
    Poblacion int NULL,
    IdPais int FOREIGN KEY REFERENCES Pais(Id)
);
 
CREATE TABLE Ciudad (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(100) NOT NULL,
    IdRegion int FOREIGN KEY REFERENCES Region(Id),
    CapitalRegion bit NULL,
    CapitalPais bit NULL,
    AreaMetropolitana float NULL,
    Area float NULL,
    Poblacion int NULL
);
GO
 
-- =====================================================================
-- EJERCICIO 1: IMPORTAR DATOS DE JAPÓN (Usando BULK INSERT)
-- =====================================================================
 
CREATE TABLE #Japon(
    Prefectura varchar(50) NOT NULL,
    Capital varchar(50) NOT NULL,
    Area float NULL,
    Poblacion int NULL
);
GO
 
BULK INSERT #Japon
FROM 'C:\BDD_DATA\Japon.csv'
WITH (
    DATAFILETYPE = 'char',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
GO
 
DECLARE @IdPais int;
DECLARE @IdTR int;
DECLARE @IdC int;
 
SET @IdPais=(SELECT TOP 1 Id FROM Pais WHERE Nombre='Japón');
 
IF @IdPais IS NULL
BEGIN
    PRINT 'El país Japón no existe, se creará...';
 
    SET @IdTR=(SELECT TOP 1 Id FROM TipoRegion WHERE TipoRegion='Prefectura');
    IF @IdTR IS NULL
    BEGIN
        INSERT INTO TipoRegion (TipoRegion) VALUES('Prefectura');
        SET @IdTR = @@IDENTITY;
    END
 
    SET @IdC=(SELECT TOP 1 Id FROM Continente WHERE Nombre='Asia');
    IF @IdC IS NULL
    BEGIN
        INSERT INTO Continente (Nombre) VALUES('Asia');
        SET @IdC = @@IDENTITY;
    END
 
    INSERT INTO Pais (Nombre, IdContinente, IdTipoRegion, Moneda)
    VALUES('Japón', @IdC, @IdTR, 'Yen'); 
    SET @IdPais = @@IDENTITY;
END;
 
INSERT INTO Region
(Nombre, IdPais, Area, Poblacion)
SELECT J.Prefectura, @IdPais, J.Area, J.Poblacion
FROM #Japon J;
 
INSERT INTO Ciudad
(Nombre, IdRegion, CapitalRegion)
SELECT J.Capital, R.Id, 1
FROM #Japon J
JOIN Region R ON J.Prefectura = R.Nombre AND R.IdPais = @IdPais;
 
PRINT 'Datos de Japón insertados:';
SELECT *
FROM Pais P
JOIN Region R ON P.Id = R.IdPais
JOIN Ciudad C ON R.Id = C.IdRegion
WHERE P.Nombre = 'Japón';
GO
 
DROP TABLE #Japon;
GO
 
-- =====================================================================
-- EJERCICIO 2: NORMALIZAR MONEDA Y AGREGAR MAPA/BANDERA (NOTA: Profe el diagrama muestra como normalizar pero el enunciado pide desnormalizar, como indicaba que el ejercicio 2 se hahcia apartir del 1 lo logico era normalizar y así lo realicé)
-- =====================================================================
 
PRINT '1. Creando la tabla Moneda...';
CREATE TABLE Moneda (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Moneda varchar(100) NOT NULL UNIQUE,
    Sigla varchar(5) NULL,
    Imagen varbinary(max) NULL
);
GO
 
PRINT '2. Agregando columna IdMoneda a Pais...';
ALTER TABLE Pais
ADD IdMoneda int NULL;
GO
 
PRINT '3. Migrando datos de monedas existentes...';
INSERT INTO Moneda (Moneda)
SELECT DISTINCT Moneda
FROM Pais
WHERE Moneda IS NOT NULL AND LTRIM(RTRIM(Moneda)) <> '';
GO
 
PRINT '4. Actualizando las referencias de IdMoneda en Pais...';
UPDATE P
SET P.IdMoneda = M.Id
FROM Pais P
JOIN Moneda M ON P.Moneda = M.Moneda;
GO
 
PRINT '5. Agregando la restricción de FK...';
ALTER TABLE Pais
ADD CONSTRAINT FK_Pais_Moneda FOREIGN KEY (IdMoneda) REFERENCES Moneda(Id);
GO
 
PRINT '6. Eliminando la columna redundante Pais.Moneda...';
ALTER TABLE Pais
DROP COLUMN Moneda;
GO
 
PRINT '7. Agregando columnas Mapa y Bandera a Pais...';
ALTER TABLE Pais
ADD
    Mapa varbinary(max) NULL,
    Bandera varbinary(max) NULL;
GO
 
PRINT 'Actualización del esquema completada.';
GO
 
EXEC sp_help 'Pais';
GO

-- =====================================================================
-- BORRAR BDD
-- =====================================================================

--USE master;
--GO
--ALTER DATABASE DivisionPolitica SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--GO
--DROP DATABASE DivisionPolitica
--GO