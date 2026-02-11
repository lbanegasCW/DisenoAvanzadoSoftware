/* ============================
   CREACIÓN DE ESQUEMA
============================ */
USE master
GO


IF EXISTS(SELECT *
FROM sys.databases
WHERE name = 'supermercado4')
BEGIN
    ALTER DATABASE supermercado4 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE supermercado4;
END
GO


CREATE DATABASE supermercado4;
GO

USE supermercado4;
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
CREATE   PROCEDURE dbo.sp_get_sucursales
AS
BEGIN
    SET NOCOUNT ON;
    SELECT (
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
                   ps.precio,
                   ps.vigente
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
               WHERE p.vigente  = 1
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
    ('30-59036076-3','Disco','Avenida Cabildo',1850,'011-4702-9090');

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
                                                                                                                         ('Disco La Plata', 'Avenida 13', 980, '0221-425-1188', -34.9209, -57.9562, 2),
                                                                                                                         ('Disco Mar del Plata', 'Avenida Colón', 2450, '0223-491-3321', -38.0008, -57.5516, 3),
                                                                                                                         ('Disco Córdoba', 'Avenida Colón', 5050, '0351-477-8890', -31.4088, -64.2109, 4),
                                                                                                                         ('Disco Rosario', 'Avenida Pellegrini', 1650, '0341-440-2233', -32.9571, -60.6476, 5),
                                                                                                                         ('Disco Buenos Aires', 'Avenida Cabildo', 1850, '011-4702-9090', -34.5619, -58.4554, 1);

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

-- Bebidas / Infusiones (sumo Arcor y La Serenísima por 057 y 100)
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 2 FROM dbo.marcas_productos
WHERE nom_marca IN ('Amanda','Taragüi','La Virginia','CBSé','Marolio','Arcor','La Serenísima');

-- Limpieza (sumo Marolio por detergente/esponja)
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 3 FROM dbo.marcas_productos
WHERE nom_marca IN ('Ala','Ayudín','Poett','Marolio');

-- Higiene (sumo Marolio por shampoo/acondicionador/desodorante)
INSERT INTO dbo.tipos_productos_marcas(nro_marca, nro_tipo_producto)
SELECT nro_marca, 4 FROM dbo.marcas_productos
WHERE nom_marca IN ('Higienol','Colgate','Marolio');

-- Otros (sumo Marolio/Arcor/Molinos por sal/vinagre/caldos/puré/mayonesa/mostaza)
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

-- PRODUCTOS (variación leve en marcas + algunos nombres)
INSERT INTO dbo.productos VALUES
                              ('100000000001','Pan francés 1Kg','Pan común a granel',1,'pan_frances.jpg',9,1,1),
                              ('100000000002','Pan lactal 550g','Pan de molde',1,'pan_lactal.jpg',5,1,1),
                              ('100000000003','Galletitas de agua 303g Arcor','Galletitas saladas',1,'galletitas_agua.jpg',3,1,1),
                              ('100000000004','Bizcochos 200g','Bizcochos para mate',1,'bizcochos.jpg',3,1,1),
                              ('100000000005','Pan rallado 500g','Rebozador',1,'pan_rallado.jpg',9,1,1),

                              ('100000000006','Harina 000 1Kg Molinos','Harina de trigo',2,'harina_000.jpg',5,1,1),
                              ('100000000007','Harina leudante 1Kg Molinos','Harina con leudante',2,'harina_leudante.jpg',5,1,1),
                              ('100000000008','Arroz largo fino 1Kg Gallo','Arroz largo fino',2,'arroz_gallo.jpg',8,1,1),
                              ('100000000009','Polenta 500g','Harina de maíz',2,'polenta.jpg',9,1,1),
                              ('100000000010','Avena 500g','Avena arrollada',2,'avena.jpg',9,1,1),
                              ('100000000011','Sémola 500g','Sémola de trigo',2,'semola.jpg',9,1,1),
                              ('100000000012','Harina de maíz 1Kg','Harina de maíz',2,'harina_maiz.jpg',9,1,1),

                              ('100000000013','Fideos secos spaghetti 500g Lucchetti','Pasta seca larga',3,'spaghetti_lucchetti.jpg',6,1,1),
                              ('100000000014','Fideos secos tirabuzón 500g Lucchetti','Pasta seca corta',3,'tirabuzon_matarazzo.jpg',6,1,1),
                              ('100000000015','Fideos secos mostachol 500g Matarazzo','Pasta seca corta',3,'mostachol_lucchetti.jpg',7,1,1),
                              ('100000000016','Lentejas secas 400g','Legumbre seca',3,'lentejas.jpg',9,1,1),
                              ('100000000017','Arvejas secas 400g','Legumbre seca',3,'arvejas.jpg',9,1,1),
                              ('100000000018','Porotos secos 400g','Legumbre seca',3,'porotos.jpg',9,1,1),
                              ('100000000019','Purè de tomate 520g Arcor','Tomate triturado',3,'pure_tomate.jpg',3,1,1),
                              ('100000000020','Salsa de tomate 340g Arcor','Salsa lista',3,'salsa_tomate.jpg',3,1,1),

                              ('100000000021','Carne picada 1Kg','Carne vacuna picada',4,'carne_picada.jpg',9,1,1),
                              ('100000000022','Carne para milanesa 1Kg','Nalga/cuadrada',4,'milanesa.jpg',9,1,1),
                              ('100000000023','Pollo entero 1Kg','Pollo fresco',4,'pollo_entero.jpg',9,1,1),
                              ('100000000024','Pescado congelado 1Kg','Filet congelado',4,'pescado.jpg',9,1,1),
                              ('100000000025','Carne para guiso 1Kg','Osobuco/paleta',4,'carne_guiso.jpg',9,1,1),

                              ('100000000026','Leche entera 1L La Serenísima','Leche UAT entera',5,'leche_entera_ls.jpg',1,1,1),
                              ('100000000027','Leche descremada 1L Sancor','Leche UAT descremada',5,'leche_descremada_sc.jpg',2,1,1),
                              ('100000000028','Yogur firme 190g Sancor','Yogur firme',5,'yogur_firme.jpg',2,1,1),
                              ('100000000029','Queso cremoso 1Kg','Queso blando',5,'queso_cremoso.jpg',1,1,1),
                              ('100000000030','Manteca 200g','Manteca',5,'manteca.jpg',1,1,1),
                              ('100000000031','Crema de leche 200cc','Crema',5,'crema.jpg',2,1,1),
                              ('100000000032','Huevos docena','Huevos',5,'huevos.jpg',9,1,1),

                              ('100000000033','Papa 1Kg','Papa',6,'papa.jpg',9,1,1),
                              ('100000000034','Cebolla 1Kg','Cebolla',6,'cebolla.jpg',9,1,1),
                              ('100000000035','Tomate 1Kg','Tomate',6,'tomate.jpg',9,1,1),
                              ('100000000036','Zanahoria 1Kg','Zanahoria',6,'zanahoria.jpg',9,1,1),
                              ('100000000037','Lechuga unidad','Lechuga',6,'lechuga.jpg',9,1,1),
                              ('100000000038','Manzana 1Kg','Manzana',6,'manzana.jpg',9,1,1),
                              ('100000000039','Banana 1Kg','Banana',6,'banana.jpg',9,1,1),
                              ('100000000040','Naranja 1Kg','Naranja',6,'naranja.jpg',9,1,1),

                              ('100000000041','Azúcar 1Kg Ledesma','Azúcar común',7,'azucar_ledesma.jpg',4,1,1),
                              ('100000000042','Dulce de leche 400g La Serenísima','Dulce de leche',7,'ddl.jpg',1,1,1),
                              ('100000000043','Mermelada 454g Arcor','Mermelada',7,'mermelada.jpg',3,1,1),
                              ('100000000044','Galletitas dulces 300g Arcor','Galletitas dulces',7,'galletitas_dulces.jpg',3,1,1),
                              ('100000000045','Cacao en polvo 180g Arcor','Cacao',7,'cacao.jpg',3,1,1),

                              ('100000000046','Aceite mezcla 1.5L Cocinero','Aceite vegetal',8,'aceite_cocinero.jpg',11,1,1),
                              ('100000000047','Aceite girasol 1.5L Natura','Aceite de girasol',8,'aceite_natura.jpg',10,1,1),
                              ('100000000048','Grasa vacuna 500g','Grasa',8,'grasa.jpg',9,1,1),
                              ('100000000049','Margarina 200g Arcor','Margarina',8,'margarina.jpg',3,1,1),

                              ('100000000050','Yerba mate 1Kg Taragüi','Yerba mate',9,'yerba_taraguei.jpg',13,2,1),
                              ('100000000051','Yerba mate 1Kg Amanda','Yerba mate',9,'yerba_amanda.jpg',12,2,1),
                              ('100000000052','Té 50 saquitos CBSé','Té negro',9,'te.jpg',15,2,1),
                              ('100000000053','Café molido 250g La Virginia','Café',9,'cafe_lavirginia.jpg',14,2,1),
                              ('100000000054','Mate cocido 25 saquitos','Mate cocido',9,'mate_cocido.jpg',12,2,1),

                              ('100000000055','Agua mineral 2L','Agua sin gas',10,'agua_2l.jpg',9,2,1),
                              ('100000000056','Agua mineral 500ml','Agua sin gas',10,'agua_500.jpg',9,2,1),
                              ('100000000057','Jugo en polvo 18g Arcor','Jugo en polvo',10,'jugo_polvo.jpg',3,2,1),
                              ('100000000058','Gaseosa cola 2.25L','Gaseosa',10,'gaseosa_cola.jpg',9,2,1),
                              ('100000000059','Gaseosa naranja 2.25L','Gaseosa',10,'gaseosa_naranja.jpg',9,2,1),

                              ('100000000060','Lavandina 1L Ayudín','Lavandina',11,'lavandina_ayudin.jpg',17,3,1),
                              ('100000000061','Desinfectante 1L Ayudín','Desinfectante',11,'desinfectante.jpg',17,3,1),
                              ('100000000062','Limpiador piso 900ml Poett','Limpieza pisos',11,'poett.jpg',18,3,1),
                              ('100000000063','Detergente cocina 750ml','Lavavajillas',11,'detergente.jpg',9,3,1),
                              ('100000000064','Esponja de cocina','Esponja',11,'esponja.jpg',9,3,1),
                              ('100000000065','Limpiavidrios 500ml Poett','Vidrios',11,'limpiavidrios.jpg',18,3,1),

                              ('100000000066','Jabón en polvo 800g Ala','Jabón en polvo',12,'ala_800.jpg',16,3,1),
                              ('100000000067','Jabón líquido ropa 3L Ala','Jabón líquido',12,'jabon_liquido_3l.jpg',16,3,1),
                              ('100000000068','Suavizante 1L Ala','Suavizante',12,'suavizante_1l.jpg',16,3,1),
                              ('100000000069','Quitamanchas 450ml Ala','Quitamanchas',12,'quitamanchas.jpg',16,3,1),
                              ('100000000070','Lavandina concentrada 2L Ayudín','Lavandina concentrada',12,'lavandina_2l.jpg',17,3,1),

                              ('100000000071','Jabón tocador 3x90g','Jabón de tocador',13,'jabon_tocador.jpg',9,4,1),
                              ('100000000072','Shampoo 400ml','Shampoo',13,'shampoo.jpg',9,4,1),
                              ('100000000073','Acondicionador 400ml','Acondicionador',13,'acondicionador.jpg',9,4,1),
                              ('100000000074','Pasta dental 90g Colgate','Pasta dental',13,'colgate_90.jpg',20,4,1),
                              ('100000000075','Cepillo dental Colgate','Cepillo dental',13,'cepillo.jpg',20,4,1),
                              ('100000000076','Desodorante aerosol 150ml','Desodorante',13,'desodorante.jpg',9,4,1),
                              ('100000000077','Toallitas femeninas','Higiene femenina',13,'toallitas.jpg',19,4,1),

                              ('100000000078','Papel higiénico 4 rollos Higienol','Papel higiénico',14,'higienol_4.jpg',19,4,1),
                              ('100000000079','Papel higiénico 6 rollos Higienol','Papel higiénico',14,'higienol_6.jpg',19,4,1),
                              ('100000000080','Servilletas 200u Higienol','Servilletas',14,'servilletas.jpg',19,4,1),
                              ('100000000081','Pañuelos descartables Higienol','Pañuelos',14,'panuelos.jpg',19,4,1),
                              ('100000000082','Toalla de papel Higienol','Rollo cocina',14,'toalla_papel.jpg',19,4,1),

                              ('100000000083','Sal fina 500g','Sal de mesa',15,'sal.jpg',9,5,1),
                              ('100000000084','Vinagre alcohol 1L','Vinagre',15,'vinagre.jpg',9,5,1),
                              ('100000000085','Caldo cubitos Arcor','Caldo',15,'caldo.jpg',3,5,1),
                              ('100000000086','Purè instantáneo 125g Molinos','Purè instantáneo',15,'pure_inst.jpg',5,5,1),
                              ('100000000087','Mayonesa 500g Arcor','Mayonesa',15,'mayonesa.jpg',3,5,1),
                              ('100000000088','Mostaza 250g Arcor','Mostaza',15,'mostaza.jpg',3,5,1),
                              ('100000000089','Fideos guiseros 500g Matarazzo','Pasta corta',3,'fideos_guiseros.jpg',7,1,1),
                              ('100000000090','Arroz parboil 1Kg Gallo','Arroz',2,'arroz_parboil.jpg',8,1,1),
                              ('100000000091','Azúcar 1Kg (económica)','Azúcar',7,'azucar_econo.jpg',9,1,1),
                              ('100000000092','Aceite 900ml Natura','Aceite',8,'aceite_900.jpg',10,1,1),
                              ('100000000093','Leche en polvo 400g Sancor','Leche en polvo',5,'leche_polvo.jpg',2,1,1),
                              ('100000000094','Queso rallado 40g','Queso rallado',5,'queso_rallado.jpg',1,1,1),
                              ('100000000095','Tomate triturado 520g','Triturado',3,'triturado.jpg',9,1,1),
                              ('100000000096','Atún en lata 170g','Atún',3,'atun.jpg',9,1,1),
                              ('100000000097','Fideos moñitos 500g Lucchetti','Pasta corta',3,'monitos.jpg',6,1,1),
                              ('100000000098','Arvejas en lata 300g','Arvejas',3,'arvejas_lata.jpg',9,1,1),
                              ('100000000099','Levadura seca 10g','Levadura',1,'levadura.jpg',9,5,1),
                              ('100000000100','Leche chocolatada 1L La Serenísima','Bebida láctea',10,'chocolatada.jpg',1,2,1);

-- PRECIOS (promos puntuales)
DECLARE @precios TABLE(cod_barra varchar(50) PRIMARY KEY, precio decimal(10,2));

INSERT INTO @precios(cod_barra, precio) VALUES
                                            ('100000000001', 2400.00),('100000000002', 2600.00),('100000000003', 990.00), ('100000000004', 1990.00),('100000000005', 1750.00),
                                            ('100000000006', 1390.00),('100000000007', 2490.00),('100000000008', 2790.00),('100000000009', 1290.00),('100000000010', 2290.00),
                                            ('100000000011', 1190.00),('100000000012', 2590.00),
                                            ('100000000013', 1490.00),('100000000014', 2190.00),('100000000015', 1590.00),('100000000016', 2790.00),('100000000017', 1990.00),
                                            ('100000000018', 3390.00),('100000000019', 1490.00),('100000000020', 2890.00),
                                            ('100000000021', 9900.00),('100000000022', 10900.00),('100000000023', 5200.00),('100000000024', 9200.00),('100000000025', 12900.00),
                                            ('100000000026', 1690.00),('100000000027', 1890.00),('100000000028', 890.00), ('100000000029', 10900.00),('100000000030', 1990.00),
                                            ('100000000031', 1790.00),('100000000032', 2890.00),
                                            ('100000000033', 1190.00),('100000000034', 990.00), ('100000000035', 2190.00),('100000000036', 1490.00),('100000000037', 790.00),
                                            ('100000000038', 2390.00),('100000000039', 1990.00),('100000000040', 2890.00),
                                            ('100000000041', 1490.00),('100000000042', 4490.00),('100000000043', 1890.00),('100000000044', 1490.00),('100000000045', 1890.00),
                                            ('100000000046', 6990.00),('100000000047', 3990.00),('100000000048', 1890.00),('100000000049', 1690.00),
                                            ('100000000050', 7990.00),('100000000051', 4890.00),('100000000052', 1490.00),('100000000053', 5990.00),('100000000054', 1490.00),
                                            ('100000000055', 690.00), ('100000000056', 590.00), ('100000000057', 590.00), ('100000000058', 4990.00),('100000000059', 3990.00),
                                            ('100000000060', 1590.00),('100000000061', 2290.00),('100000000062', 1990.00),('100000000063', 1590.00),('100000000064', 790.00),
                                            ('100000000065', 1990.00),
                                            ('100000000066', 3990.00),('100000000067', 10900.00),('100000000068', 2190.00),('100000000069', 4990.00),('100000000070', 1990.00),
                                            ('100000000071', 990.00), ('100000000072', 1990.00),('100000000073', 2190.00),('100000000074', 2590.00),('100000000075', 1290.00),
                                            ('100000000076', 3990.00),('100000000077', 1890.00),
                                            ('100000000078', 2590.00),('100000000079', 6990.00),('100000000080', 1490.00),('100000000081', 1290.00),('100000000082', 1990.00),
                                            ('100000000083', 590.00), ('100000000084', 1190.00),('100000000085', 790.00), ('100000000086', 1190.00),('100000000087', 2190.00),
                                            ('100000000088', 1390.00),('100000000089', 1590.00),('100000000090', 2490.00),('100000000091', 1590.00),('100000000092', 2990.00),
                                            ('100000000093', 6990.00),('100000000094', 1390.00),('100000000095', 1590.00),('100000000096', 4490.00),('100000000097', 1490.00),
                                            ('100000000098', 2890.00),('100000000099', 390.00), ('100000000100', 2290.00);

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