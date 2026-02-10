/* ============================
   CREACIÓN DE ESQUEMA
============================ */
USE master
GO


IF EXISTS(SELECT *
FROM sys.databases
WHERE name = 'supermercado2')
BEGIN
    ALTER DATABASE supermercado2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE supermercado2;
END
GO


CREATE DATABASE supermercado2;
GO

USE supermercado2;
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
    imagen varchar(100) NOT NULL,
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
    SELECT (
               SELECT
                   s.nro_sucursal,
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
                   JSON_QUERY((
                       SELECT
                           hs.dia_semana,
                           CONVERT(varchar(5), hs.hora_desde, 108) AS hora_desde,
                           CONVERT(varchar(5), hs.hora_hasta, 108) AS hora_hasta
                       FROM dbo.horarios_sucursales hs
                       WHERE hs.nro_sucursal = s.nro_sucursal
                       ORDER BY hs.dia_semana
                       FOR JSON PATH
                   )) AS horarios,
                   JSON_QUERY((
                       SELECT
                           ss.nro_tipo_servicio,
                           sp.nom_tipo_servicio
                       FROM dbo.tipos_servicios_sucursales ss
                                JOIN dbo.tipos_servicios_supermercado sp
                                     ON sp.nro_tipo_servicio = ss.nro_tipo_servicio
                       WHERE ss.nro_sucursal = s.nro_sucursal
                         AND ss.vigente = 1
                       ORDER BY sp.nom_tipo_servicio
                       FOR JSON PATH
                   )) AS servicios
               FROM dbo.sucursales s
                        JOIN dbo.localidades l
                             ON l.nro_localidad = s.nro_localidad
                        JOIN dbo.provincias p
                             ON p.cod_provincia = l.cod_provincia
                                 AND p.cod_pais      = l.cod_pais
                        JOIN dbo.paises pa
                             ON pa.cod_pais = p.cod_pais
               WHERE s.habilitada = 1
               ORDER BY s.nom_sucursal
               FOR JSON PATH, ROOT('sucursales')
           ) AS json;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_productos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT (
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
                   ps.precio
               FROM dbo.productos_sucursales ps
                        JOIN dbo.productos p
                             ON ps.cod_barra = p.cod_barra
                        JOIN dbo.categorias_productos c
                             ON p.nro_categoria = c.nro_categoria
                        JOIN dbo.rubros_productos r
                             ON c.nro_rubro = r.nro_rubro
                        JOIN dbo.marcas_productos m
                             ON p.nro_marca = m.nro_marca
                        JOIN dbo.tipos_productos t
                             ON p.nro_tipo_producto = t.nro_tipo_producto
                        JOIN dbo.sucursales s
                             ON ps.nro_sucursal = s.nro_sucursal
               WHERE ps.vigente = 1
                 AND p.vigente  = 1
                 AND c.vigente  = 1
                 AND r.vigente  = 1
                 AND s.habilitada = 1
               ORDER BY ps.nro_sucursal, r.nom_rubro, c.nom_categoria, p.nom_producto
               FOR JSON PATH, ROOT('productosSucursales')
           ) AS json;
END
GO

/* ============================
   DATOS INICIALES (PAÍSES/PROVINCIAS/LOCALIDADES/SUCURSALES/SERVICIOS)
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
        ('30-63986527-2','ChangoMas Argentina S.A.','Avenida San Martín',4560,'011-4632-5487');

INSERT INTO dbo.tipos_servicios_supermercado (nom_tipo_servicio) VALUES
         ('DELIVERY'),
         ('PICKUP'),
         ('PAGO ONLINE'),
         ('PARKING'),
         ('ACCESO ESPECIAL'),
         ('ATENCIÓN AL CLIENTE'),
         ('FARMACIA'),
         ('AUTOSERVICIO'),
         ('CARGA DE SUBE'),
         ('CAJA RÁPIDA');

INSERT INTO dbo.sucursales (nom_sucursal, calle, nro_calle, telefonos, coord_latitud, coord_longitud, nro_localidad) VALUES
        ('ChangoMas La Plata', 'Calle 32', 1200, '0221-455-7896', -34.9214, -57.9544, 2),
        ('ChangoMas Mar del Plata', 'Avenida Independencia', 4500, '0223-472-1234', -37.9977, -57.5491, 3),
        ('ChangoMas Córdoba', 'Avenida Rafael Núñez', 5200, '0351-478-9012', -31.4135, -64.1811, 4),
        ('ChangoMas Rosario', 'Boulevard Oroño', 5300, '0341-467-2345', -32.9442, -60.6505, 5),
        ('ChangoMas Buenos Aires', 'Avenida Cabildo', 1234, '011-4785-6789', -34.5683, -58.4488, 1);

INSERT INTO dbo.horarios_sucursales (nro_sucursal, dia_semana, hora_desde, hora_hasta) VALUES
       (1, 1, '08:00', '22:00'), (1, 2, '08:00', '22:00'), (1, 3, '08:00', '22:00'),
       (1, 4, '08:00', '22:00'), (1, 5, '08:00', '22:00'), (1, 6, '08:00', '14:00'),
       (2, 1, '08:00', '22:00'), (2, 2, '08:00', '22:00'), (2, 3, '08:00', '22:00'),
       (2, 4, '08:00', '22:00'), (2, 5, '08:00', '22:00'), (2, 6, '08:00', '15:00'),
       (3, 1, '08:00', '22:00'), (3, 2, '08:00', '22:00'), (3, 3, '08:00', '22:00'),
       (3, 4, '08:00', '22:00'), (3, 5, '08:00', '22:00'), (3, 6, '08:00', '13:00'),
       (4, 1, '08:00', '22:00'), (4, 2, '08:00', '22:00'), (4, 3, '08:00', '22:00'),
       (4, 4, '08:00', '22:00'), (4, 5, '08:00', '22:00'), (4, 6, '08:00', '13:00'),
       (5, 1, '08:00', '22:00'), (5, 2, '08:00', '22:00'), (5, 3, '08:00', '22:00'),
       (5, 4, '08:00', '22:00'), (5, 5, '08:00', '22:00'), (5, 6, '08:00', '13:00');

INSERT INTO dbo.tipos_servicios_sucursales (nro_sucursal, nro_tipo_servicio, vigente) VALUES
      (1, 1, 1),(1, 2, 1),(1, 3, 1),(1, 4, 1),(1, 10, 1),
      (2, 1, 1),(2, 2, 1),(2, 5, 1),(2, 9, 1),
      (3, 1, 1),(3, 4, 1),(3, 7, 1),
      (4, 3, 1),(4, 4, 1),(4, 6, 1),
      (5, 1, 1),(5, 2, 1),(5, 8, 1);

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
            ('Alimentos'),('Bebidas'),('Limpieza'),('Higiene Personal'),('Electrónica');

INSERT INTO dbo.categorias_productos(nom_categoria, nro_rubro) VALUES
           ('Lácteos',1),('Fiambres',1),('Snacks',1),('Galletitas',1),('Pastas Secas',1),
           ('Bebidas sin alcohol',2),('Bebidas alcohólicas',2),('Jugos',2),('Cerveza',2),('Vinos',2),
           ('Limpieza Hogar',3),('Lavandería',3),
           ('Cuidado Personal',4),('Perfumería',4),
           ('Electrodomésticos',5);

INSERT INTO dbo.marcas_productos(nom_marca) VALUES
            ('La Serenísima'),('Sancor'),('Coca-Cola'),('Pepsi'),('Manaos'),
            ('Terrabusi'),('Arcor'),('Lucchetti'),('Knorr'),
            ('Quilmes'),('Stella Artois'),('Trapiche'),
            ('Nivea'),('Colgate'),('Procter & Gamble'),
            ('Philips'),('Samsung'),('LG'),('Sony'),('P&G');

INSERT INTO dbo.tipos_productos(nom_tipo_producto) VALUES
           ('Bebida'),('Alimento'),('Higiene'),('Limpieza'),('Electrónica');

INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 2 FROM dbo.marcas_productos WHERE nom_marca IN ('La Serenísima','Sancor','Arcor','Lucchetti','Knorr','Terrabusi');
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 1 FROM dbo.marcas_productos WHERE nom_marca IN ('Coca-Cola','Pepsi','Manaos','Quilmes','Stella Artois','Trapiche');
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 3 FROM dbo.marcas_productos WHERE nom_marca IN ('Nivea','Colgate','Procter & Gamble','P&G');
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 4 FROM dbo.marcas_productos WHERE nom_marca = 'Procter & Gamble';
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 5 FROM dbo.marcas_productos WHERE nom_marca IN ('Philips','Samsung','LG','Sony');

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

BEGIN TRY
BEGIN TRANSACTION;

/* LÁCTEOS (1) */
INSERT INTO dbo.productos VALUES
           ('100000000001','Leche entera 1L La Serenísima','Leche UAT entera 1L',1,'leche_entera_ls.jpg',1,2,1),
           ('100000000002','Leche descremada 1L Sancor','Leche UAT descremada 1L',1,'leche_descremada_sc.jpg',2,2,1),
           ('100000000003','Yogur firme vainilla 190g La Serenísima','Yogur firme sabor vainilla',1,'yogur_vainilla_ls.jpg',1,2,1),
           ('100000000004','Yogur bebible frutilla 1L Sancor','Yogur bebible sabor frutilla',1,'yogur_bebible_sc.jpg',2,2,1),
           ('100000000005','Queso cremoso 1Kg La Serenísima','Queso blando cremoso',1,'queso_cremoso_ls.jpg',1,2,1),
           ('100000000006','Queso tybo 1Kg Sancor','Queso semiduro tybo',1,'queso_tybo_sc.jpg',2,2,1),
           ('100000000007','Manteca 200g La Serenísima','Manteca clásica 200g',1,'manteca_ls.jpg',1,2,1),
           ('100000000008','Crema de leche 200cc Sancor','Crema clásica 200cc',1,'crema_sc.jpg',2,2,1);

/* FIAMBRES (2) */
INSERT INTO dbo.productos VALUES
          ('100000000009','Jamón cocido feteado 200g Arcor','Jamón cocido',2,'jamon_cocido_arcor.jpg',7,2,1),
          ('100000000010','Salame milán 200g Arcor','Fiambre salame tipo milán',2,'salame_arcor.jpg',7,2,1),
          ('100000000011','Mortadela 200g Arcor','Mortadela feteada',2,'mortadela_arcor.jpg',7,2,1),
          ('100000000012','Pechuga de pavo 200g Arcor','Feteado de pavo',2,'pavo_arcor.jpg',7,2,1),
          ('100000000013','Queso sandwich feteado 200g La Serenísima','Queso feteado',2,'queso_feteado_ls.jpg',1,2,1);

/* SNACKS (3) */
INSERT INTO dbo.productos VALUES
          ('100000000014','Papas fritas clásicas 90g Arcor','Snack de papa clásico',3,'papas_arcor.jpg',7,2,1),
          ('100000000015','Papas fritas onduladas 90g Arcor','Snack ondulado',3,'papas_ond_arcor.jpg',7,2,1),
          ('100000000016','Maní salado 150g Arcor','Maní tostado salado',3,'mani_arcor.jpg',7,2,1),
          ('100000000017','Palitos salados 100g Terrabusi','Snack salado',3,'palitos_terrabusi.jpg',6,2,1),
          ('100000000018','Nachos 150g Arcor','Triángulos de maíz',3,'nachos_arcor.jpg',7,2,1);

/* GALLETITAS (4) */
INSERT INTO dbo.productos VALUES
          ('100000000019','Oreo 117g Terrabusi','Galletitas con crema',4,'oreo_terrabusi.jpg',6,2,1),
          ('100000000020','Chocolinas 170g Arcor','Galletitas de chocolate',4,'chocolinas_arcor.jpg',7,2,1),
          ('100000000021','Criollitas 100g Arcor','Galletitas de agua',4,'criollitas_arcor.jpg',7,2,1),
          ('100000000022','Sonrisas 118g Terrabusi','Galletitas rellenas',4,'sonrisas_terrabusi.jpg',6,2,1),
          ('100000000023','Melba 170g Terrabusi','Galletitas dulces',4,'melba_terrabusi.jpg',6,2,1);

/* PASTAS SECAS (5) */
INSERT INTO dbo.productos VALUES
          ('100000000024','Spaghetti 500g Lucchetti','Pasta seca larga',5,'spaghetti_lucchetti.jpg',8,2,1),
          ('100000000025','Mostachol 500g Lucchetti','Pasta seca corta',5,'mostachol_lucchetti.jpg',8,2,1),
          ('100000000026','Tirabuzón 500g Lucchetti','Pasta seca corta',5,'tirabuzon_lucchetti.jpg',8,2,1),
          ('100000000027','Fideos al huevo 500g Lucchetti','Pasta con huevo',5,'huevo_lucchetti.jpg',8,2,1),
          ('100000000028','Salsa boloñesa 340g Knorr','Salsa lista',5,'bolonesa_knorr.jpg',9,2,1),
          ('100000000029','Salsa fileto 340g Knorr','Salsa lista',5,'fileto_knorr.jpg',9,2,1);

/* BEBIDAS SIN ALCOHOL (6) */
INSERT INTO dbo.productos VALUES
          ('100000000030','Coca-Cola 2.25L','Gaseosa cola 2.25L',6,'coca225.jpg',3,1,1),
          ('100000000031','Coca-Cola Zero 2.25L','Gaseosa sin azúcar',6,'cocazero225.jpg',3,1,1),
          ('100000000032','Pepsi 2.25L','Gaseosa cola 2.25L',6,'pepsi225.jpg',4,1,1),
          ('100000000033','Manaos Cola 2.25L','Gaseosa económica',6,'manaos_cola225.jpg',5,1,1),
          ('100000000034','Manaos Naranja 2.25L','Gaseosa sabor naranja',6,'manaos_naranja225.jpg',5,1,1);

/* JUGOS (8) */
INSERT INTO dbo.productos VALUES
          ('100000000035','Jugo en polvo BC Naranja 15g Arcor','Polvo para preparar 1L',8,'bc_naranja_arcor.jpg',7,2,1),
          ('100000000036','Jugo en polvo BC Manzana 15g Arcor','Polvo para preparar 1L',8,'bc_manzana_arcor.jpg',7,2,1),
          ('100000000037','Jugo en polvo BC Pomelo 15g Arcor','Polvo para preparar 1L',8,'bc_pomelo_arcor.jpg',7,2,1);

/* CERVEZA (9) */
INSERT INTO dbo.productos VALUES
          ('100000000038','Cerveza Quilmes 1L','Rubia retornable',9,'quilmes1l.jpg',10,1,1),
          ('100000000039','Cerveza Quilmes lata 473ml','Rubia lata',9,'quilmes_lata.jpg',10,1,1),
          ('100000000040','Cerveza Stella Artois 1L','Premium rubia',9,'stella1l.jpg',11,1,1),
          ('100000000041','Cerveza Stella Artois lata 473ml','Premium lata',9,'stella_lata.jpg',11,1,1),
          ('100000000042','Cerveza Quilmes Bock 1L','Bock',9,'quilmes_bock.jpg',10,1,1);

/* VINOS (10) */
INSERT INTO dbo.productos VALUES
          ('100000000043','Vino Trapiche Malbec 750ml','Tinto Malbec',10,'trapiche_malbec.jpg',12,1,1),
          ('100000000044','Vino Trapiche Cabernet 750ml','Tinto Cabernet',10,'trapiche_cab.jpg',12,1,1),
          ('100000000045','Vino Trapiche Chardonnay 750ml','Blanco Chardonnay',10,'trapiche_chard.jpg',12,1,1),
          ('100000000046','Vino Trapiche Reserva Malbec 750ml','Tinto Reserva',10,'trapiche_reserva.jpg',12,1,1);

/* LIMPIEZA HOGAR (11) */
INSERT INTO dbo.productos VALUES
          ('100000000047','Lavandina 1L P&G','Desinfectante hogar',11,'lavandina_pg.jpg',15,4,1),
          ('100000000048','Limpiador multiuso 900ml P&G','Multiuso',11,'multiuso_pg.jpg',15,4,1),
          ('100000000049','Desodorante de ambientes 360ml P&G','Aerosol',11,'ambientes_pg.jpg',15,4,1),
          ('100000000050','Limpiavidrios 500ml P&G','Vidrios/espejos',11,'vidrios_pg.jpg',15,4,1);

/* LAVANDERÍA (12) */
INSERT INTO dbo.productos VALUES
          ('100000000051','Jabón en polvo 800g P&G','Ropa blanca/color',12,'jabonpolvo_pg.jpg',15,4,1),
          ('100000000052','Detergente líquido 3L P&G','Detergente para ropa',12,'detergenteliq_pg.jpg',15,4,1),
          ('100000000053','Suavizante 1L P&G','Aroma y suavidad',12,'suavizante_pg.jpg',15,4,1),
          ('100000000054','Quita manchas 450ml P&G','Ropa con manchas difíciles',12,'quitamanchas_pg.jpg',15,4,1);

/* CUIDADO PERSONAL (13) */
INSERT INTO dbo.productos VALUES
          ('100000000055','Shampoo Nivea 400ml','Cuidado cabello',13,'shampoo_nivea.jpg',13,3,1),
          ('100000000056','Acondicionador Nivea 400ml','Cuidado cabello',13,'acond_nivea.jpg',13,3,1),
          ('100000000057','Jabón de tocador 125g P&G','Higiene personal',13,'jabon_tocador_pg.jpg',15,3,1),
          ('100000000058','Pasta dental Colgate Total 90g','Protección completa',13,'colgate_total.jpg',14,3,1),
          ('100000000059','Cepillo dental Colgate medio','Cepillo dental',13,'cepillo_colgate.jpg',14,3,1),
          ('100000000060','Enjuague bucal Colgate 500ml','Anticaries',13,'enjuague_colgate.jpg',14,3,1);

/* PERFUMERÍA (14) */
INSERT INTO dbo.productos VALUES
          ('100000000061','Desodorante Nivea Men aerosol 150ml','Antitranspirante',14,'deso_nivea_men.jpg',13,3,1),
          ('100000000062','Desodorante Nivea Women aerosol 150ml','Antitranspirante',14,'deso_nivea_women.jpg',13,3,1),
          ('100000000063','Crema corporal Nivea 250ml','Hidratación',14,'crema_corporal_nivea.jpg',13,3,1),
          ('100000000064','Crema de manos Nivea 100ml','Hidratación manos',14,'crema_manos_nivea.jpg',13,3,1);

/* ELECTRODOMÉSTICOS / ELECTRÓNICA (15) */
INSERT INTO dbo.productos VALUES
          ('100000000065','Smart TV Samsung 50" UHD','Televisor 4K 50"',15,'tv_samsung_50.jpg',17,5,1),
          ('100000000066','Smart TV LG 55" UHD','Televisor 4K 55"',15,'tv_lg_55.jpg',18,5,1),
          ('100000000067','Smart TV Sony 65" UHD','Televisor 4K 65"',15,'tv_sony_65.jpg',19,5,1),
          ('100000000068','Barra de sonido Samsung 2.1','Soundbar',15,'soundbar_samsung.jpg',17,5,1),
          ('100000000069','Auriculares Sony on-ear','Auriculares cableados',15,'auris_sony.jpg',19,5,1),
          ('100000000070','Auriculares Philips in-ear','In-ear cableados',15,'auris_philips.jpg',16,5,1),
          ('100000000071','Batidora Philips 400W','Batidora de mano',15,'batidora_philips.jpg',16,5,1),
          ('100000000072','Licuadora Philips 600W','Jarra plástica',15,'licuadora_philips.jpg',16,5,1);

/* MÁS LÁCTEOS / ALIMENTOS PARA COMPLETAR HASTA 100 */
INSERT INTO dbo.productos VALUES
          ('100000000073','Leche chocolatada 1L La Serenísima','Bebida láctea chocolate',1,'chocolatada_ls.jpg',1,2,1),
          ('100000000074','Queso rallado 40g Sancor','Rallado en sobre',1,'rallado_sc.jpg',2,2,1),
          ('100000000075','Dulce de leche 400g La Serenísima','Clásico',1,'ddl_ls.jpg',1,2,1),
          ('100000000076','Ricota 500g Sancor','Ricota fresca',1,'ricota_sc.jpg',2,2,1),
          ('100000000077','Postre vainilla 120g La Serenísima','Postre lácteo',1,'postre_vainilla_ls.jpg',1,2,1),
          ('100000000078','Muzzarella 500g Sancor','Queso mozzarella',1,'muza_sc.jpg',2,2,1);

/* MÁS PASTAS / SALSAS */
INSERT INTO dbo.productos VALUES
          ('100000000079','Mostachol 1Kg Lucchetti','Pasta seca 1Kg',5,'mostachol1kg_lucchetti.jpg',8,2,1),
          ('100000000080','Capelettini 500g Lucchetti','Pasta seca rellena',5,'capelettini_lucchetti.jpg',8,2,1),
          ('100000000081','Salsa 4 quesos 340g Knorr','Salsa lista',5,'4quesos_knorr.jpg',9,2,1),
          ('100000000082','Salsa tuco 340g Knorr','Salsa lista',5,'tuco_knorr.jpg',9,2,1);

/* MÁS GALLETITAS / SNACKS */
INSERT INTO dbo.productos VALUES
          ('100000000083','Express 170g Terrabusi','Galletitas agua',4,'express_terrabusi.jpg',6,2,1),
          ('100000000084','Mini Oreo 50g Terrabusi','Galletitas mini',4,'minioro_terrabusi.jpg',6,2,1),
          ('100000000085','Bizcochos de grasa 200g Arcor','Bizcochos',4,'bizcochos_arcor.jpg',7,2,1),
          ('100000000086','Maní japonés 120g Arcor','Snack crocante',3,'mani_jap_arcor.jpg',7,2,1),
          ('100000000087','Palitos de maíz 90g Arcor','Snack maíz',3,'palitos_maiz_arcor.jpg',7,2,1);

/* MÁS BEBIDAS SIN ALCOHOL / JUGOS */
INSERT INTO dbo.productos VALUES
          ('100000000088','Coca-Cola 1.5L','Gaseosa cola 1.5L',6,'coca15.jpg',3,1,1),
          ('100000000089','Pepsi 1.5L','Gaseosa cola 1.5L',6,'pepsi15.jpg',4,1,1),
          ('100000000090','Manaos Limón 2.25L','Gaseosa sabor limón',6,'manaos_limon225.jpg',5,1,1),
          ('100000000091','BC Naranja 30g Arcor','Jugo en polvo 2L',8,'bc_2l_naranja_arcor.jpg',7,2,1),
          ('100000000092','BC Pomelo 30g Arcor','Jugo en polvo 2L',8,'bc_2l_pomelo_arcor.jpg',7,2,1);

/* MÁS CERVEZA / VINOS */
INSERT INTO dbo.productos VALUES
          ('100000000093','Cerveza Quilmes Stout lata 473ml','Negra',9,'quilmes_stout_lata.jpg',10,1,1),
          ('100000000094','Cerveza Stella Noire lata 473ml','Edición especial',9,'stella_noire_lata.jpg',11,1,1),
          ('100000000095','Vino Trapiche Rosé 750ml','Rosado',10,'trapiche_rose.jpg',12,1,1);

/* MÁS LIMPIEZA / LAVANDERÍA */
INSERT INTO dbo.productos VALUES
          ('100000000096','Lavandina concentrada 2L P&G','Desinfectante concentrado',11,'lavandina2l_pg.jpg',15,4,1),
          ('100000000097','Detergente platos 750ml P&G','Lavavajillas',11,'platos_pg.jpg',15,4,1),
          ('100000000098','Quitasarro baño 500ml P&G','Limpieza baño',11,'quitasarro_pg.jpg',15,4,1),
          ('100000000099','Jabón líquido 1.8L P&G','Ropa color',12,'jabliquido_pg.jpg',15,4,1),
          ('100000000100','Suavizante 3L P&G','Aroma duradero',12,'suavizante3l_pg.jpg',15,4,1);

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

/* ============================
   PRECIOS (10 CAMBIOS vs supermercado1)
============================ */
BEGIN TRY
BEGIN TRANSACTION;

DECLARE @precios TABLE(cod_barra varchar(50) PRIMARY KEY, precio decimal(10,2));

-- BASE: mismos precios que supermercado1 ...
INSERT INTO @precios(cod_barra, precio) VALUES
-- Lácteos
('100000000001', 1500.00),('100000000002', 1550.00),('100000000003', 950.00),
('100000000004', 2100.00),('100000000005', 7800.00),('100000000006', 7600.00),
('100000000007', 1900.00),('100000000008', 1750.00),
-- Fiambres
('100000000009', 4500.00),('100000000010', 5200.00),('100000000011', 3500.00),
('100000000012', 5200.00),('100000000013', 2800.00),
-- Snacks
('100000000014', 1800.00),('100000000015', 1900.00),('100000000016', 2200.00),
('100000000017', 1600.00),('100000000018', 2300.00),
-- Galletitas
('100000000019', 2200.00),('100000000020', 2500.00),('100000000021', 1500.00),
('100000000022', 2100.00),('100000000023', 2000.00),
-- Pastas/Salsas
('100000000024', 1700.00),('100000000025', 1700.00),('100000000026', 1700.00),
('100000000027', 1850.00),('100000000028', 2500.00),('100000000029', 2400.00),
-- Bebidas sin alcohol
('100000000030', 4800.00),('100000000031', 5000.00),('100000000032', 4500.00),
('100000000033', 2900.00),('100000000034', 2900.00),
-- Jugos
('100000000035', 650.00),('100000000036', 650.00),('100000000037', 650.00),
-- Cerveza
('100000000038', 2400.00),('100000000039', 1700.00),('100000000040', 3200.00),
('100000000041', 2400.00),('100000000042', 2600.00),
-- Vinos
('100000000043', 5900.00),('100000000044', 6200.00),('100000000045', 5400.00),
('100000000046', 8500.00),
-- Limpieza hogar
('100000000047', 1200.00),('100000000048', 2300.00),('100000000049', 2100.00),
('100000000050', 2000.00),
-- Lavandería
('100000000051', 3900.00),('100000000052', 9800.00),('100000000053', 4800.00),
('100000000054', 5200.00),
-- Cuidado personal
('100000000055', 5200.00),('100000000056', 5200.00),('100000000057', 1200.00),
('100000000058', 2600.00),('100000000059', 1800.00),('100000000060', 4500.00),
-- Perfumería
('100000000061', 3900.00),('100000000062', 3900.00),('100000000063', 4900.00),
('100000000064', 3200.00),
-- Electrónica
('100000000065', 650000.00),('100000000066', 780000.00),('100000000067', 1150000.00),
('100000000068', 160000.00),('100000000069', 45000.00),('100000000070', 28000.00),
('100000000071', 52000.00),('100000000072', 89000.00),
-- Más lácteos
('100000000073', 2600.00),('100000000074', 1400.00),('100000000075', 4200.00),
('100000000076', 3300.00),('100000000077', 1100.00),('100000000078', 4900.00),
-- Más pastas/salsas
('100000000079', 3000.00),('100000000080', 3200.00),('100000000081', 2900.00),('100000000082', 2400.00),
-- Más galletitas/snacks
('100000000083', 1700.00),('100000000084', 1200.00),('100000000085', 1900.00),
('100000000086', 2300.00),('100000000087', 1700.00),
-- Más bebidas/jugos
('100000000088', 4200.00),('100000000089', 4000.00),('100000000090', 2900.00),
('100000000091', 1050.00),('100000000092', 1050.00),
-- Más cerveza/vinos
('100000000093', 2000.00),('100000000094', 2600.00),('100000000095', 4800.00),
-- Más limpieza/lavandería
('100000000096', 2200.00),('100000000097', 2100.00),('100000000098', 2500.00),
('100000000099', 7800.00),('100000000100', 9500.00);

-- ... Y AHORA APLICAMOS 10 CAMBIOS PARA supermercado2
UPDATE @precios SET precio = 1600.00 WHERE cod_barra='100000000001'; -- +100
UPDATE @precios SET precio = 5000.00 WHERE cod_barra='100000000010'; -- -200
UPDATE @precios SET precio = 2700.00 WHERE cod_barra='100000000020'; -- +200
UPDATE @precios SET precio = 5100.00 WHERE cod_barra='100000000030'; -- +300
UPDATE @precios SET precio = 3500.00 WHERE cod_barra='100000000040'; -- +300
UPDATE @precios SET precio = 2300.00 WHERE cod_barra='100000000050'; -- +300
UPDATE @precios SET precio = 4200.00 WHERE cod_barra='100000000060'; -- -300
UPDATE @precios SET precio = 25000.00 WHERE cod_barra='100000000070'; -- -3000
UPDATE @precios SET precio = 3000.00 WHERE cod_barra='100000000080'; -- -200
UPDATE @precios SET precio = 3100.00 WHERE cod_barra='100000000090'; -- +200

-- Replicar mismo precio (ajustado) en TODAS las sucursales
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