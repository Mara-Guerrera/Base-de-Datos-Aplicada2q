/*
		BASE DE DATOS APLICADA
		GRUPO: 05
		COMISION: 02-5600
		INTEGRANTES:
			María del Pilar Bourdieu
			Abigail Karina Peñafiel Huayta	41913506
			Federico Pucci 41106855
			Mara Verónica Guerrera

		FECHA DE ENTREGA: 01/11/2024

ENTREGA 3:

Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos,
etc.) en un documento como el que le entregaría al DBA.
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
Los nombres de los store procedures NO deben comenzar con “SP”.
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
en la creación de objetos. NO use el esquema “dbo”.

*/

/*USE MASTER
DROP DATABASE Com5600G05
USE Com5600G05*/

-- ================== CREACION DE DB, ESQUEMAS Y TABLAS ==================

IF NOT EXISTS (
	SELECT 1
	FROM sys.databases
	WHERE name = 'Com5600G05'
)
BEGIN
	CREATE DATABASE Com5600G05
	COLLATE MODERN_SPANISH_CI_AS;
END
GO

USE Com5600G05
GO

IF NOT EXISTS (
	SELECT 1
	FROM sys.schemas
	WHERE name = 'gestion_sucursal'
)
BEGIN
	EXEC ('create schema gestion_sucursal');
END
GO

IF NOT EXISTS (
	SELECT 1
	FROM sys.schemas
	WHERE name = 'gestion_producto'
)
BEGIN
	EXEC ('create schema gestion_producto');
END
GO

IF NOT EXISTS (
	SELECT 1
	FROM sys.schemas
	WHERE name = 'gestion_venta'
)
BEGIN
	EXEC ('create schema gestion_venta');
END
GO
-- ================== CREACION TABLAS DE ESQUEMA GESTION_SUCURSAL ==================
/*
IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Ciudad'
    AND schema_id = SCHEMA_ID('gestion_sucursal')
)
BEGIN
    CREATE TABLE gestion_sucursal.Ciudad
	(
		id			INT IDENTITY(1,1),
		nombre			VARCHAR(50),
	
		CONSTRAINT PK_CiudadID PRIMARY KEY (id)
	)
END
GO*/

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Sucursal'
    AND schema_id = SCHEMA_ID('gestion_sucursal')
)
BEGIN
    CREATE TABLE gestion_sucursal.Sucursal
	(
		id					INT IDENTITY(1,1),
		nombre				VARCHAR(30),
		--id_ciudad			INT,
		direccion			VARCHAR(100),
		horario				VARCHAR(50),
		telefono			CHAR(9),
		activo				BIT DEFAULT 1,

		CONSTRAINT Ck_SucursalTelefono CHECK (telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
		CONSTRAINT PK_SucursalID PRIMARY KEY (id),
		--CONSTRAINT FK_CiudadID1 FOREIGN KEY (id_ciudad) REFERENCES gestion_sucursal.Ciudad(id)
	)
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Turno'
    AND schema_id = SCHEMA_ID('gestion_sucursal')
)
BEGIN
    CREATE TABLE gestion_sucursal.Turno
	(
		id			INT IDENTITY(1,1),
		descripcion		VARCHAR(16),
		activo			BIT DEFAULT 1,

		CONSTRAINT PK_TurnoID PRIMARY KEY (id)
	)
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Cargo'
    AND schema_id = SCHEMA_ID('gestion_sucursal')
)
BEGIN
    CREATE TABLE gestion_sucursal.Cargo
	(
		id			INT IDENTITY(1,1),
		nombre			VARCHAR(20),
		activo			BIT DEFAULT 1,

		CONSTRAINT PK_CargoID PRIMARY KEY (id)
	)
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Empleado'
    AND schema_id = SCHEMA_ID('gestion_sucursal')
)
BEGIN
    CREATE TABLE gestion_sucursal.Empleado
	(
		id				INT IDENTITY(1,1),
		cuil				CHAR(13),
		email				VARCHAR(60),
		email_empresa			VARCHAR(60),
		id_cargo			INT,
		id_sucursal			INT,
		id_turno			INT,
		activo				BIT DEFAULT 1,

		CONSTRAINT Ck_EmpleadoCuil CHECK (cuil LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'),
		CONSTRAINT PK_EmpleadoID PRIMARY KEY (id),
		CONSTRAINT FK_CargoID FOREIGN KEY (id_cargo) REFERENCES gestion_sucursal.Cargo(id),
		CONSTRAINT FK_SucursalID1 FOREIGN KEY (id_sucursal) REFERENCES gestion_sucursal.Sucursal(id),
		CONSTRAINT FK_TurnoID FOREIGN KEY (id_turno) REFERENCES gestion_sucursal.Turno(id)
	)
END
GO
	
IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'TipoCliente'
    AND schema_id = SCHEMA_ID('gestion_sucursal')
)
BEGIN
	CREATE TABLE gestion_sucursal.TipoCliente
	(
		id			INT IDENTITY(1,1),
		descripcion		VARCHAR(10),
		activo			BIT DEFAULT 1,

		CONSTRAINT PK_TipoClienteID PRIMARY KEY (id),
	)
END 
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Genero'
    AND schema_id = SCHEMA_ID('gestion_sucursal')
)
BEGIN
	CREATE TABLE gestion_sucursal.Genero
	(
		id			INT IDENTITY(1,1),
		descripcion		VARCHAR(10),
		activo			BIT DEFAULT 1,

		CONSTRAINT PK_GeneroID PRIMARY KEY (id)
	)
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Cliente'
    AND schema_id = SCHEMA_ID('gestion_sucursal')
)
BEGIN
    CREATE TABLE gestion_sucursal.Cliente
	(
		id				INT IDENTITY(1,1),
		nombre				VARCHAR(50),
		apellido			VARCHAR(50),
		id_tipo				INT, -- Normal / Member
		id_genero			INT, -- Male / Female
		--id_ciudad			INT,
		activo				BIT DEFAULT 1,

		CONSTRAINT PK_ClienteID PRIMARY KEY (id),
		--CONSTRAINT FK_CiudadID2 FOREIGN KEY (id_ciudad) REFERENCES gestion_sucursal.Ciudad(id),
		CONSTRAINT FK_TipoCliente FOREIGN KEY (id_tipo) REFERENCES gestion_sucursal.TipoCliente(id),
		CONSTRAINT FK_Genero FOREIGN KEY (id_genero) REFERENCES gestion_sucursal.Genero(id)
	)
END
GO
-- ================== CREACION TABLAS DE ESQUEMA GESTION_PRODUCTO ==================
	
IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Proveedor'
    AND schema_id = SCHEMA_ID('gestion_producto')
)
BEGIN
    CREATE TABLE gestion_producto.Proveedor
	(
		id			INT IDENTITY(1,1),
		nombre		VARCHAR(40),
		activo		BIT DEFAULT 1,

		CONSTRAINT PK_ProveedorID PRIMARY KEY (id)
	)
END
GO
	
IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'TipoProducto'
    AND schema_id = SCHEMA_ID('gestion_productos')
)
BEGIN
    CREATE TABLE gestion_producto.TipoProducto
	(
		id		INT IDENTITY(1,1),
		nombre		VARCHAR(40),
		activo		BIT DEFAULT 1,

		CONSTRAINT PK_TipoProductoID PRIMARY KEY (id)
	)
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Categoria'
    AND schema_id = SCHEMA_ID('gestion_producto')
)
BEGIN
    CREATE TABLE gestion_producto.Categoria
    (
        id			INT IDENTITY(1,1),
        nombre			VARCHAR(50),
        id_tipoProducto 	INT,
	activo			BIT DEFAULT 1,

	CONSTRAINT PK_CategoriaID PRIMARY KEY (id),
        CONSTRAINT FK_Categoria_TipoProducto FOREIGN KEY (id_tipoProducto) REFERENCES gestion_producto.TipoProducto(id)
    )
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Producto'
    AND schema_id = SCHEMA_ID('gestion_producto')
)
BEGIN
    CREATE TABLE gestion_producto.Producto
	(
		id					INT IDENTITY(1,1),
		descripcion			VARCHAR(50),
		precio				DECIMAL(7,2),
		id_categoria		INT,
		--id_tipoProducto		INT,
		precio_ref			DECIMAL(7,2),
		unidad_ref			CHAR(3),
		cant_por_unidad		VARCHAR(25),
		id_proveedor		INT, -- NUEVO
		activo				BIT DEFAULT 1,

		CONSTRAINT Ck_ProductoPrecio CHECK (precio > 0),
		CONSTRAINT PK_ProductoID PRIMARY KEY (id),
		CONSTRAINT FK_CategoriaID FOREIGN KEY (id_categoria) REFERENCES gestion_producto.Categoria(id),
		--CONSTRAINT FK_TipoProductoID FOREIGN KEY (id_tipoProducto) REFERENCES gestion_producto.TipoProducto(id),
		CONSTRAINT FK_ProveedorID FOREIGN KEY (id_proveedor) REFERENCES gestion_producto.Proveedor(id)
	)
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'AccesorioElectronico'
    AND schema_id = SCHEMA_ID('gestion_producto')
)
BEGIN
    CREATE TABLE gestion_producto.AccesorioElectronico
	(
		id				INT IDENTITY(1,1),
		nombre			VARCHAR(30),
		precioDolar		DECIMAL(6,2),
		activo			BIT DEFAULT 1,

		CONSTRAINT PK_AccesorioElectronicoID PRIMARY KEY (id)
	)
END
GO
-- ================== CREACION TABLAS DE ESQUEMA GESTION_VENTA ==================

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'MedioDePago'
    AND schema_id = SCHEMA_ID('gestion_venta')
)
BEGIN
    CREATE TABLE gestion_venta.MedioDePago
	(
		id				INT IDENTITY(1,1),
		nombre			VARCHAR(11),
		descripcion		VARCHAR(30), -- NUEVO
		activo			BIT DEFAULT 1,
		
		CONSTRAINT PK_MedioDePagoID PRIMARY KEY (id)
	)
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'TipoFactura'
    AND schema_id = SCHEMA_ID('gestion_venta')
)
BEGIN
    CREATE TABLE gestion_venta.TipoFactura
	(
		id		INT IDENTITY(1,1),
		nombre	CHAR(1),
		activo	BIT DEFAULT 1,

		CONSTRAINT PK_TipoFacturaID PRIMARY KEY (id)
	)
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Factura'
    AND schema_id = SCHEMA_ID('gestion_venta')
)
BEGIN
    CREATE TABLE gestion_venta.Factura
	(
		id					CHAR(11),
		id_tipoFactura		INT,
		id_cliente			INT, -- tipo, genero
		fecha				DATE,
		hora				TIME,
		id_medioDePago		INT, -- descripcion
		id_empleado			INT,
		id_sucursal			INT, -- nombre
		--pagada				BIT DEFAULT 0,
		activo				BIT DEFAULT 1,
		--Actualizar la primary key a un identity 
		CONSTRAINT Ck_FacturaID CHECK (id LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'),
		CONSTRAINT PK_FacturaID PRIMARY KEY (id),
		CONSTRAINT FK_TipoFactura FOREIGN KEY (id_tipoFactura) REFERENCES gestion_venta.TipoFactura(id),
		CONSTRAINT FK_ClienteID FOREIGN KEY(id_cliente) REFERENCES gestion_sucursal.Cliente(id),
		CONSTRAINT FK_MedioDePagoID FOREIGN KEY(id_medioDePago) REFERENCES gestion_venta.MedioDePago(id),
		CONSTRAINT FK_EmpleadoID FOREIGN KEY(id_empleado) REFERENCES gestion_sucursal.Empleado(id),
		CONSTRAINT FK_SucursalID4 FOREIGN KEY(id_sucursal) REFERENCES gestion_sucursal.Sucursal(id)
	)
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'DetalleVenta'
    AND schema_id = SCHEMA_ID('gestion_venta')
)
BEGIN
    CREATE TABLE gestion_venta.DetalleVenta
	(
		id					INT IDENTITY(1,1),
		id_producto			INT, -- descripcion, precio, cantidad
		id_factura			CHAR(11),
		cantidad			INT,
		subtotal			DECIMAL(8,2),
		precio_unitario		DECIMAL(7,2),
		activo				BIT DEFAULT 1,

		CONSTRAINT Ck_DetalleVentaCantidad CHECK (cantidad > 0),
		CONSTRAINT Ck_DetalleVentaSubtotal CHECK (subtotal > 0),
		CONSTRAINT PK_DetalleVentaID PRIMARY KEY (id, id_factura),
		CONSTRAINT FK_FacturaID FOREIGN KEY (id_factura) REFERENCES gestion_venta.Factura(id),
		CONSTRAINT FK_ProductoID2 FOREIGN KEY(id_producto) REFERENCES gestion_producto.Producto(id)
	)
END
GO
