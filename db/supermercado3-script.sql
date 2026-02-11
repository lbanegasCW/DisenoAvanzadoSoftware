/* ============================
   CREACIÓN DE ESQUEMA
============================ */
USE master
GO


IF EXISTS(SELECT *
FROM sys.databases
WHERE name = 'supermercado3')
BEGIN
    ALTER DATABASE supermercado3 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE supermercado3;
END
GO


CREATE DATABASE supermercado3;
GO

USE supermercado3;
GO

CREATE TYPE CodigoPais FROM varchar(3);
GO

CREATE TYPE CodigoProvincia FROM varchar(3);
GO

CREATE TABLE dbo.empresas_externas
(
    nro_empresa int PRIMARY KEY IDENTITY(1,1),
    razon_social varchar(100) NOT NULL,
    cuit_empresa int NOT NULL,
    token_servicio varchar(200)
);

CREATE TABLE dbo.supermercado
(
    cuit varchar(13) PRIMARY KEY,
    razon_social varchar(100) NOT NULL,
    calle varchar(100) NOT NULL,
    nro_calle int NOT NULL,
    telefonos varchar(13) NOT NULL,
);


CREATE TABLE dbo.paises
(
    cod_pais CodigoPais PRIMARY KEY,
    nom_pais varchar(100) NOT NULL,
    local bit NOT NULL DEFAULT 0
);


CREATE TABLE dbo.provincias
(
    cod_pais CodigoPais NOT NULL,
    cod_provincia CodigoProvincia NOT NULL,
    nom_provincia varchar(100) NOT NULL,
    PRIMARY KEY (cod_pais, cod_provincia),
    FOREIGN KEY (cod_pais) REFERENCES dbo.paises(cod_pais)
);


CREATE TABLE dbo.localidades
(
    nro_localidad int PRIMARY KEY IDENTITY(1,1),
    nom_localidad varchar(100) NOT NULL,
    cod_pais CodigoPais NOT NULL,
    cod_provincia CodigoProvincia NOT NULL,
    FOREIGN KEY (cod_pais, cod_provincia) REFERENCES dbo.provincias(cod_pais, cod_provincia)
);


CREATE TABLE dbo.sucursales
(
    nro_sucursal int IDENTITY(1,1),
    nom_sucursal varchar(100) NOT NULL,
    calle varchar(100) NOT NULL,
    nro_calle int NOT NULL,
    telefonos varchar(13) NOT NULL,
    coord_latitud decimal(9,6),
    coord_longitud decimal(9,6),
    nro_localidad int NOT NULL,
    habilitada bit NOT NULL DEFAULT 1,
    PRIMARY KEY (nro_sucursal),
    FOREIGN KEY (nro_localidad) REFERENCES dbo.localidades(nro_localidad)
);


CREATE TABLE dbo.horarios_sucursales
(
    nro_sucursal int NOT NULL,
    dia_semana tinyint NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
    hora_desde time NOT NULL,
    hora_hasta time NOT NULL,
    PRIMARY KEY (nro_sucursal, dia_semana),
    FOREIGN KEY (nro_sucursal) REFERENCES dbo.sucursales(nro_sucursal),
    CONSTRAINT CHK_horario_valido CHECK (hora_desde < hora_hasta)
);


CREATE TABLE dbo.tipos_servicios_supermercado
(
    nro_tipo_servicio int PRIMARY KEY IDENTITY(1,1),
    nom_tipo_servicio varchar(50) NOT NULL
);


CREATE TABLE dbo.tipos_servicios_sucursales
(
    nro_sucursal int NOT NULL,
    nro_tipo_servicio int NOT NULL,
    vigente bit NOT NULL DEFAULT 1,
    PRIMARY KEY (nro_sucursal, nro_tipo_servicio),
    FOREIGN KEY (nro_sucursal) REFERENCES dbo.sucursales(nro_sucursal),
    FOREIGN KEY (nro_tipo_servicio) REFERENCES dbo.tipos_servicios_supermercado(nro_tipo_servicio)
);


CREATE TABLE dbo.rubros_productos
(
    nro_rubro int PRIMARY KEY IDENTITY(1,1),
    nom_rubro varchar(100) NOT NULL,
    vigente bit NOT NULL DEFAULT 1
);


CREATE TABLE dbo.categorias_productos
(
    nro_categoria int PRIMARY KEY IDENTITY(1,1),
    nom_categoria varchar(100) NOT NULL,
    nro_rubro int NOT NULL,
    vigente bit NOT NULL DEFAULT 1,
    FOREIGN KEY (nro_rubro) REFERENCES dbo.rubros_productos(nro_rubro)
);


CREATE TABLE dbo.marcas_productos
(
    nro_marca int PRIMARY KEY IDENTITY(1,1),
    nom_marca varchar(100) NOT NULL,
    vigente bit NOT NULL DEFAULT 1
);


CREATE TABLE dbo.tipos_productos
(
    nro_tipo_producto int PRIMARY KEY IDENTITY(1,1),
    nom_tipo_producto varchar(100) NOT NULL
);


CREATE TABLE dbo.tipos_productos_marcas
(
    nro_marca int NOT NULL,
    nro_tipo_producto int NOT NULL,
    vigente bit NOT NULL DEFAULT 1,
    PRIMARY KEY (nro_marca, nro_tipo_producto),
    FOREIGN KEY (nro_marca) REFERENCES dbo.marcas_productos(nro_marca),
    FOREIGN KEY (nro_tipo_producto) REFERENCES dbo.tipos_productos(nro_tipo_producto)
);


CREATE TABLE dbo.productos
(
    cod_barra varchar(50) PRIMARY KEY,
    nom_producto varchar(100) NOT NULL,
    desc_producto varchar(500),
    nro_categoria int NOT NULL,
    imagen varchar(500) NOT NULL,
    nro_marca int NOT NULL,
    nro_tipo_producto int NOT NULL,
    vigente bit NOT NULL DEFAULT 1,
    FOREIGN KEY (nro_categoria) REFERENCES dbo.categorias_productos(nro_categoria),
    FOREIGN KEY (nro_marca, nro_tipo_producto) REFERENCES dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
);


CREATE TABLE dbo.productos_sucursales
(
    nro_sucursal int NOT NULL,
    cod_barra varchar(50) NOT NULL,
    precio decimal(10,2) NOT NULL,
    vigente bit NOT NULL DEFAULT 1,
    PRIMARY KEY (nro_sucursal, cod_barra),
    FOREIGN KEY (nro_sucursal) REFERENCES dbo.sucursales(nro_sucursal),
    FOREIGN KEY (cod_barra) REFERENCES dbo.productos(cod_barra),
    CONSTRAINT CHK_precio_positivo CHECK (precio > 0)
);

GO

/* -------------------------------------
  Procedimientos almacenados
  ------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.sp_get_sucursales
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        s.nro_sucursal,
        s.nom_sucursal,
        s.calle,
        s.nro_calle,
        s.telefonos,
        s.coord_latitud,
        s.coord_longitud,
        s.habilitada,
        l.nro_localidad,
        l.nom_localidad,
        p.cod_provincia,
        p.nom_provincia,
        p.cod_pais,
        pa.nom_pais,
        p.cod_pais,
        (
            SELECT
                hs.dia_semana,
                CONVERT(varchar(5), hs.hora_desde, 108)         AS 'hora_desde',
                CONVERT(varchar(5), hs.hora_hasta, 108)         AS 'hora_hasta'
            FROM dbo.horarios_sucursales hs
            WHERE hs.nro_sucursal = s.nro_sucursal
            ORDER BY hs.dia_semana
            FOR XML PATH('horario'), ROOT('horarios'), TYPE
        ) AS 'Horarios',
        (
            SELECT
                ss.nro_tipo_servicio                             AS 'nro_tipo_servicio',
                sp.nom_tipo_servicio                             AS 'nom_tipo_servicio'
            FROM dbo.tipos_servicios_sucursales ss
                     JOIN dbo.tipos_servicios_supermercado sp
                          ON sp.nro_tipo_servicio = ss.nro_tipo_servicio
            WHERE ss.nro_sucursal = s.nro_sucursal
              AND ss.vigente = 1
            ORDER BY sp.nom_tipo_servicio
            FOR XML PATH('servicio'), ROOT('servicios'), TYPE
        ) AS 'Servicios'
    FROM dbo.sucursales s
             JOIN dbo.localidades l
                  ON l.nro_localidad = s.nro_localidad
             JOIN dbo.provincias p
                  ON p.cod_provincia = l.cod_provincia
                      AND p.cod_pais      = l.cod_pais
             JOIN dbo.paises pa
                  ON pa.cod_pais = p.cod_pais
    ORDER BY s.nom_sucursal
    FOR XML PATH('sucursal'), ROOT('sucursales'), TYPE;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_productos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ps.nro_sucursal,
        r.nro_rubro,
        r.nom_rubro,
        c.nro_categoria,
        c.nom_categoria,
        p.cod_barra,
        p.nom_producto,
        p.desc_producto,
        p.imagen,
        m.nro_marca,
        m.nom_marca,
        t.nro_tipo_producto,
        t.nom_tipo_producto,
        ps.precio,
        ps.vigente
    FROM dbo.productos_sucursales ps
             INNER JOIN dbo.productos p
                        ON ps.cod_barra = p.cod_barra
             INNER JOIN dbo.categorias_productos c
                        ON p.nro_categoria = c.nro_categoria
             INNER JOIN dbo.rubros_productos r
                        ON c.nro_rubro = r.nro_rubro
             INNER JOIN dbo.marcas_productos m
                        ON p.nro_marca = m.nro_marca
             INNER JOIN dbo.tipos_productos t
                        ON p.nro_tipo_producto = t.nro_tipo_producto
             INNER JOIN dbo.sucursales s
                        ON ps.nro_sucursal = s.nro_sucursal
    WHERE p.vigente  = 1
      AND c.vigente  = 1
      AND r.vigente  = 1
      AND s.habilitada = 1
    ORDER BY ps.nro_sucursal, r.nom_rubro, c.nom_categoria, p.nom_producto
    FOR XML PATH('productoSucursal'), ROOT('productosSucursales'), TYPE;
END
GO

/* ============================
   DATOS INICIALES (PAÍSES/PROVINCIAS/HORARIOS/SUCURSALES/SERVICIOS/PRODUCTOS/MARCAS/CATEGORIAS/RUBROS/TIPOS)
============================ */
BEGIN TRY
BEGIN TRANSACTION;

INSERT INTO dbo.paises (cod_pais, nom_pais, local) VALUES
        ('ARG','Argentina',1),('CHL','Chile',0),('BRA','Brazil',0);

INSERT INTO dbo.provincias (cod_pais, cod_provincia, nom_provincia) VALUES
        ('ARG','BA','Buenos Aires'),('ARG','CBA','Córdoba'),('ARG','SF','Santa Fe'),
        ('CHL','RM','Región Metropolitana'),('CHL','V','Valparaíso'),
        ('BRA','SP','São Paulo'),('BRA','RJ','Rio de Janeiro');

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

INSERT INTO dbo.supermercado (cuit, razon_social, calle, nro_calle, telefonos) VALUES
        ('30-61292945-5','Hiper Libertad','Avenida Sabattini',3250,'351-231-4242');

INSERT INTO dbo.tipos_servicios_supermercado (nom_tipo_servicio) VALUES
         ('DELIVERY'),('PICKUP'),('PAGO ONLINE'),('PARKING'),('ACCESO ESPECIAL'),
         ('ATENCIÓN AL CLIENTE'),('FARMACIA'),('AUTOSERVICIO'),('CARGA DE SUBE'),('CAJA RÁPIDA');

INSERT INTO dbo.sucursales (nom_sucursal, calle, nro_calle, telefonos, coord_latitud, coord_longitud, nro_localidad) VALUES
         ('Hiper Libertad La Plata','Avenida 44',1350,'0221-452-7788',-34.9139,-57.9521,2),
         ('Hiper Libertad Mar del Plata','Avenida Champagnat',2100,'0223-470-6655',-38.0182,-57.5538,3),
         ('Hiper Libertad Córdoba','Avenida Sabattini',3250,'0351-456-2200',-31.4306,-64.1532,4),
         ('Hiper Libertad Rosario','Avenida Circunvalación',6800,'0341-485-4400',-32.9874,-60.7009,5),
         ('Hiper Libertad Buenos Aires','Avenida General Paz',14200,'011-4687-3311',-34.5359,-58.4896,1);

INSERT INTO dbo.horarios_sucursales (nro_sucursal, dia_semana, hora_desde, hora_hasta) VALUES
       (1,1,'09:00','21:00'),(1,2,'09:00','21:00'),(1,3,'09:00','21:00'),(1,4,'09:00','21:00'),(1,5,'09:00','21:00'),(1,6,'09:00','13:00'),
       (2,1,'09:00','21:00'),(2,2,'09:00','21:00'),(2,3,'09:00','21:00'),(2,4,'09:00','21:00'),(2,5,'09:00','21:00'),(2,6,'14:00','21:00'),
       (3,1,'09:00','21:00'),(3,2,'09:00','21:00'),(3,3,'09:00','21:00'),(3,4,'09:00','21:00'),(3,5,'09:00','21:00'),(3,6,'09:00','13:30'),
       (4,1,'09:00','21:00'),(4,2,'09:00','21:00'),(4,3,'09:00','21:00'),(4,4,'09:00','21:00'),(4,5,'09:00','21:00'),(4,6,'09:00','13:00'),
       (5,1,'09:00','21:00'),(5,2,'09:00','21:00'),(5,3,'09:00','21:00'),(5,4,'09:00','21:00'),(5,5,'09:00','21:00'),(5,6,'09:00','13:00');

INSERT INTO dbo.tipos_servicios_sucursales (nro_sucursal, nro_tipo_servicio, vigente) VALUES
        (1,1,1),(1,2,1),(1,3,1),(1,4,1),(1,10,1),
        (2,1,1),(2,2,1),(2,5,1),(2,9,1),
        (3,1,1),(3,4,1),(3,7,1),
        (4,3,1),(4,4,1),(4,6,1),
        (5,1,1),(5,2,1),(5,8,1);

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

BEGIN TRY
BEGIN TRANSACTION;

INSERT INTO dbo.rubros_productos(nom_rubro) VALUES
                                                ('Alimentos'),
                                                ('Bebidas sin alcohol'),
                                                ('Limpieza'),
                                                ('Higiene Personal'),
                                                ('Otros Esenciales');

INSERT INTO dbo.categorias_productos(nom_categoria, nro_rubro) VALUES
                                                                   ('Panificados',1),
                                                                   ('Harinas y Cereales',1),
                                                                   ('Pastas y Legumbres',1),
                                                                   ('Carnes',1),
                                                                   ('Lácteos y Huevos',1),
                                                                   ('Frutas y Verduras',1),
                                                                   ('Azúcar y Dulces',1),
                                                                   ('Aceites y Grasas',1),
                                                                   ('Infusiones',2),
                                                                   ('Bebidas sin alcohol',2),
                                                                   ('Limpieza Hogar',3),
                                                                   ('Lavandería',3),
                                                                   ('Cuidado Personal',4),
                                                                   ('Papel e Higiene',4),
                                                                   ('Condimentos y Básicos',5);

INSERT INTO dbo.marcas_productos(nom_marca) VALUES
                                                ('La Serenísima'),
                                                ('Sancor'),
                                                ('Arcor'),
                                                ('Ledesma'),
                                                ('Molinos'),
                                                ('Lucchetti'),
                                                ('Matarazzo'),
                                                ('Gallo'),
                                                ('Marolio'),
                                                ('Natura'),
                                                ('Cocinero'),
                                                ('Amanda'),
                                                ('Taragüi'),
                                                ('La Virginia'),
                                                ('CBSé'),
                                                ('Ala'),
                                                ('Ayudín'),
                                                ('Poett'),
                                                ('Higienol'),
                                                ('Colgate');

INSERT INTO dbo.tipos_productos(nom_tipo_producto) VALUES
                                                       ('Alimento'),
                                                       ('Bebida'),
                                                       ('Limpieza'),
                                                       ('Higiene'),
                                                       ('Otros');

-- Alimentos
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 1 FROM dbo.marcas_productos
WHERE nom_marca IN ('La Serenísima','Sancor','Arcor','Ledesma','Molinos','Lucchetti','Matarazzo','Gallo','Marolio','Natura','Cocinero');

-- Bebidas / Infusiones (sumo Arcor y La Serenísima por productos 057 y 100)
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 2 FROM dbo.marcas_productos
WHERE nom_marca IN ('Amanda','Taragüi','La Virginia','CBSé','Marolio','Arcor','La Serenísima');

-- Limpieza (sumo Marolio por detergente/esponja)
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 3 FROM dbo.marcas_productos
WHERE nom_marca IN ('Ala','Ayudín','Poett','Marolio');

-- Higiene (sumo Marolio por shampoo/acondicionador/etc.)
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 4 FROM dbo.marcas_productos
WHERE nom_marca IN ('Higienol','Colgate','Marolio');

-- Otros (sumo Marolio, Arcor y Molinos por sal/vinagre/caldos/puré)
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 5 FROM dbo.marcas_productos
WHERE nom_marca IN ('Marolio','Arcor','Molinos');

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO


BEGIN TRY
BEGIN TRANSACTION;

-- PRODUCTOS (leve variación en marcas)
INSERT INTO dbo.productos VALUES
                              ('100000000001','Pan francés 1Kg','Pan común a granel',1,'https://images.openfoodfacts.org/images/products/257/001/200/0902/front_es.3.400.jpg',9,1,1),
                              ('100000000002','Pan lactal 550g','Pan de molde',1,'https://images.openfoodfacts.org/images/products/779/389/000/1129/front_fr.8.400.jpg',5,1,1),
                              ('100000000003','Galletitas de agua 303g','Galletitas saladas',1,'https://images.openfoodfacts.org/images/products/779/808/274/4518/front_es.5.400.jpg',3,1,1),
                              ('100000000004','Bizcochos 200g','Bizcochos para mate',1,'https://images.openfoodfacts.org/images/products/841/037/603/5391/front_es.24.400.jpg',3,1,1),
                              ('100000000005','Pan rallado 500g','Rebozador',1,'https://images.openfoodfacts.org/images/products/841/480/754/3721/front_es.3.400.jpg',9,1,1),

                              ('100000000006','Harina 000 1Kg Molinos','Harina de trigo',2,'https://images.openfoodfacts.org/images/products/777/261/900/0278/front_es.4.400.jpg',5,1,1),
                              ('100000000007','Harina leudante 1Kg Molinos','Harina con leudante',2,'https://images.openfoodfacts.org/images/products/779/218/014/0708/front_es.20.400.jpg',5,1,1),
                              ('100000000008','Arroz largo fino 1Kg Gallo','Arroz largo fino',2,'https://images.openfoodfacts.org/images/products/177/905/031/59693/front_es.3.400.jpg',8,1,1),
                              ('100000000009','Polenta 500g','Harina de maíz',2,'https://images.openfoodfacts.org/images/products/400/604/012/0698/front_en.20.400.jpg',9,1,1),
                              ('100000000010','Avena 500g','Avena arrollada',2,'https://images.openfoodfacts.org/images/products/842/690/410/3647/front_es.5.400.jpg',5,1,1),
                              ('100000000011','Sémola 500g','Sémola de trigo',2,'https://images.openfoodfacts.org/images/products/801/178/090/9713/front_fr.4.400.jpg',9,1,1),
                              ('100000000012','Harina de maíz 1Kg','Harina de maíz',2,'https://placehold.co/300x300?text=Harina%20de%20ma%C3%ADz%201Kg',9,1,1),

                              ('100000000013','Fideos secos spaghetti 500g Lucchetti','Pasta seca larga',3,'https://placehold.co/300x300?text=Fideos%20secos%20spaghetti%20500g%20Lucchetti',6,1,1),
                              ('100000000014','Fideos secos tirabuzón 500g Matarazzo','Pasta seca corta',3,'https://placehold.co/300x300?text=Fideos%20secos%20tirabuz%C3%B3n%20500g%20Matarazzo',7,1,1),
                              ('100000000015','Fideos secos mostachol 500g Lucchetti','Pasta seca corta',3,'https://placehold.co/300x300?text=Fideos%20secos%20mostachol%20500g%20Lucchetti',6,1,1),
                              ('100000000016','Lentejas secas 400g','Legumbre seca',3,'https://images.openfoodfacts.org/images/products/848/000/005/3251/front_es.49.400.jpg',9,1,1),
                              ('100000000017','Arvejas secas 400g','Legumbre seca',3,'https://images.openfoodfacts.org/images/products/779/661/330/8543/front_es.3.400.jpg',9,1,1),
                              ('100000000018','Porotos secos 400g','Legumbre seca',3,'https://images.openfoodfacts.org/images/products/779/229/027/9008/front_en.8.400.jpg',9,1,1),
                              ('100000000019','Purè de tomate 520g','Tomate triturado',3,'https://images.openfoodfacts.org/images/products/779/058/013/8844/front_es.8.400.jpg',9,1,1),
                              ('100000000020','Salsa de tomate 340g','Salsa lista',3,'https://images.openfoodfacts.org/images/products/779/058/096/9400/front_es.10.400.jpg',9,1,1),

                              ('100000000021','Carne picada 1Kg','Carne vacuna picada',4,'https://images.openfoodfacts.org/images/products/843/656/926/3174/front_es.39.400.jpg',9,1,1),
                              ('100000000022','Carne para milanesa 1Kg','Nalga/cuadrada',4,'https://images.openfoodfacts.org/images/products/234/947/400/6483/front_es.4.400.jpg',9,1,1),
                              ('100000000023','Pollo entero 1Kg','Pollo fresco',4,'https://images.openfoodfacts.org/images/products/230/278/100/4542/front_es.4.400.jpg',9,1,1),
                              ('100000000024','Pescado congelado 1Kg','Filet congelado',4,'https://images.openfoodfacts.org/images/products/848/000/024/0200/front_es.53.400.jpg',9,1,1),
                              ('100000000025','Carne para guiso 1Kg','Osobuco/paleta',4,'https://images.openfoodfacts.org/images/products/841/030/035/5397/front_fr.7.400.jpg',9,1,1),

                              ('100000000026','Leche entera 1L Sancor','Leche UAT entera',5,'https://images.openfoodfacts.org/images/products/779/074/230/6302/front_es.7.400.jpg',2,1,1),
                              ('100000000027','Leche descremada 1L La Serenísima','Leche UAT descremada',5,'https://images.openfoodfacts.org/images/products/779/008/003/7715/front_es.5.400.jpg',1,1,1),
                              ('100000000028','Yogur firme 190g','Yogur firme',5,'https://images.openfoodfacts.org/images/products/779/133/700/7000/front_es.3.400.jpg',1,1,1),
                              ('100000000029','Queso cremoso 1Kg','Queso blando',5,'https://images.openfoodfacts.org/images/products/762/220/172/4443/front_en.21.400.jpg',1,1,1),
                              ('100000000030','Manteca 200g','Manteca',5,'https://images.openfoodfacts.org/images/products/779/074/234/5707/front_es.3.400.jpg',2,1,1),
                              ('100000000031','Crema de leche 200cc','Crema',5,'https://images.openfoodfacts.org/images/products/779/008/003/3199/front_es.3.400.jpg',1,1,1),
                              ('100000000032','Huevos docena','Huevos',5,'https://images.openfoodfacts.org/images/products/842/796/572/2464/front_es.4.400.jpg',9,1,1),

                              ('100000000033','Papa 1Kg','Papa',6,'https://images.openfoodfacts.org/images/products/541/308/199/0033/front_fr.40.400.jpg',9,1,1),
                              ('100000000034','Cebolla 1Kg','Cebolla',6,'https://images.openfoodfacts.org/images/products/843/700/027/0669/front_es.3.400.jpg',9,1,1),
                              ('100000000035','Tomate 1Kg','Tomate',6,'https://images.openfoodfacts.org/images/products/366/099/200/1767/front_fr.3.400.jpg',9,1,1),
                              ('100000000036','Zanahoria 1Kg','Zanahoria',6,'https://images.openfoodfacts.org/images/products/848/000/016/7521/front_es.56.400.jpg',9,1,1),
                              ('100000000037','Lechuga unidad','Lechuga',6,'https://placehold.co/300x300?text=Lechuga%20unidad',9,1,1),
                              ('100000000038','Manzana 1Kg','Manzana',6,'https://images.openfoodfacts.org/images/products/840/200/101/2174/front_es.51.400.jpg',9,1,1),
                              ('100000000039','Banana 1Kg','Banana',6,'https://images.openfoodfacts.org/images/products/600/398/900/3042/front_en.3.400.jpg',9,1,1),
                              ('100000000040','Naranja 1Kg','Naranja',6,'https://images.openfoodfacts.org/images/products/841/037/604/7578/front_es.61.400.jpg',9,1,1),

                              ('100000000041','Azúcar 1Kg Ledesma','Azúcar común',7,'https://images.openfoodfacts.org/images/products/779/254/025/0450/front_es.8.400.jpg',4,1,1),
                              ('100000000042','Dulce de leche 400g','Dulce de leche',7,'https://images.openfoodfacts.org/images/products/779/074/214/4607/front_es.21.400.jpg',2,1,1),
                              ('100000000043','Mermelada 454g','Mermelada',7,'https://images.openfoodfacts.org/images/products/779/058/012/3437/front_es.3.400.jpg',3,1,1),
                              ('100000000044','Galletitas dulces 300g','Galletitas dulces',7,'https://images.openfoodfacts.org/images/products/779/004/012/6800/front_es.10.400.jpg',3,1,1),
                              ('100000000045','Cacao en polvo 180g','Cacao',7,'https://images.openfoodfacts.org/images/products/750/223/094/7238/front_es.4.400.jpg',3,1,1),

                              ('100000000046','Aceite mezcla 1.5L Cocinero','Aceite vegetal',8,'https://placehold.co/300x300?text=Aceite%20mezcla%201.5L%20Cocinero',11,1,1),
                              ('100000000047','Aceite girasol 1.5L Natura','Aceite de girasol',8,'https://images.openfoodfacts.org/images/products/779/027/200/1005/front_es.44.400.jpg',10,1,1),
                              ('100000000048','Grasa vacuna 500g','Grasa',8,'https://images.openfoodfacts.org/images/products/773/013/200/1677/front_es.3.400.jpg',9,1,1),
                              ('100000000049','Margarina 200g','Margarina',8,'https://placehold.co/300x300?text=Margarina%20200g%20Arcor',3,1,1),

                              ('100000000050','Yerba mate 1Kg Taragüi','Yerba mate',9,'https://images.openfoodfacts.org/images/products/779/038/711/3228/front_fr.3.400.jpg',13,2,1),
                              ('100000000051','Yerba mate 1Kg Amanda','Yerba mate',9,'https://images.openfoodfacts.org/images/products/779/271/000/0021/front_fr.13.400.jpg',12,2,1),
                              ('100000000052','Té 50 saquitos','Té negro',9,'https://placehold.co/300x300?text=T%C3%A9%2050%20saquitos%20CBS%C3%A9',14,2,1),
                              ('100000000053','Café molido 250g La Virginia','Café',9,'https://images.openfoodfacts.org/images/products/779/015/003/7072/front_es.3.400.jpg',14,2,1),
                              ('100000000054','Mate cocido 25 saquitos','Mate cocido',9,'https://placehold.co/300x300?text=Mate%20cocido%2025%20saquitos%20Amanda',15,2,1),

                              ('100000000055','Agua mineral 2L','Agua sin gas',10,'https://images.openfoodfacts.org/images/products/841/204/250/2367/front_es.26.400.jpg',9,2,1),
                              ('100000000056','Agua mineral 500ml','Agua sin gas',10,'https://images.openfoodfacts.org/images/products/789/490/053/0001/front_pt.30.400.jpg',9,2,1),
                              ('100000000057','Jugo en polvo 18g','Jugo en polvo',10,'https://images.openfoodfacts.org/images/products/779/058/010/6041/front_es.4.400.jpg',3,2,1),
                              ('100000000058','Gaseosa cola 2.25L','Gaseosa',10,'https://images.openfoodfacts.org/images/products/775/018/200/1687/front_es.21.400.jpg',9,2,1),
                              ('100000000059','Gaseosa naranja 2.25L','Gaseosa',10,'https://images.openfoodfacts.org/images/products/759/103/100/0228/front_es.3.400.jpg',9,2,1),

                              ('100000000060','Lavandina 1L Ayudín','Lavandina',11,'https://placehold.co/300x300?text=Lavandina%201L%20Ayud%C3%ADn',17,3,1),
                              ('100000000061','Desinfectante 1L Ayudín','Desinfectante',11,'https://images.openfoodfacts.org/images/products/779/325/300/5221/front_es.3.400.jpg',17,3,1),
                              ('100000000062','Limpiador piso 900ml Poett','Limpieza pisos',11,'https://placehold.co/300x300?text=Limpiador%20piso%20900ml%20Poett',18,3,1),
                              ('100000000063','Detergente cocina 750ml','Lavavajillas',11,'https://placehold.co/300x300?text=Detergente%20cocina%20750ml',9,3,1),
                              ('100000000064','Esponja de cocina','Esponja',11,'https://placehold.co/300x300?text=Esponja%20de%20cocina',9,3,1),
                              ('100000000065','Limpiavidrios 500ml','Vidrios',11,'https://placehold.co/300x300?text=Limpiavidrios%20500ml%20Poett',18,3,1),

                              ('100000000066','Jabón en polvo 800g Ala','Jabón en polvo',12,'https://placehold.co/300x300?text=Jab%C3%B3n%20en%20polvo%20800g%20Ala',16,3,1),
                              ('100000000067','Jabón líquido ropa 3L','Jabón líquido',12,'https://placehold.co/300x300?text=Jab%C3%B3n%20l%C3%ADquido%20ropa%203L%20Ala',16,3,1),
                              ('100000000068','Suavizante 1L','Suavizante',12,'https://placehold.co/300x300?text=Suavizante%201L%20Ala',16,3,1),
                              ('100000000069','Quitamanchas 450ml','Quitamanchas',12,'https://placehold.co/300x300?text=Quitamanchas%20450ml%20Ala',16,3,1),
                              ('100000000070','Lavandina concentrada 2L','Lavandina concentrada',12,'https://placehold.co/300x300?text=Lavandina%20concentrada%202L%20Ayud%C3%ADn',17,3,1),

                              ('100000000071','Jabón tocador 3x90g','Jabón de tocador',13,'https://placehold.co/300x300?text=Jab%C3%B3n%20tocador%203x90g',9,4,1),
                              ('100000000072','Shampoo 400ml','Shampoo',13,'https://images.openfoodfacts.org/images/products/405/648/982/7184/front_en.3.400.jpg',9,4,1),
                              ('100000000073','Acondicionador 400ml','Acondicionador',13,'https://images.openfoodfacts.org/images/products/000/001/221/1111/front_fr.9.400.jpg',9,4,1),
                              ('100000000074','Pasta dental 90g Colgate','Pasta dental',13,'https://placehold.co/300x300?text=Pasta%20dental%2090g%20Colgate',20,4,1),
                              ('100000000075','Cepillo dental','Cepillo dental',13,'https://placehold.co/300x300?text=Cepillo%20dental%20Colgate',20,4,1),
                              ('100000000076','Desodorante aerosol 150ml','Desodorante',13,'https://placehold.co/300x300?text=Desodorante%20aerosol%20150ml',9,4,1),
                              ('100000000077','Toallitas femeninas','Higiene femenina',13,'https://images.openfoodfacts.org/images/products/779/077/060/2087/front_en.3.400.jpg',19,4,1),

                              ('100000000078','Papel higiénico 4 rollos Higienol','Papel higiénico',14,'https://placehold.co/300x300?text=Papel%20higi%C3%A9nico%204%20rollos%20Higienol',19,4,1),
                              ('100000000079','Papel higiénico 6 rollos Higienol','Papel higiénico',14,'https://placehold.co/300x300?text=Papel%20higi%C3%A9nico%206%20rollos%20Higienol',19,4,1),
                              ('100000000080','Servilletas 200u','Servilletas',14,'https://placehold.co/300x300?text=Servilletas%20200u%20Higienol',19,4,1),
                              ('100000000081','Pañuelos descartables','Pañuelos',14,'https://placehold.co/300x300?text=Pa%C3%B1uelos%20descartables%20Higienol',19,4,1),
                              ('100000000082','Toalla de papel','Rollo cocina',14,'https://placehold.co/300x300?text=Toalla%20de%20papel%20Higienol',19,4,1),

                              ('100000000083','Sal fina 500g','Sal de mesa',15,'https://images.openfoodfacts.org/images/products/000/002/008/4820/front_es.41.400.jpg',9,5,1),
                              ('100000000084','Vinagre alcohol 1L','Vinagre',15,'https://images.openfoodfacts.org/images/products/750/105/247/5004/front_es.9.400.jpg',9,5,1),
                              ('100000000085','Caldo cubitos','Caldo',15,'https://placehold.co/300x300?text=Caldo%20cubitos%20Arcor',3,5,1),
                              ('100000000086','Purè instantáneo 125g','Purè instantáneo',15,'https://placehold.co/300x300?text=Pur%C3%A8%20instant%C3%A1neo%20125g%20Molinos',5,5,1),
                              ('100000000087','Mayonesa 500g','Mayonesa',15,'https://placehold.co/300x300?text=Mayonesa%20500g%20Arcor',3,5,1),
                              ('100000000088','Mostaza 250g','Mostaza',15,'https://placehold.co/300x300?text=Mostaza%20250g%20Arcor',3,5,1),
                              ('100000000089','Fideos guiseros 500g','Pasta corta',3,'https://placehold.co/300x300?text=Fideos%20guiseros%20500g%20Matarazzo',7,1,1),
                              ('100000000090','Arroz parboil 1Kg','Arroz',2,'https://images.openfoodfacts.org/images/products/779/007/041/3765/front_es.3.400.jpg',8,1,1),
                              ('100000000091','Azúcar 1Kg (económica)','Azúcar',7,'https://placehold.co/300x300?text=Az%C3%BAcar%201Kg%20%28econ%C3%B3mica%29',9,1,1),
                              ('100000000092','Aceite 900ml','Aceite',8,'https://images.openfoodfacts.org/images/products/841/017/901/6542/front_es.8.400.jpg',10,1,1),
                              ('100000000093','Leche en polvo 400g','Leche en polvo',5,'https://images.openfoodfacts.org/images/products/779/008/004/4188/front_es.12.400.jpg',2,1,1),
                              ('100000000094','Queso rallado 40g','Queso rallado',5,'https://images.openfoodfacts.org/images/products/779/008/001/4709/front_es.11.400.jpg',1,1,1),
                              ('100000000095','Tomate triturado 520g','Triturado',3,'https://images.openfoodfacts.org/images/products/848/000/016/0447/front_es.52.400.jpg',9,1,1),
                              ('100000000096','Atún en lata 170g','Atún',3,'https://images.openfoodfacts.org/images/products/841/020/503/2386/front_es.44.400.jpg',9,1,1),
                              ('100000000097','Fideos moñitos 500g','Pasta corta',3,'https://placehold.co/300x300?text=Fideos%20mo%C3%B1itos%20500g%20Lucchetti',6,1,1),
                              ('100000000098','Arvejas en lata 300g','Arvejas',3,'https://images.openfoodfacts.org/images/products/779/229/027/9206/front_es.5.400.jpg',9,1,1),
                              ('100000000099','Levadura seca 10g','Levadura',1,'https://images.openfoodfacts.org/images/products/000/004/210/0263/front_es.8.400.jpg',9,5,1),
                              ('100000000100','Leche chocolatada 1L','Bebida láctea',10,'https://images.openfoodfacts.org/images/products/779/074/217/2204/front_es.12.400.jpg',1,2,1);

-- PRECIOS (muy disperso)
DECLARE @precios TABLE(cod_barra varchar(50) PRIMARY KEY, precio decimal(10,2));

INSERT INTO @precios(cod_barra, precio) VALUES
                                            ('100000000001', 1700.00),('100000000002', 4590.00),('100000000003', 1300.00),('100000000004', 3100.00),('100000000005', 1650.00),
                                            ('100000000006', 1490.00),('100000000007', 2990.00),('100000000008', 1990.00),('100000000009', 2890.00),('100000000010', 1690.00),
                                            ('100000000011', 990.00), ('100000000012', 3490.00),
                                            ('100000000013', 1200.00),('100000000014', 2990.00),('100000000015', 1390.00),('100000000016', 3990.00),('100000000017', 1890.00),
                                            ('100000000018', 4490.00),('100000000019', 1290.00),('100000000020', 3890.00),
                                            ('100000000021', 7200.00),('100000000022', 16900.00),('100000000023', 5900.00),('100000000024', 13900.00),('100000000025', 7900.00),
                                            ('100000000026', 1590.00),('100000000027', 3490.00),('100000000028', 890.00), ('100000000029', 18900.00),('100000000030', 1990.00),
                                            ('100000000031', 4590.00),('100000000032', 2390.00),
                                            ('100000000033', 990.00), ('100000000034', 2990.00),('100000000035', 1290.00),('100000000036', 3590.00),('100000000037', 890.00),
                                            ('100000000038', 3890.00),('100000000039', 1490.00),('100000000040', 4290.00),
                                            ('100000000041', 1890.00),('100000000042', 7900.00),('100000000043', 2190.00),('100000000044', 4890.00),('100000000045', 1590.00),
                                            ('100000000046', 3490.00),('100000000047', 9900.00),('100000000048', 1290.00),('100000000049', 3890.00),
                                            ('100000000050', 3990.00),('100000000051', 8990.00),('100000000052', 1490.00),('100000000053', 11900.00),('100000000054', 1290.00),
                                            ('100000000055', 790.00), ('100000000056', 2190.00),('100000000057', 690.00), ('100000000058', 8990.00),('100000000059', 3590.00),
                                            ('100000000060', 1290.00),('100000000061', 5990.00),('100000000062', 1690.00),('100000000063', 3890.00),('100000000064', 690.00),
                                            ('100000000065', 5490.00),
                                            ('100000000066', 2990.00),('100000000067', 16900.00),('100000000068', 2590.00),('100000000069', 6990.00),('100000000070', 2190.00),
                                            ('100000000071', 1090.00),('100000000072', 5890.00),('100000000073', 1890.00),('100000000074', 5490.00),('100000000075', 1190.00),
                                            ('100000000076', 6990.00),('100000000077', 1690.00),
                                            ('100000000078', 2890.00),('100000000079', 10900.00),('100000000080', 1490.00),('100000000081', 1390.00),('100000000082', 5990.00),
                                            ('100000000083', 490.00), ('100000000084', 2990.00),('100000000085', 790.00), ('100000000086', 3490.00),('100000000087', 1490.00),
                                            ('100000000088', 4890.00),('100000000089', 1290.00),('100000000090', 4990.00),('100000000091', 1190.00),('100000000092', 8990.00),
                                            ('100000000093', 4990.00),('100000000094', 3290.00),('100000000095', 1490.00),('100000000096', 7990.00),('100000000097', 1390.00),
                                            ('100000000098', 5490.00),('100000000099', 390.00), ('100000000100', 2990.00);

INSERT INTO dbo.productos_sucursales(nro_sucursal, cod_barra, precio)
SELECT s.nro_sucursal, p.cod_barra, p.precio
FROM dbo.sucursales s CROSS JOIN @precios p;

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
