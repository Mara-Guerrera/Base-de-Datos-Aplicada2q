-----ROL SUPERVISOR-----
USE Com5600G05
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

--Asignar el rol Supervisor al usuario creado solo si no tiene el rol
IF NOT EXISTS (SELECT 1 FROM sys.database_role_members 
               WHERE role_principal_id = DATABASE_PRINCIPAL_ID('Supervisor') 
               AND member_principal_id = USER_ID('Grupo5'))
BEGIN
    EXEC sp_addrolemember 'Supervisor', 'Grupo5';
END
IF OBJECT_ID('[gestion_venta].[Tipo_Comprobante]', 'U') IS NOT NULL
    DROP TABLE [gestion_venta].[Tipo_Comprobante];
GO
	CREATE TABLE gestion_venta.Tipo_Comprobante
	(
		id INT IDENTITY(1,1),
		nombre VARCHAR(40),
		CONSTRAINT PK_TipoComprobante PRIMARY KEY (id)
	)

GO
--Inserciones en tabla tipo comprobante--
/*INSERT INTO gestion_venta.Tipo_Comprobante (nombre)
VALUES 
    ('NOTAS DE DEBITO B'),
    ('NOTAS DE CREDITO B'),
    ('RECIBOS B'),
    ('NOTAS DE VENTA AL CONTADO B');*/
-----NOTA DE CREDITO----

CREATE TABLE gestion_venta.NotaCredito
    (
        id                  INT IDENTITY(1,1),
        id_notaCredito      CHAR(11),
        id_factura          INT,
        fecha               DATE DEFAULT GETDATE(),
		id_supervisor		INT,
		id_tipo_comprobante	INT,
        id_sucursal			INT,
		id_cliente			INT,
		motivo				VARCHAR(40),
        activo              BIT DEFAULT 1,
        CONSTRAINT PK_NotaCreditoID PRIMARY KEY (id),
        CONSTRAINT FK_FacturaID_Nota FOREIGN KEY (id_factura) REFERENCES gestion_venta.Factura(id),
		CONSTRAINT FK_ClienteID_Nota FOREIGN KEY (id_cliente) REFERENCES gestion_sucursal.Cliente(id),
		CONSTRAINT FK_Sucursal_Nota FOREIGN KEY (id_sucursal) REFERENCES gestion_sucursal.Sucursal(id),
        CONSTRAINT FK_SupervisorID FOREIGN KEY (id_supervisor) REFERENCES gestion_sucursal.Empleado(id),
		CONSTRAINT FK_tipo_comprobante FOREIGN KEY (id_tipo_comprobante) REFERENCES gestion_venta.Tipo_Comprobante
    )
GO

CREATE TABLE gestion_venta.Detalle_Nota
    (
        id_item                  INT IDENTITY(1,1),
        id_nota					 INT,
		id_producto				 INT,
		cantidad				 INT,
		valor_credito			 DECIMAL(7,2),
		importe					 DECIMAL(8,2),
        activo					 BIT DEFAULT 1,
        CONSTRAINT PK_NotaDetalleID PRIMARY KEY (id_item,id_nota),
        CONSTRAINT FK_Nota_Detalle  FOREIGN KEY (id_nota) REFERENCES gestion_venta.NotaCredito,
		CONSTRAINT FK_Producto_Nota	FOREIGN KEY (id_producto) REFERENCES gestion_producto.Producto,
        CONSTRAINT CK_ValorCredito CHECK (valor_credito > 0),
		CONSTRAINT CK_ImporteCredito CHECK (importe > 0)
    )
GO

-- Otorgar permisos al rol Supervisor
GRANT INSERT, SELECT ON gestion_venta.NotaCredito TO Supervisor;
GRANT INSERT, SELECT ON gestion_venta.Detalle_Nota TO Supervisor;
GO
CREATE PROCEDURE gestion_venta.Generar_Nota_Credito
	@id_factura INT,
	@id_tipo_comprobante INT,
	@id_sucursal INT,
	@id_cliente INT,
	@motivo VARCHAR(40),
	@id_supervisor INT
AS
BEGIN
    -- Validar que la factura esté pagada
	IF NOT EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = @id_factura AND activo = 1)
    BEGIN
        RAISERROR('La factura no existe.', 16, 1);
        RETURN;
    END
	IF NOT EXISTS (SELECT 1 FROM gestion_venta.Tipo_Comprobante WHERE id = @id_tipo_comprobante)
	BEGIN
		RAISERROR('Tipo de comprobante no válido.', 16, 1);
        RETURN;
	END
	IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal AND activo = 1)
	BEGIN
		RAISERROR('La sucursal no existe.', 16, 1);
        RETURN;
	END
	IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Empleado e 
	INNER JOIN gestion_sucursal.Cargo c ON e.id_cargo = c.id
	WHERE e.id = @id_supervisor
	AND c.nombre = 'Supervisor')
	BEGIN
		RAISERROR('El empleado no existe o no es supervisor.', 16, 1);
        RETURN;
	END
	IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Cliente WHERE id = @id_cliente AND activo = 1)
	BEGIN
		RAISERROR('ID de cliente no válido.', 16, 1);
        RETURN;
	END
	DECLARE @fecha_emision DATE;
	SET @fecha_emision = GETDATE();
    -- Insertar la nota de crédito
    INSERT INTO gestion_venta.NotaCredito (id_factura, fecha,id_supervisor,id_tipo_comprobante,id_sucursal,id_cliente,motivo)
    VALUES (@id_factura, @fecha_emision, @id_supervisor, @id_tipo_comprobante,@id_sucursal,@id_cliente,@motivo);
    PRINT 'Nota de crédito generada exitosamente.';
END
GO

CREATE PROCEDURE gestion_venta.Insertar_Detalle_Nota
	@id_nota INT,
	@id_producto INT,
	@cantidad INT,
	@valor_credito DECIMAL(7,2)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM gestion_venta.NotaCredito WHERE id = @id_nota)
	BEGIN
		RAISERROR('La nota de crédito no es válida',16,1);
		RETURN;
	END

	IF NOT EXISTS (SELECT 1 FROM gestion_producto.Producto WHERE id = @id_producto)
	BEGIN
		RAISERROR('El producto no existe.',16,1);
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM gestion_venta.Detalle_Nota WHERE id_nota = @id_nota AND id_producto = @id_producto)
	BEGIN
		RAISERROR('Ya hay un detalle con el mismo producto asociado a la nota de crédito.',16,1);
		RETURN;
	END

	IF @cantidad <= 0 OR @valor_credito <= 0
	BEGIN
		RAISERROR('La cantidad o el precio no es válido.',16,1);
		RETURN;
	END
	DECLARE @importe DECIMAL(8,2);
	SET @importe = @valor_credito * @cantidad;

	INSERT INTO gestion_venta.Detalle_Nota(id_nota,id_producto,cantidad,valor_credito,importe)
    VALUES (@id_nota,@id_producto,@cantidad,@valor_credito,@importe);
    PRINT 'Detalle de nota de crédito insertado.';
END
GO
