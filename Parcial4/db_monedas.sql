CREATE DATABASE db_monedas;

GO
USE db_monedas;
GO
 
IF OBJECT_ID('dbo.cambiomoneda', 'U') IS NOT NULL DROP TABLE dbo.cambiomoneda;
IF OBJECT_ID('dbo.pais', 'U') IS NOT NULL DROP TABLE dbo.pais;
IF OBJECT_ID('dbo.moneda', 'U') IS NOT NULL DROP TABLE dbo.moneda;
GO
 
CREATE TABLE moneda (
    IdMoneda INT PRIMARY KEY,
    Moneda VARCHAR(100),
    Sigla VARCHAR(5),
    Simbolo VARCHAR(5),
    Emisor VARCHAR(100),
    Imagen VARBINARY(MAX)
);
GO
 
CREATE TABLE pais (
    Id INT PRIMARY KEY,
    Pais VARCHAR(50),
    CodigoAlfa2 VARCHAR(5),
    CodigoAlfa3 VARCHAR(5),
    IdMoneda INT,
    Mapa VARBINARY(MAX),
    Bandera VARBINARY(MAX),
    FOREIGN KEY (IdMoneda) REFERENCES moneda(IdMoneda)
);
GO
 
CREATE TABLE cambiomoneda (
    IdCambio INT PRIMARY KEY IDENTITY(1,1),
    IdMoneda INT,
    Fecha DATETIME,
    Cambio FLOAT,
    FOREIGN KEY (IdMoneda) REFERENCES moneda(IdMoneda)
);
GO
 
INSERT INTO moneda (IdMoneda, Moneda, Sigla) VALUES
(49, 'Euro', 'EUR'),
(149, 'Dólar estadounidense', 'USD'),
(166, 'Dólar del Caribe Oriental', 'XCD'),
(8, 'Dólar australiano', 'AUD'),
(52, 'Libra esterlina', 'GBP'),
(159, 'Franco CFA de África Central', 'XAF'),
(109, 'Dólar neozelandés', 'NZD');
 
INSERT INTO pais (Id, Pais, IdMoneda) VALUES
(1, 'Alemania', 49),
(2, 'Francia', 49),
(3, 'Italia', 49),
(4, 'Estados Unidos', 149),
(5, 'Ecuador', 149),
(6, 'Reino Unido', 52),
(7, 'Antigua y Barbuda', 166),
(8, 'Australia', 8);
 
INSERT INTO cambiomoneda (IdMoneda, Fecha, Cambio) VALUES
(49, '2025-11-12 00:00:00', 0.86244070720138),
(49, '2025-11-10 00:00:00', 0.8620),
(49, '2025-10-15 00:00:00', 0.8630),
(49, '2025-09-01 00:00:00', 0.8500),
(52, '2025-11-12 00:00:00', 0.781527624414576),
(52, '2025-11-01 00:00:00', 0.7500),
(52, '2025-10-20 00:00:00', 0.7300);
GO
 
DECLARE @FECHA_REPORTE DATETIME;
SET @FECHA_REPORTE = '2025-11-12 00:00:00';
 
WITH 
PaisesPorMoneda AS (
    SELECT 
        IdMoneda, 
        COUNT(*) AS TotalPaises
    FROM pais
    GROUP BY IdMoneda
),
 
Promedio30Dias AS (
    SELECT 
        IdMoneda,
        AVG(Cambio) AS Promedio30Dias
    FROM cambiomoneda
    WHERE Fecha >= DATEADD(DAY, -30, @FECHA_REPORTE)
    GROUP BY IdMoneda
),
 
CambiosRankeados AS (
    SELECT 
        IdMoneda,
        Fecha,
        Cambio,
        ROW_NUMBER() OVER(PARTITION BY IdMoneda ORDER BY Fecha DESC) as rn
    FROM cambiomoneda
),
 
UltimoCambio AS (
    SELECT 
        IdMoneda,
        Fecha AS UltimaFecha,
        Cambio AS UltimoCambio
    FROM CambiosRankeados
    WHERE rn = 1
),
 
CalculoVolatilidad AS (
    SELECT
        IdMoneda,
        STDEV(Cambio) AS VolatilidadValor
    FROM cambiomoneda
    GROUP BY IdMoneda
)
 
-- Union de resultados
SELECT 
    m.IdMoneda AS Id,
    m.Moneda,
    m.Sigla,
    ISNULL(p.TotalPaises, 0) AS TotalPaises,
    uc.UltimaFecha,
    uc.UltimoCambio,
    p30.Promedio30Dias,
    CASE 
        WHEN cv.VolatilidadValor > 0.05 THEN 'Volátil' 
        ELSE 'Estable' 
    END AS Volatilidad,
    RANK() OVER (ORDER BY ISNULL(p.TotalPaises, 0) DESC) AS RankingUso
FROM 
    moneda m
LEFT JOIN 
    PaisesPorMoneda p ON m.IdMoneda = p.IdMoneda
LEFT JOIN 
    Promedio30Dias p30 ON m.IdMoneda = p30.IdMoneda
LEFT JOIN 
    UltimoCambio uc ON m.IdMoneda = uc.IdMoneda
LEFT JOIN 
    CalculoVolatilidad cv ON m.IdMoneda = cv.IdMoneda
ORDER BY 
    RankingUso, m.Moneda;
GO

-- =====================================================================
-- BORRAR BDD
-- =====================================================================


--USE master;
--GO
--ALTER DATABASE db_monedas SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--GO
--DROP DATABASE db_monedas
--GO