USE master
GO

IF EXISTS(SELECT *
          FROM sys.databases
          WHERE name = 'indec')
    BEGIN
        ALTER DATABASE indec SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
        DROP DATABASE indec;
    END
GO

CREATE DATABASE indec;
GO

USE indec
GO

/* -------------------------------------
   TIPOS DE DATOS PERSONALIZADOS
   ------------------------------------- */
IF TYPE_ID('codigopais') IS NULL
CREATE TYPE codigopais FROM VARCHAR(3)
GO

IF TYPE_ID('codigoprovincia') IS NULL
CREATE TYPE codigoprovincia FROM VARCHAR(3)
GO

/* -------------------------------------
   CREACIÓN DE TABLAS BASE
   ------------------------------------- */
CREATE TABLE dbo.paises
(
    cod_pais codigopais PRIMARY KEY,
    nom_pais VARCHAR(100) NOT NULL,
    local BIT NOT NULL
)

CREATE TABLE dbo.provincias
(
    cod_pais codigopais NOT NULL,
    cod_provincia codigoprovincia NOT NULL,
    nom_provincia VARCHAR(100) NOT NULL,
    PRIMARY KEY (cod_pais, cod_provincia),
    FOREIGN KEY (cod_pais) REFERENCES dbo.paises (cod_pais)
)

CREATE TABLE dbo.localidades
(
    nro_localidad INT PRIMARY KEY IDENTITY(1,1),
    cod_pais codigopais NOT NULL,
    cod_provincia codigoprovincia NOT NULL,
    nom_localidad VARCHAR(100) NOT NULL,
    UNIQUE (nom_localidad, cod_pais, cod_provincia),
    FOREIGN KEY (cod_pais, cod_provincia) REFERENCES dbo.provincias (cod_pais, cod_provincia)
)

CREATE TABLE dbo.idiomas
(
    cod_idioma VARCHAR(2) PRIMARY KEY,
    nom_idioma VARCHAR(50) NOT NULL
)

CREATE TABLE dbo.supermercados
(
    nro_supermercado INT PRIMARY KEY IDENTITY(1,1),
    razon_social VARCHAR(100) NOT NULL,
    cuit VARCHAR(13) NOT NULL
)

CREATE TABLE dbo.servicios_supermercados
(
    nro_supermercado INT NOT NULL,
    url_servicio VARCHAR(500) NOT NULL,
    tipo_servicio VARCHAR(10) NOT NULL CHECK (tipo_servicio IN ('SOAP', 'REST')),
    token_servicio VARCHAR(500) NOT NULL,
    fecha_ult_act_servicio DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (nro_supermercado),
    FOREIGN KEY (nro_supermercado) REFERENCES dbo.supermercados (nro_supermercado)
)

CREATE TABLE dbo.sucursales
(
    nro_supermercado INT NOT NULL,
    nro_sucursal INT NOT NULL,
    nom_sucursal VARCHAR(100) NOT NULL,
    calle VARCHAR(100) NOT NULL,
    nro_calle VARCHAR(10) NOT NULL,
    telefonos VARCHAR(100),
    coord_latitud DECIMAL(9,6),
    coord_longitud DECIMAL(9,6),
    horario_sucursal VARCHAR(200),
    servicios_disponibles VARCHAR(200),
    nro_localidad INT NOT NULL,
    habilitada BIT NOT NULL DEFAULT 1,
    PRIMARY KEY (nro_supermercado, nro_sucursal),
    FOREIGN KEY (nro_supermercado) REFERENCES dbo.supermercados (nro_supermercado),
    FOREIGN KEY (nro_localidad) REFERENCES dbo.localidades (nro_localidad)
)

CREATE TABLE dbo.rubros_productos
(
    nro_rubro INT PRIMARY KEY,
    nom_rubro VARCHAR(100) NOT NULL,
    vigente BIT NOT NULL DEFAULT 1
)

CREATE TABLE dbo.idiomas_rubros_productos
(
    nro_rubro INT NOT NULL,
    cod_idioma VARCHAR(2) NOT NULL,
    rubro VARCHAR(100) NOT NULL,
    PRIMARY KEY (nro_rubro, cod_idioma),
    FOREIGN KEY (nro_rubro) REFERENCES dbo.rubros_productos (nro_rubro),
    FOREIGN KEY (cod_idioma) REFERENCES dbo.idiomas (cod_idioma)
)

CREATE TABLE dbo.categorias_productos
(
    nro_categoria INT PRIMARY KEY,
    nro_rubro INT NOT NULL,
    nom_categoria VARCHAR(100) NOT NULL,
    vigente BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (nro_rubro) REFERENCES dbo.rubros_productos (nro_rubro)
)

CREATE TABLE dbo.idiomas_categorias_productos
(
    nro_categoria INT NOT NULL,
    cod_idioma VARCHAR(2) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    PRIMARY KEY (nro_categoria, cod_idioma),
    FOREIGN KEY (nro_categoria) REFERENCES dbo.categorias_productos (nro_categoria),
    FOREIGN KEY (cod_idioma) REFERENCES dbo.idiomas (cod_idioma)
)

CREATE TABLE dbo.marcas_productos
(
    nro_marca INT PRIMARY KEY,
    nom_marca VARCHAR(100) NOT NULL,
    vigente BIT NOT NULL DEFAULT 1
)

CREATE TABLE dbo.tipos_productos
(
    nro_tipo_producto INT PRIMARY KEY,
    nom_tipo_producto VARCHAR(100) NOT NULL
)

CREATE TABLE dbo.tipos_productos_marcas
(
    nro_marca INT NOT NULL,
    nro_tipo_producto INT NOT NULL,
    vigente BIT NOT NULL DEFAULT 1,
    PRIMARY KEY (nro_marca, nro_tipo_producto),
    FOREIGN KEY (nro_marca) REFERENCES dbo.marcas_productos (nro_marca),
    FOREIGN KEY (nro_tipo_producto) REFERENCES dbo.tipos_productos (nro_tipo_producto)
)

CREATE TABLE dbo.idiomas_tipos_productos
(
    nro_tipo_producto INT NOT NULL,
    cod_idioma VARCHAR(2) NOT NULL,
    tipo_producto VARCHAR(100) NOT NULL,
    PRIMARY KEY (nro_tipo_producto, cod_idioma),
    FOREIGN KEY (nro_tipo_producto) REFERENCES dbo.tipos_productos (nro_tipo_producto),
    FOREIGN KEY (cod_idioma) REFERENCES dbo.idiomas (cod_idioma)
)

CREATE TABLE dbo.productos
(
    cod_barra VARCHAR(50) PRIMARY KEY,
    nom_producto VARCHAR(100) NOT NULL,
    desc_producto VARCHAR(500),
    nro_categoria INT NOT NULL,
    imagen VARCHAR(500) NULL,
    nro_marca INT NOT NULL,
    nro_tipo_producto INT NOT NULL,
    vigente BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (nro_marca) REFERENCES dbo.marcas_productos (nro_marca),
    FOREIGN KEY (nro_tipo_producto) REFERENCES dbo.tipos_productos (nro_tipo_producto),
    FOREIGN KEY (nro_categoria) REFERENCES dbo.categorias_productos (nro_categoria)
)

CREATE TABLE dbo.productos_supermercados
(
    nro_supermercado INT NOT NULL,
    nro_sucursal INT NOT NULL,
    cod_barra VARCHAR(50) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    fecha_ult_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (cod_barra, nro_supermercado, nro_sucursal),
    FOREIGN KEY (nro_supermercado, nro_sucursal) REFERENCES dbo.sucursales (nro_supermercado, nro_sucursal),
    FOREIGN KEY (cod_barra) REFERENCES dbo.productos (cod_barra)
)

/* -------------------------------------
   datos iniciales
------------------------------------- */
BEGIN TRY
    BEGIN TRANSACTION;

    /* ======= PAISES ======= */
    INSERT INTO dbo.paises (cod_pais, nom_pais, local) VALUES
                                                           ('ARG','Argentina',1),
                                                           ('CHL','Chile',0),
                                                           ('BRA','Brazil',0);

    /* ======= PROVINCIAS ======= */
    INSERT INTO dbo.provincias (cod_pais, cod_provincia, nom_provincia) VALUES
                                                                            ('ARG','BA','Buenos Aires'),
                                                                            ('ARG','CBA','Córdoba'),
                                                                            ('ARG','SF','Santa Fe'),
                                                                            ('CHL','RM','Región Metropolitana'),
                                                                            ('CHL','V','Valparaíso'),
                                                                            ('BRA','SP','São Paulo'),
                                                                            ('BRA','RJ','Rio de Janeiro');

    /* ======= LOCALIDADES ======= */
    INSERT INTO dbo.localidades (cod_pais, cod_provincia, nom_localidad) VALUES
                                                                             ('ARG','BA','Ciudad Autónoma de Buenos Aires'),
                                                                             ('ARG','BA','La Plata'),
                                                                             ('ARG','BA','Mar del Plata'),
                                                                             ('ARG','CBA','Córdoba'),
                                                                             ('ARG','SF','Rosario'),
                                                                             ('ARG','SF','Santa Fe'),
                                                                             ('CHL','RM','Santiago'),
                                                                             ('CHL','RM','Providencia'),
                                                                             ('CHL','V','Valparaíso'),
                                                                             ('BRA','SP','São Paulo'),
                                                                             ('BRA','RJ','Rio de Janeiro');

    /* ======= RUBROS (IDs 1..5) ======= */
    INSERT INTO dbo.rubros_productos (nro_rubro, nom_rubro, vigente) VALUES
                                                                         (1,'Alimentos',1),
                                                                         (2,'Bebidas sin alcohol',1),
                                                                         (3,'Limpieza',1),
                                                                         (4,'Higiene Personal',1),
                                                                         (5,'Otros Esenciales',1);

    /* ======= CATEGORÍAS (IDs 1..15) ======= */
    INSERT INTO dbo.categorias_productos (nro_categoria, nro_rubro, nom_categoria, vigente) VALUES
                                                                                                (1 ,1,'Panificados',1),
                                                                                                (2 ,1,'Harinas y Cereales',1),
                                                                                                (3 ,1,'Pastas y Legumbres',1),
                                                                                                (4 ,1,'Carnes',1),
                                                                                                (5 ,1,'Lácteos y Huevos',1),
                                                                                                (6 ,1,'Frutas y Verduras',1),
                                                                                                (7 ,1,'Azúcar y Dulces',1),
                                                                                                (8 ,1,'Aceites y Grasas',1),
                                                                                                (9 ,2,'Infusiones',1),
                                                                                                (10,2,'Bebidas sin alcohol',1),
                                                                                                (11,3,'Limpieza Hogar',1),
                                                                                                (12,3,'Lavandería',1),
                                                                                                (13,4,'Cuidado Personal',1),
                                                                                                (14,4,'Papel e Higiene',1),
                                                                                                (15,5,'Condimentos y Básicos',1);

    /* ======= MARCAS (IDs 1..20) ======= */
    INSERT INTO dbo.marcas_productos (nro_marca, nom_marca, vigente) VALUES
                                                                         (1 ,'La Serenísima',1),
                                                                         (2 ,'Sancor',1),
                                                                         (3 ,'Arcor',1),
                                                                         (4 ,'Ledesma',1),
                                                                         (5 ,'Molinos',1),
                                                                         (6 ,'Lucchetti',1),
                                                                         (7 ,'Matarazzo',1),
                                                                         (8 ,'Gallo',1),
                                                                         (9 ,'Marolio',1),
                                                                         (10,'Cañuelas',1),
                                                                         (11,'Cocinero',1),
                                                                         (12,'Dia',1),
                                                                         (13,'Ilolay',1),
                                                                         (14,'La Paulina',1),
                                                                         (15,'Taragüi',1),
                                                                         (16,'La Virginia',1),
                                                                         (17,'CBSé',1),
                                                                         (18,'Poett',1),
                                                                         (19,'Higienol',1),
                                                                         (20,'Colgate',1);

    /* ======= TIPOS DE PRODUCTO (IDs 1..5) ======= */
    INSERT INTO dbo.tipos_productos (nro_tipo_producto, nom_tipo_producto) VALUES
                                                                               (1,'Alimento'),
                                                                               (2,'Bebida'),
                                                                               (3,'Limpieza'),
                                                                               (4,'Higiene'),
                                                                               (5,'Otros');

    /* ======= TIPOS x MARCAS ======= */
    -- Alimento: (1..14) + (10,11,12,13,14 ya están ahí)
    INSERT INTO dbo.tipos_productos_marcas (nro_marca, nro_tipo_producto, vigente) VALUES
                                                                                       (1,1,1),(2,1,1),(3,1,1),(4,1,1),(5,1,1),(6,1,1),(7,1,1),(8,1,1),(9,1,1),
                                                                                       (10,1,1),(11,1,1),(12,1,1),(13,1,1),(14,1,1);

    -- Bebida: marcas típicas (15,16,17) y también (9,12) como económicas
    INSERT INTO dbo.tipos_productos_marcas (nro_marca, nro_tipo_producto, vigente) VALUES
                                                                                       (9,2,1),(12,2,1),(15,2,1),(16,2,1),(17,2,1);

    -- Limpieza
    INSERT INTO dbo.tipos_productos_marcas (nro_marca, nro_tipo_producto, vigente) VALUES
        (18,3,1);

    -- Higiene
    INSERT INTO dbo.tipos_productos_marcas (nro_marca, nro_tipo_producto, vigente) VALUES
                                                                                       (19,4,1),(20,4,1);

    /* ======= IDIOMAS ======= */
    INSERT INTO dbo.idiomas (cod_idioma, nom_idioma) VALUES
                                                         ('ES','Español'),
                                                         ('EN','English'),
                                                         ('PT','Português');

    /* ======= RUBROS x IDIOMA ======= */
    INSERT INTO dbo.idiomas_rubros_productos (nro_rubro, cod_idioma, rubro) VALUES
                                                                                (1,'ES','Alimentos'),            (1,'EN','Food'),                  (1,'PT','Alimentos'),
                                                                                (2,'ES','Bebidas sin alcohol'),  (2,'EN','Non-alcoholic drinks'),  (2,'PT','Bebidas não alcoólicas'),
                                                                                (3,'ES','Limpieza'),             (3,'EN','Cleaning'),              (3,'PT','Limpeza'),
                                                                                (4,'ES','Higiene Personal'),     (4,'EN','Personal Care'),         (4,'PT','Higiene Pessoal'),
                                                                                (5,'ES','Otros Esenciales'),     (5,'EN','Other essentials'),      (5,'PT','Outros essenciais');

    /* ======= CATEGORÍAS x IDIOMA ======= */
    INSERT INTO dbo.idiomas_categorias_productos (nro_categoria, cod_idioma, categoria) VALUES
                                                                                            (1 ,'ES','Panificados'),          (1 ,'EN','Bakery'),                 (1 ,'PT','Padaria'),
                                                                                            (2 ,'ES','Harinas y Cereales'),   (2 ,'EN','Flours & Cereals'),        (2 ,'PT','Farinhas e Cereais'),
                                                                                            (3 ,'ES','Pastas y Legumbres'),   (3 ,'EN','Pasta & Legumes'),         (3 ,'PT','Massas e Leguminosas'),
                                                                                            (4 ,'ES','Carnes'),               (4 ,'EN','Meat'),                    (4 ,'PT','Carnes'),
                                                                                            (5 ,'ES','Lácteos y Huevos'),     (5 ,'EN','Dairy & Eggs'),            (5 ,'PT','Laticínios e Ovos'),
                                                                                            (6 ,'ES','Frutas y Verduras'),    (6 ,'EN','Fruits & Vegetables'),     (6 ,'PT','Frutas e Verduras'),
                                                                                            (7 ,'ES','Azúcar y Dulces'),      (7 ,'EN','Sugar & Sweets'),          (7 ,'PT','Açúcar e Doces'),
                                                                                            (8 ,'ES','Aceites y Grasas'),     (8 ,'EN','Oils & Fats'),             (8 ,'PT','Óleos e Gorduras'),
                                                                                            (9 ,'ES','Infusiones'),           (9 ,'EN','Infusions'),               (9 ,'PT','Infusões'),
                                                                                            (10,'ES','Bebidas sin alcohol'),  (10,'EN','Non-alcoholic beverages'), (10,'PT','Bebidas não alcoólicas'),
                                                                                            (11,'ES','Limpieza Hogar'),       (11,'EN','Home Cleaning'),           (11,'PT','Limpeza Doméstica'),
                                                                                            (12,'ES','Lavandería'),           (12,'EN','Laundry'),                 (12,'PT','Lavanderia'),
                                                                                            (13,'ES','Cuidado Personal'),     (13,'EN','Personal Care'),           (13,'PT','Cuidados Pessoais'),
                                                                                            (14,'ES','Papel e Higiene'),      (14,'EN','Paper & Hygiene'),         (14,'PT','Papel e Higiene'),
                                                                                            (15,'ES','Condimentos y Básicos'),(15,'EN','Condiments & Basics'),     (15,'PT','Condimentos e Básicos');

    /* ======= TIPOS x IDIOMA ======= */
    INSERT INTO dbo.idiomas_tipos_productos (nro_tipo_producto, cod_idioma, tipo_producto) VALUES
                                                                                               (1,'ES','Alimento'), (1,'EN','Food'),     (1,'PT','Alimento'),
                                                                                               (2,'ES','Bebida'),   (2,'EN','Beverage'), (2,'PT','Bebida'),
                                                                                               (3,'ES','Limpieza'), (3,'EN','Cleaning'), (3,'PT','Limpeza'),
                                                                                               (4,'ES','Higiene'),  (4,'EN','Hygiene'),  (4,'PT','Higiene'),
                                                                                               (5,'ES','Otros'),    (5,'EN','Other'),    (5,'PT','Outros');

    INSERT INTO dbo.supermercados
    (razon_social, cuit)
    VALUES
        ('Carrefour Argentina', '30-68731043-4'),
        ('Chango Mas', '30-71191539-7'),
        ('Hiper Libertad', '30-61292945-5'),
        ('Disco', '30-59036076-3');

    INSERT INTO dbo.servicios_supermercados
    (nro_supermercado, url_servicio, tipo_servicio, token_servicio)
    VALUES
        (1, 'http://localhost:8081/ws/', 'SOAP', 'carrefour.a5s1d7fg4'),
        (2, 'http://localhost:8082/api/v1/supermercado', 'REST', 'changoMas.c1h2s4f'),
        (3, 'http://localhost:8083/ws/', 'SOAP', 'libertad.b3s1x8fg4'),
        (4, 'http://localhost:8084/api/v1/supermercado', 'REST', 'disco.n0h2e9f');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    THROW;
END CATCH;


/* -------------------------------------
   procedimientos almacenados
   ------------------------------------- */
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_all_provincias
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.cod_provincia AS codProvincia,
        p.nom_provincia AS nomProvincia,
        p.cod_pais AS codPais,
        pa.nom_pais AS nomPais
    FROM dbo.provincias p
             INNER JOIN dbo.paises pa ON p.cod_pais = pa.cod_pais
    WHERE p.cod_pais = 'ARG'
    ORDER BY pa.nom_pais, p.nom_provincia;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_localidades_by_provincia
    @cod_provincia VARCHAR(3),
    @cod_pais VARCHAR(3)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        nro_localidad AS nroLocalidad,
        nom_localidad AS nomLocalidad,
        cod_provincia AS codProvincia,
        cod_pais AS codPais
    FROM dbo.localidades
    WHERE cod_provincia = @cod_provincia
      AND cod_pais = @cod_pais
    ORDER BY nom_localidad;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_all_supermercados
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.nro_supermercado AS nroSupermercado,
        s.razon_social AS razonSocial,
        s.cuit,
        ss.url_servicio AS urlServicio,
        ss.tipo_servicio AS tipoServicio,
        ss.token_servicio AS tokenServicio,
        ss.fecha_ult_act_servicio AS fechaUltActServicio
    FROM dbo.supermercados s
             LEFT JOIN dbo.servicios_supermercados ss ON s.nro_supermercado = ss.nro_supermercado
    ORDER BY s.razon_social;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_sucursales
    @nro_supermercado INT = NULL,
    @nro_localidad INT = NULL,
    @cod_provincia VARCHAR(3) = NULL,
    @cod_pais VARCHAR(3) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        suc.nro_supermercado AS nroSupermercado,
        suc.nro_sucursal AS nroSucursal,
        suc.nom_sucursal AS nomSucursal,
        suc.calle,
        suc.nro_calle AS nroCalle,
        suc.telefonos,
        suc.coord_latitud AS coordLatitud,
        suc.coord_longitud AS coordLongitud,
        suc.horario_sucursal AS horarioSucursal,
        suc.servicios_disponibles AS serviciosDisponibles,
        suc.habilitada,
        sup.razon_social AS razonSocial,
        l.nro_localidad AS nroLocalidad,
        l.nom_localidad AS nomLocalidad,
        l.cod_provincia AS codProvincia,
        p.nom_provincia AS nomProvincia,
        l.cod_pais AS codPais,
        pa.nom_pais AS nomPais
    FROM dbo.sucursales suc
             INNER JOIN dbo.supermercados sup ON suc.nro_supermercado = sup.nro_supermercado
             INNER JOIN dbo.localidades l ON suc.nro_localidad = l.nro_localidad
             INNER JOIN dbo.provincias p ON l.cod_provincia = p.cod_provincia AND l.cod_pais = p.cod_pais
             INNER JOIN dbo.paises pa ON l.cod_pais = pa.cod_pais
    WHERE (@nro_supermercado IS NULL OR suc.nro_supermercado = @nro_supermercado)
      AND (@nro_localidad IS NULL OR suc.nro_localidad = @nro_localidad)
      AND (@cod_provincia IS NULL OR l.cod_provincia = @cod_provincia)
      AND (@cod_pais IS NULL OR l.cod_pais = @cod_pais)
      AND suc.habilitada = 1
    ORDER BY pa.nom_pais, p.nom_provincia, l.nom_localidad, sup.razon_social, suc.nom_sucursal;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_productos
    @cod_idioma VARCHAR(2) = 'es'
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.cod_barra                               AS codBarra,
        p.nom_producto                            AS nomProducto,
        p.desc_producto                           AS descProducto,
        p.imagen                                  AS imagen,
        m.nom_marca                               AS nomMarca,
        p.nro_categoria                           AS nroCategoria,
        COALESCE(icp.categoria, c.nom_categoria)  AS nomCategoria,
        r.nro_rubro                               AS nroRubro,
        COALESCE(irp.rubro, r.nom_rubro)          AS nomRubro,
        COALESCE(itp.tipo_producto, tp.nom_tipo_producto) AS nomTipoProducto
    FROM dbo.productos p
             INNER JOIN dbo.categorias_productos c
                        ON c.nro_categoria = p.nro_categoria
             INNER JOIN dbo.rubros_productos r
                        ON r.nro_rubro = c.nro_rubro
             LEFT JOIN dbo.tipos_productos tp
                       ON tp.nro_tipo_producto = p.nro_tipo_producto
             LEFT JOIN dbo.idiomas_categorias_productos icp
                       ON icp.nro_categoria = c.nro_categoria
                      AND icp.cod_idioma = @cod_idioma
             LEFT JOIN dbo.idiomas_rubros_productos irp
                       ON irp.nro_rubro = r.nro_rubro
                      AND irp.cod_idioma = @cod_idioma
             LEFT JOIN dbo.idiomas_tipos_productos itp
                       ON itp.nro_tipo_producto = tp.nro_tipo_producto
                      AND itp.cod_idioma = @cod_idioma
             LEFT  JOIN dbo.marcas_productos m
                        ON m.nro_marca = p.nro_marca
    WHERE p.vigente=1 AND c.vigente=1 AND r.vigente=1
    ORDER BY
        COALESCE(irp.rubro, r.nom_rubro), COALESCE(icp.categoria, c.nom_categoria), p.nom_producto;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_productos_precios
    @nro_localidad INT,
    @codigos       NVARCHAR(MAX), -- CSV: '100000000001,100000000030,...'
    @cod_idioma    VARCHAR(2) = 'es'
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH codes AS (
        SELECT TRIM(value) AS cod_barra
        FROM STRING_SPLIT(@codigos, ',')
        WHERE TRIM(value) <> ''
    )
     SELECT
         p.cod_barra                              AS codBarra,
         p.nom_producto                           AS nomProducto,
         COALESCE(icp.categoria, c.nom_categoria) AS nomCategoria,
         (
             SELECT
                 s2.nro_supermercado                  AS nroSupermercado,
                 CAST(ps2.precio AS DECIMAL(10,2))    AS precio
             FROM dbo.sucursales s2
                      JOIN dbo.productos_supermercados ps2
                           ON ps2.nro_supermercado = s2.nro_supermercado
                               AND ps2.nro_sucursal    = s2.nro_sucursal
                               AND CONVERT(date, ps2.fecha_ult_actualizacion) = CONVERT(date, GETDATE())
             WHERE s2.nro_localidad = @nro_localidad
               AND s2.habilitada = 1
               AND ps2.cod_barra = p.cod_barra
             FOR JSON PATH
         ) AS preciosPorSupermercado
     FROM codes x
              JOIN dbo.productos p
                   ON p.cod_barra = x.cod_barra
              JOIN dbo.categorias_productos c
                   ON c.nro_categoria = p.nro_categoria
              LEFT JOIN dbo.idiomas_categorias_productos icp
                   ON icp.nro_categoria = c.nro_categoria
                  AND icp.cod_idioma = @cod_idioma
              JOIN dbo.sucursales s
                   ON s.nro_localidad = @nro_localidad
              JOIN dbo.productos_supermercados ps
                   ON ps.cod_barra = p.cod_barra
                       AND ps.nro_supermercado = s.nro_supermercado
                       AND ps.nro_sucursal    = s.nro_sucursal
                       AND CONVERT(date, ps.fecha_ult_actualizacion) = CONVERT(date, GETDATE())
     WHERE p.vigente = 1
       AND c.vigente = 1
       AND s.habilitada = 1
     GROUP BY
         p.cod_barra, p.nom_producto, c.nom_categoria, icp.categoria
     ORDER BY
         p.nom_producto;
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.sp_upsert_sucursales
    @nro_supermercado INT,          -- ID del Supermercado
    @formato          NVARCHAR(10), -- 'REST' | 'SOAP'
    @payload          NVARCHAR(MAX) -- Response del servicio
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET QUOTED_IDENTIFIER ON;
    SET ANSI_NULLS ON;
    SET ANSI_WARNINGS ON;
    SET ANSI_PADDING ON;
    SET CONCAT_NULL_YIELDS_NULL ON;
    SET ARITHABORT ON;

    BEGIN TRY
        DECLARE @s TABLE(
                            nro_sucursal          INT            NOT NULL,
                            nom_sucursal          NVARCHAR(100)  NOT NULL,
                            calle                 NVARCHAR(100)  NOT NULL,
                            nro_calle             NVARCHAR(10)   NOT NULL,
                            telefonos             NVARCHAR(100)  NULL,
                            coord_latitud         DECIMAL(9,6)   NULL,
                            coord_longitud        DECIMAL(9,6)   NULL,
                            horario_sucursal      NVARCHAR(200)  NULL,  -- “1 09:00-21:00; 2 09:00-21:00; …”
                            servicios_disponibles NVARCHAR(200)  NULL,  -- “DELIVERY, PICKUP, …”
                            nro_localidad         INT            NOT NULL,
                            habilitada            BIT            NOT NULL
                        );

        /* ===========================
           JSON (arrays anidados)
           =========================== */
        IF UPPER(@formato) = N'REST'
            BEGIN
                IF ISJSON(@payload) <> 1
                    THROW 62001, 'Payload JSON inválido', 1;

                    ;WITH base AS (
                    SELECT *
                    FROM OPENJSON(@payload, N'$.sucursales')
                                  WITH (
                                      nro_sucursal          INT,
                                      nom_sucursal          NVARCHAR(100),
                                      calle                 NVARCHAR(100),
                                      nro_calle             NVARCHAR(20),
                                      telefonos             NVARCHAR(100),
                                      coord_latitud         NVARCHAR(50),
                                      coord_longitud        NVARCHAR(50),
                                      nro_localidad         INT,
                                      habilitada            BIT,
                                      horarios              NVARCHAR(MAX) AS JSON,
                                      servicios             NVARCHAR(MAX) AS JSON
                                      )
                ),
                          h AS (
                              SELECT b.nro_sucursal,
                                     STRING_AGG(CONCAT(hh.dia_semana, ' ', hh.hora_desde, '-', hh.hora_hasta), '; ')
                                                WITHIN GROUP (ORDER BY hh.dia_semana) AS cadena
                              FROM base b
                                       OUTER APPLY OPENJSON(b.horarios)
                                                            WITH (
                                                                dia_semana INT,
                                                                hora_desde NVARCHAR(5),
                                                                hora_hasta NVARCHAR(5)
                                                                ) AS hh
                              GROUP BY b.nro_sucursal
                          ),
                          sv AS (
                              SELECT b.nro_sucursal,
                                     STRING_AGG(ss.nom_tipo_servicio, ', ')
                                                WITHIN GROUP (ORDER BY ss.nom_tipo_servicio) AS cadena
                              FROM base b
                                       OUTER APPLY OPENJSON(b.servicios)
                                                            WITH (
                                                                nro_tipo_servicio INT,
                                                                nom_tipo_servicio NVARCHAR(100)
                                                                ) AS ss
                              GROUP BY b.nro_sucursal
                          )
                     INSERT INTO @s(
                    nro_sucursal, nom_sucursal, calle, nro_calle, telefonos,
                    coord_latitud, coord_longitud, horario_sucursal, servicios_disponibles,
                    nro_localidad, habilitada
                )
                     SELECT
                         b.nro_sucursal,
                         NULLIF(LTRIM(RTRIM(b.nom_sucursal)),N''),
                         COALESCE(NULLIF(LTRIM(RTRIM(b.calle)),N''), N'Desconocida'),
                         LEFT(COALESCE(b.nro_calle, N'0'), 10),
                         NULLIF(LTRIM(RTRIM(b.telefonos)),N''),
                         TRY_CAST(b.coord_latitud  AS DECIMAL(9,6)),
                         TRY_CAST(b.coord_longitud AS DECIMAL(9,6)),
                         LEFT(ISNULL(h.cadena, N''), 200),
                         LEFT(ISNULL(sv.cadena,N''), 200),
                         b.nro_localidad,
                         ISNULL(b.habilitada, 1)
                     FROM base b
                              LEFT JOIN h  ON h.nro_sucursal  = b.nro_sucursal
                              LEFT JOIN sv ON sv.nro_sucursal = b.nro_sucursal;
            END

            /* ===========================
               XML (nodos anidados) - ROBUSTO (local-name + string + try_convert)
               Soporta namespaces y estructuras SOAP
               =========================== */
        ELSE IF UPPER(@formato) = N'SOAP'
            BEGIN
                DECLARE @x XML = TRY_CAST(@payload AS XML);
                IF @x IS NULL
                    THROW 62002, 'Payload XML inválido', 1;

                    ;WITH SucRaw AS (
                    SELECT
                        nro_sucursal = TRY_CONVERT(INT,
                                SX.value('string(./*[local-name()="nro_sucursal"][1])','NVARCHAR(50)')),
                        nom_sucursal = NULLIF(LTRIM(RTRIM(
                                SX.value('string(./*[local-name()="nom_sucursal"][1])','NVARCHAR(100)')
                                                    )), N''),
                        calle = NULLIF(LTRIM(RTRIM(
                                SX.value('string(./*[local-name()="calle"][1])','NVARCHAR(100)')
                                             )), N''),
                        nro_calle = NULLIF(LTRIM(RTRIM(
                                SX.value('string(./*[local-name()="nro_calle"][1])','NVARCHAR(20)')
                                                 )), N''),
                        telefonos = NULLIF(LTRIM(RTRIM(
                                SX.value('string(./*[local-name()="telefonos"][1])','NVARCHAR(100)')
                                                 )), N''),
                        coord_latitud = TRY_CONVERT(DECIMAL(9,6),
                                REPLACE(SX.value('string(./*[local-name()="coord_latitud"][1])','NVARCHAR(50)'), ',', '.')),
                        coord_longitud = TRY_CONVERT(DECIMAL(9,6),
                                REPLACE(SX.value('string(./*[local-name()="coord_longitud"][1])','NVARCHAR(50)'), ',', '.')),
                        nro_localidad = TRY_CONVERT(INT,
                                SX.value('string(./*[local-name()="nro_localidad"][1])','NVARCHAR(50)')),
                        habilitada = TRY_CONVERT(BIT,
                                SX.value('string(./*[local-name()="habilitada"][1])','NVARCHAR(1)')),
                        nodoSucursal = SX.query('.')
                    FROM @x.nodes('//*[local-name()="sucursal"]') AS A(SX)
                ),
                          HorRows AS (
                              SELECT
                                  R.nro_sucursal,
                                  dia_semana = TRY_CONVERT(INT,
                                          H.value('string(./*[local-name()="dia_semana"][1])','NVARCHAR(10)')),
                                  hora_desde = NULLIF(LTRIM(RTRIM(
                                          H.value('string(./*[local-name()="hora_desde"][1])','NVARCHAR(10)')
                                                            )), N''),
                                  hora_hasta = NULLIF(LTRIM(RTRIM(
                                          H.value('string(./*[local-name()="hora_hasta"][1])','NVARCHAR(10)')
                                                            )), N'')
                              FROM SucRaw R
                                       OUTER APPLY R.nodoSucursal.nodes('.//*[local-name()="Horarios"]//*[local-name()="horario"]') AS X(H)
                          ),
                          ServRows AS (
                              SELECT
                                  R.nro_sucursal,
                                  nro_tipo_servicio = TRY_CONVERT(INT,
                                          V.value('string(./*[local-name()="nro_tipo_servicio"][1])','NVARCHAR(10)')),
                                  nom_tipo_servicio = NULLIF(LTRIM(RTRIM(
                                          V.value('string(./*[local-name()="nom_tipo_servicio"][1])','NVARCHAR(100)')
                                                                   )), N'')
                              FROM SucRaw R
                                       OUTER APPLY R.nodoSucursal.nodes('.//*[local-name()="Servicios"]//*[local-name()="servicio"]') AS Y(V)
                          ),
                          HorAgg AS (
                              SELECT
                                  nro_sucursal,
                                  cadena = STRING_AGG(CONCAT(dia_semana, ' ', hora_desde, '-', hora_hasta), '; ')
                                                      WITHIN GROUP (ORDER BY dia_semana)
                              FROM HorRows
                              WHERE dia_semana IS NOT NULL AND hora_desde IS NOT NULL AND hora_hasta IS NOT NULL
                              GROUP BY nro_sucursal
                          ),
                          ServAgg AS (
                              SELECT
                                  nro_sucursal,
                                  cadena = STRING_AGG(nom_tipo_servicio, ', ')
                                                      WITHIN GROUP (ORDER BY nom_tipo_servicio)
                              FROM ServRows
                              WHERE nom_tipo_servicio IS NOT NULL
                              GROUP BY nro_sucursal
                          )
                     INSERT INTO @s(
                    nro_sucursal, nom_sucursal, calle, nro_calle, telefonos,
                    coord_latitud, coord_longitud, horario_sucursal, servicios_disponibles,
                    nro_localidad, habilitada
                )
                     SELECT
                         R.nro_sucursal,
                         COALESCE(NULLIF(LTRIM(RTRIM(R.nom_sucursal)),N''), CONCAT(N'Sucursal ', R.nro_sucursal)),
                         COALESCE(NULLIF(LTRIM(RTRIM(R.calle)),N''), N'Desconocida'),
                         LEFT(COALESCE(R.nro_calle, N'0'), 10),
                         R.telefonos,
                         R.coord_latitud,
                         R.coord_longitud,
                         LEFT(ISNULL(H.cadena, N''), 200),
                         LEFT(ISNULL(S.cadena, N''), 200),
                         R.nro_localidad,
                         ISNULL(R.habilitada, 1)
                     FROM SucRaw R
                              LEFT JOIN HorAgg  H ON H.nro_sucursal = R.nro_sucursal
                              LEFT JOIN ServAgg S ON S.nro_sucursal = R.nro_sucursal
                     WHERE R.nro_sucursal IS NOT NULL
                       AND R.nro_localidad IS NOT NULL;
            END
        ELSE
            THROW 62003, 'Formato no soportado. Use JSON o XML.', 1;

        IF NOT EXISTS (SELECT 1 FROM @s)
            THROW 62004, 'No se detectaron sucursales en el payload.', 1;

        /* Validación de FK de localidades (no inserta/actualiza maestros) */
        IF EXISTS (
            SELECT 1
            FROM @s st
                     LEFT JOIN dbo.localidades l ON l.nro_localidad = st.nro_localidad
            WHERE l.nro_localidad IS NULL
        )
            THROW 62005, 'Alguna nro_localidad no existe en dbo.localidades.', 1;

        /* UPSERT SOLO en dbo.sucursales */
        MERGE dbo.sucursales AS tgt
        USING (
            SELECT
                @nro_supermercado AS nro_supermercado,
                nro_sucursal, nom_sucursal, calle, nro_calle, telefonos,
                coord_latitud, coord_longitud, horario_sucursal, servicios_disponibles,
                nro_localidad, habilitada
            FROM @s
        ) AS src
        ON tgt.nro_supermercado = src.nro_supermercado
            AND tgt.nro_sucursal  = src.nro_sucursal
        WHEN MATCHED THEN
            UPDATE SET
                       tgt.nom_sucursal          = src.nom_sucursal,
                       tgt.calle                 = src.calle,
                       tgt.nro_calle             = src.nro_calle,
                       tgt.telefonos             = src.telefonos,
                       tgt.coord_latitud         = src.coord_latitud,
                       tgt.coord_longitud        = src.coord_longitud,
                       tgt.horario_sucursal      = src.horario_sucursal,
                       tgt.servicios_disponibles = src.servicios_disponibles,
                       tgt.nro_localidad         = src.nro_localidad,
                       tgt.habilitada            = src.habilitada
        WHEN NOT MATCHED THEN
            INSERT (nro_supermercado, nro_sucursal, nom_sucursal, calle, nro_calle, telefonos,
                    coord_latitud, coord_longitud, horario_sucursal, servicios_disponibles,
                    nro_localidad, habilitada)
            VALUES (src.nro_supermercado, src.nro_sucursal, src.nom_sucursal, src.calle, src.nro_calle, src.telefonos,
                    src.coord_latitud, src.coord_longitud, src.horario_sucursal, src.servicios_disponibles,
                    src.nro_localidad, src.habilitada);

        SELECT (
                   SELECT
                       @nro_supermercado AS nro_supermercado,
                       (SELECT COUNT(*) FROM @s) AS sucursales_procesadas
                   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
               ) AS json;

    END TRY
    BEGIN CATCH
        DECLARE @err NVARCHAR(4000) =
            CONCAT('(',ERROR_NUMBER(),') ',ERROR_MESSAGE(),' en ',ISNULL(ERROR_PROCEDURE(),'-'),' L',ERROR_LINE());
        SELECT (SELECT 1 AS error, @err AS detalle FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS json;
        IF XACT_STATE() <> 0 ROLLBACK;
    END CATCH
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE dbo.sp_upsert_productos
    @nro_supermercado INT,          -- ID del Supermercado
    @formato          NVARCHAR(10), -- 'REST' | 'SOAP'
    @payload          NVARCHAR(MAX) -- Response del servicio
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @items TABLE(
                                nro_sucursal       INT            NOT NULL,
                                cod_barra          NVARCHAR(50)   NOT NULL,
                                nom_producto       NVARCHAR(100)  NULL,
                                desc_producto      NVARCHAR(500)  NULL,
                                nro_categoria      INT            NOT NULL,
                                imagen             NVARCHAR(500)  NULL,
                                nro_marca          INT            NOT NULL,
                                nro_tipo_producto  INT            NOT NULL,
                                precio             DECIMAL(10,2)  NOT NULL,
                                vigente            BIT            NULL
                            );

        IF UPPER(@formato) = 'REST'
            BEGIN
                IF ISJSON(@payload) <> 1
                    THROW 11001, 'Payload JSON inválido', 1;

                INSERT INTO @items
                (nro_sucursal, cod_barra, nom_producto, desc_producto, nro_categoria,
                 imagen, nro_marca, nro_tipo_producto, precio, vigente)
                SELECT
                    p.nro_sucursal,
                    p.cod_barra,
                    p.nom_producto,
                    p.desc_producto,
                    p.nro_categoria,
                    p.imagen,
                    p.nro_marca,
                    p.nro_tipo_producto,
                    p.precio,
                    p.vigente
                FROM OPENJSON(@payload, '$.productosSucursales')
                              WITH (
                                  nro_sucursal       INT,
                                  cod_barra          NVARCHAR(50),
                                  nom_producto       NVARCHAR(100),
                                  desc_producto      NVARCHAR(500),
                                  nro_categoria      INT,
                                  imagen             NVARCHAR(500),
                                  nro_marca          INT,
                                  nro_tipo_producto  INT,
                                  precio             DECIMAL(10,2),
                                  vigente            BIT
                                  ) AS p;
            END
        ELSE IF UPPER(@formato) = 'SOAP'
            BEGIN
                DECLARE @x XML = TRY_CAST(@payload AS XML);
                IF @x IS NULL THROW 11002, 'Payload XML inválido', 1;

                /* PATRÓN SEGURO: un solo nodes() y solo .value() */
                INSERT INTO @items
                (nro_sucursal, cod_barra, nom_producto, desc_producto, nro_categoria,
                 imagen, nro_marca, nro_tipo_producto, precio, vigente)
                SELECT
                    PX.p.value('(./*[local-name()="nro_sucursal"]/text())[1]','INT'),
                    PX.p.value('(./*[local-name()="cod_barra"]/text())[1]','NVARCHAR(50)'),
                    PX.p.value('(./*[local-name()="nom_producto"]/text())[1]','NVARCHAR(100)'),
                    PX.p.value('(./*[local-name()="desc_producto"]/text())[1]','NVARCHAR(500)'),
                    PX.p.value('(./*[local-name()="nro_categoria"]/text())[1]','INT'),
                    PX.p.value('(./*[local-name()="imagen"]/text())[1]','NVARCHAR(500)'),
                    PX.p.value('(./*[local-name()="nro_marca"]/text())[1]','INT'),
                    PX.p.value('(./*[local-name()="nro_tipo_producto"]/text())[1]','INT'),
                    TRY_CAST(PX.p.value('(./*[local-name()="precio"]/text())[1]','NVARCHAR(64)') AS DECIMAL(10,2)),
                    TRY_CONVERT(BIT, PX.p.value('string(./*[local-name()="vigente"][1])','NVARCHAR(10)'))
                FROM (SELECT @x AS x) AS T
                         CROSS APPLY T.x.nodes('//*[local-name()="productosSucursales"]/*[local-name()="productoSucursal"]') AS PX(p);
            END
        ELSE
            THROW 11003, 'Formato no soportado. Use JSON o XML.', 1;

        IF NOT EXISTS (SELECT 1 FROM @items)
            THROW 11004, 'No se detectaron productos en el payload.', 1;

        /* UPSERT productos */
        MERGE dbo.productos AS tgt
        USING (
            SELECT DISTINCT cod_barra, nom_producto, desc_producto, nro_categoria, imagen, nro_marca, nro_tipo_producto
            FROM @items
            WHERE vigente = 1
        ) AS src
        ON tgt.cod_barra = src.cod_barra
        WHEN NOT MATCHED THEN
            INSERT (cod_barra, nom_producto, desc_producto, nro_categoria, imagen, nro_marca, nro_tipo_producto, vigente)
            VALUES (src.cod_barra, src.nom_producto, src.desc_producto, src.nro_categoria, src.imagen, src.nro_marca, src.nro_tipo_producto, 1)
        WHEN MATCHED AND (
            ISNULL(LTRIM(RTRIM(tgt.nom_producto)),'')  <> ISNULL(LTRIM(RTRIM(src.nom_producto)),'')
                OR ISNULL(LTRIM(RTRIM(tgt.desc_producto)),'') <> ISNULL(LTRIM(RTRIM(src.desc_producto)),'')
                OR ISNULL(tgt.nro_categoria,0)                <> ISNULL(src.nro_categoria,0)
                OR ISNULL(LTRIM(RTRIM(tgt.imagen)),'')        <> ISNULL(LTRIM(RTRIM(src.imagen)),'')
                OR ISNULL(tgt.nro_marca,0)                    <> ISNULL(src.nro_marca,0)
                OR ISNULL(tgt.nro_tipo_producto,0)            <> ISNULL(src.nro_tipo_producto,0)
                OR tgt.vigente = 0
            )
            THEN UPDATE SET
                            tgt.nom_producto      = src.nom_producto,
                            tgt.desc_producto     = src.desc_producto,
                            tgt.nro_categoria     = src.nro_categoria,
                            tgt.imagen            = src.imagen,
                            tgt.nro_marca         = src.nro_marca,
                            tgt.nro_tipo_producto = src.nro_tipo_producto,
                            tgt.vigente           = 1;

        /* UPSERT precios por supermercado/sucursal */
        MERGE dbo.productos_supermercados AS tgt
        USING (
            SELECT cod_barra, @nro_supermercado AS nro_supermercado, nro_sucursal, precio
            FROM @items
            WHERE vigente = 1
        ) AS src
        ON tgt.cod_barra = src.cod_barra
            AND tgt.nro_supermercado = src.nro_supermercado
            AND tgt.nro_sucursal     = src.nro_sucursal
        WHEN NOT MATCHED THEN
            INSERT (nro_supermercado, nro_sucursal, cod_barra, precio, fecha_ult_actualizacion)
            VALUES (src.nro_supermercado, src.nro_sucursal, src.cod_barra, src.precio, SYSUTCDATETIME())
        WHEN MATCHED AND (tgt.precio <> src.precio)
            THEN UPDATE SET tgt.precio = src.precio, tgt.fecha_ult_actualizacion = SYSUTCDATETIME();

        COMMIT;

        SELECT (SELECT @nro_supermercado AS nro_supermercado,
                       (SELECT COUNT(*) FROM @items) AS productos_recibidos
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS json;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        DECLARE @err NVARCHAR(4000) = CONCAT('(',ERROR_NUMBER(),') ',ERROR_MESSAGE(),' L',ERROR_LINE());
        SELECT (SELECT 1 AS error, @err AS detalle FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) AS json;
    END CATCH
END
GO
