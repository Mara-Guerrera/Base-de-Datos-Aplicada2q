/*
		BASE DE DATOS APLICADA
		GRUPO: 05
		COMISION: 02-5600
		INTEGRANTES:
			María del Pilar Bourdieu 45289653
			Abigail Karina Peñafiel Huayta	41913506
			Federico Pucci 41106855
			Mara Verónica Guerrera 40538513

		FECHA DE ENTREGA: 22/11/2024

ENTREGA 5:

Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.
*/
-- ============================ ROL SUPERVISOR ============================
USE Com5600G05
GO

-- Crear un nuevo usuario de base de datos
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Supervisor')
BEGIN
    CREATE ROLE Supervisor;
END

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Grupo5')
BEGIN
    CREATE LOGIN Grupo5 WITH PASSWORD = 'Grupo5';
END

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Grupo5')
BEGIN
    CREATE USER Grupo5 FOR LOGIN Grupo5;
END

-- Asignar el rol Supervisor al usuario creado solo si no tiene el rol
IF NOT EXISTS (SELECT 1 FROM sys.database_role_members 
               WHERE role_principal_id = DATABASE_PRINCIPAL_ID('Supervisor') 
               AND member_principal_id = USER_ID('Grupo5'))
BEGIN
    EXEC sp_addrolemember 'Supervisor', 'Grupo5';
END
GO

CREATE TABLE gestion_venta.TipoComprobante
(
	id		INT IDENTITY(1,1),
	nombre	VARCHAR(40),

	CONSTRAINT PK_TipoComprobante PRIMARY KEY (id)
)
GO

-- Inserciones en tabla tipo comprobante --
INSERT INTO gestion_venta.Tipo_Comprobante (nombre)
VALUES 
    ('NOTAS DE DEBITO B'),
    ('NOTAS DE CREDITO B'),
    ('RECIBOS B'),
    ('NOTAS DE VENTA AL CONTADO B');
GO
-- ============================ NOTA DE CREDITO ============================

CREATE TABLE gestion_venta.NotaCredito
    (
        id                  INT IDENTITY(1,1),
        id_notaCredito      CHAR(11),
        id_factura          INT,
        fecha               DATE DEFAULT GETDATE(),
		id_supervisor		INT,
		id_tipoComprobante	INT,
        id_sucursal			INT,
		id_cliente			INT,
		motivo				VARCHAR(40),
        activo              BIT DEFAULT 1,

        CONSTRAINT PK_NotaCreditoID PRIMARY KEY (id),
        CONSTRAINT FK_FacturaID_Nota FOREIGN KEY (id_factura) REFERENCES gestion_venta.Factura(id),
		CONSTRAINT FK_ClienteID_Nota FOREIGN KEY (id_cliente) REFERENCES gestion_sucursal.Cliente(id),
		CONSTRAINT FK_Sucursal_Nota FOREIGN KEY (id_sucursal) REFERENCES gestion_sucursal.Sucursal(id),
        CONSTRAINT FK_SupervisorID FOREIGN KEY (id_supervisor) REFERENCES gestion_sucursal.Empleado(id),
		CONSTRAINT FK_tipoComprobante FOREIGN KEY (id_tipoComprobante) REFERENCES gestion_venta.TipoComprobante(id)
    )
GO

CREATE TABLE gestion_venta.DetalleNota
    (
        id_item                  INT IDENTITY(1,1),
        id_nota					 INT,
		id_producto				 INT,
		cantidad				 INT,
		valor_credito			 DECIMAL(7,2),
		importe					 DECIMAL(8,2),
        activo					 BIT DEFAULT 1,

        CONSTRAINT PK_NotaDetalleID PRIMARY KEY (id_item, id_nota),
        CONSTRAINT FK_Nota_Detalle FOREIGN KEY (id_nota) REFERENCES gestion_venta.NotaCredito(id),
		CONSTRAINT FK_Producto_Nota	FOREIGN KEY (id_producto) REFERENCES gestion_producto.Producto(id),
        CONSTRAINT CK_ValorCredito CHECK (valor_credito > 0),
		CONSTRAINT CK_ImporteCredito CHECK (importe > 0)
    )
GO
-- ============================ STORED PROCEDURES NOTA DE CREDITO ============================

IF OBJECT_ID('[gestion_venta].[Generar_NotaCredito]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_venta].[Generar_NotaCredito];
GO
CREATE PROCEDURE gestion_venta.Generar_NotaCredito
    @id_factura INT,
    @id_tipoComprobante INT,
    @id_sucursal INT,
    @id_cliente INT,
	@motivo VARCHAR(40),
	@id_supervisor INT
AS
BEGIN
	IF @id_factura IS NULL AND @id_tipoComprobante IS NULL AND @id_sucursal IS NULL
	AND @id_cliente IS NULL	AND @motivo IS NULL AND @id_supervisor IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar todos los datos (ninguno puede ser nulo).', 16, 1)
		RETURN
	END

    -- Validar que la factura esté pagada
	IF NOT EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = @id_factura AND activo = 1)
    BEGIN
        RAISERROR('Error: La factura no existe.', 16, 1);
        RETURN;
    END

	IF NOT EXISTS (SELECT 1 FROM gestion_venta.TipoComprobante WHERE id = @id_tipoComprobante)
	BEGIN
		RAISERROR('Error: Tipo de comprobante no válido.', 16, 1);
        RETURN;
	END

	IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal AND activo = 1)
	BEGIN
		RAISERROR('Error: La sucursal no existe.', 16, 1);
        RETURN;
	END

	IF NOT EXISTS ( SELECT 1 FROM gestion_sucursal.Empleado e 
					INNER JOIN gestion_sucursal.Cargo c ON e.id_cargo = c.id
					WHERE e.id = @id_supervisor AND c.nombre = 'Supervisor' )
	BEGIN
		RAISERROR('Error: El empleado no existe o no es supervisor.', 16, 1);
        RETURN;
	END

	IF EXISTS(SELECT 1 FROM gestion_venta.NotaCredito WHERE id_factura = @id_factura)
	BEGIN
		RAISERROR('Error: Ya existe una nota de crédito asociada a la factura', 16, 1);
		RETURN;
	END

	IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Cliente WHERE id = @id_cliente AND activo = 1)
	BEGIN
		RAISERROR('Error: ID de cliente no válido.', 16, 1);
        RETURN;
	END

	DECLARE @fecha_emision DATE;
	SET @fecha_emision = GETDATE();
    -- Insertar la nota de crédito
    INSERT INTO gestion_venta.NotaCredito(id_factura, fecha,id_supervisor, id_tipo_comprobante, id_sucursal, id_cliente, motivo)
    VALUES (@id_factura, @fecha_emision, @id_supervisor, @id_tipoComprobante, @id_sucursal, @id_cliente, @motivo);
    PRINT 'Nota de crédito generada exitosamente.';
END
GO

IF OBJECT_ID('[gestion_venta].[Insertar_DetalleNota]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Insertar_DetalleNota];
GO
CREATE PROCEDURE gestion_venta.Insertar_DetalleNota
	@id_nota INT,
	@id_producto INT,
	@cantidad INT,
	@valor_credito DECIMAL(7,2)
AS
BEGIN
	IF @id_nota IS NULL AND @id_producto IS NULL AND @cantidad IS NULL AND @valor_credito IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar todos los datos (ninguno puede ser nulo).', 16, 1)
		RETURN
	END

	IF NOT EXISTS (SELECT 1 FROM gestion_venta.NotaCredito WHERE id = @id_nota)
	BEGIN
		RAISERROR('Error: La nota de crédito no es válida', 16, 1);
		RETURN;
	END

	IF NOT EXISTS (SELECT 1 FROM gestion_producto.Producto WHERE id = @id_producto)
	BEGIN
		RAISERROR('Error: El producto no existe.', 16, 1);
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM gestion_venta.DetalleNota WHERE id_nota = @id_nota AND id_producto = @id_producto)
	BEGIN
		RAISERROR('Error: Ya hay un detalle con el mismo producto asociado a la nota de crédito.', 16, 1);
		RETURN;
	END
	--Verificación de que el id_producto este en la factura a la que se desea hacer nota de crédito--
	IF NOT EXISTS ( SELECT 1 FROM gestion_venta.DetalleVenta dv 
					INNER JOIN gestion_venta.NotaCredito n ON dv.id_factura = n.id_factura 
					WHERE dv.id_producto = @id_producto )
	BEGIN
		RAISERROR('Error: No existe detalle de la factura asociada que contenga el producto que se desea incluir en la nota de crédito.', 16, 1)
		RETURN;
	END

	--Verificación de que la cantidad no sea nula ni número negativo y tampoco mayor a la que aparece en el detalle de venta--
	IF @cantidad <= 0 OR @cantidad > (SELECT cantidad FROM gestion_venta.DetalleVenta dv INNER JOIN gestion_venta.NotaCredito n 
	ON dv.id_factura = n.id_factura 
	WHERE dv.id_producto = @id_producto) OR @valor_credito <= 0
	BEGIN
		RAISERROR('Error: La cantidad y/o el valor crédito no es válida', 16, 1);
		RETURN;
	END

	DECLARE @importe DECIMAL(8,2);
	SET @importe = @valor_credito * @cantidad;

	INSERT INTO gestion_venta.DetalleNota(id_nota, id_producto, cantidad, valor_credito, importe)
    VALUES (@id_nota, @id_producto, @cantidad, @valor_credito, @importe);
    PRINT 'Detalle de nota de crédito insertado.';
END
GO

-- Otorgar permisos al rol Supervisor
GRANT INSERT, UPDATE ON gestion_venta.NotaCredito TO Supervisor;
GRANT INSERT, UPDATE ON gestion_venta.DetalleNota TO Supervisor;
