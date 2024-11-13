-----NOTA DE CREDITO----

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'NotaCredito'
    AND schema_id = SCHEMA_ID('gestion_venta')
)
BEGIN
    CREATE TABLE gestion_venta.NotaCredito
    (
        id                  INT IDENTITY(1,1),
        id_notaCredito      CHAR(11) UNIQUE,
        id_factura          INT,
        id_producto         INT,
        valor_credito       DECIMAL(7,2),
        fecha               DATE DEFAULT GETDATE(),
        hora                TIME DEFAULT GETDATE(),
        id_supervisor       INT,
        activo              BIT DEFAULT 1,

        CONSTRAINT PK_NotaCreditoID PRIMARY KEY (id),
        CONSTRAINT FK_FacturaID FOREIGN KEY (id_factura) REFERENCES gestion_venta.Factura(id),
        CONSTRAINT FK_ProductoID FOREIGN KEY (id_producto) REFERENCES gestion_producto.Producto(id),
        CONSTRAINT FK_SupervisorID FOREIGN KEY (id_supervisor) REFERENCES gestion_sucursal.Empleado(id),
        CONSTRAINT CK_ValorCredito CHECK (valor_credito > 0),
        CONSTRAINT CK_FacturaPagada CHECK (
            EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = id_factura AND pagada = 1)
        )
    )
END
GO


-- Crear el rol Supervisor si no existe
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Supervisor')
BEGIN
    CREATE ROLE Supervisor;
END

-- Otorgar permisos al rol Supervisor
GRANT INSERT, SELECT ON gestion_venta.NotaCredito TO Supervisor;

-- Asignar el rol Supervisor a los empleados correspondientes
-- Ejemplo:
EXEC sp_addrolemember 'Supervisor', 'nombre_usuario_supervisor';


CREATE OR ALTER PROCEDURE gestion_venta.GenerarNotaCredito
    @id_factura INT,
    @id_producto INT,
    @valor_credito DECIMAL(7,2),
    @id_supervisor INT
AS
BEGIN
    -- Validar que la factura esté pagada
    IF NOT EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = @id_factura AND pagada = 1)
    BEGIN
        RAISERROR('La factura no está pagada.', 16, 1);
        RETURN;
    END

    -- Insertar la nota de crédito
    INSERT INTO gestion_venta.NotaCredito (id_factura, id_producto, valor_credito, id_supervisor)
    VALUES (@id_factura, @id_producto, @valor_credito, @id_supervisor);

    PRINT 'Nota de crédito generada exitosamente.';
END
GO




-------DEVOLUCION------------

IF NOT EXISTS (
    SELECT 1
    FROM sys.tables
    WHERE name = 'Devolucion'
    AND schema_id = SCHEMA_ID('gestion_venta')
)
BEGIN
    CREATE TABLE gestion_venta.Devolucion
    (
        id                  INT IDENTITY(1,1),
        id_devolucion       CHAR(11) UNIQUE,
        id_factura          INT,
        id_producto         INT,
        cantidad            INT,
        motivo              VARCHAR(255),
        fecha               DATE DEFAULT GETDATE(),
        hora                TIME DEFAULT GETDATE(),
        id_supervisor       INT,
        id_notaCredito      INT NULL, -- Puede ser NULL si no se emite nota de crédito
        activo              BIT DEFAULT 1,

        CONSTRAINT PK_DevolucionID PRIMARY KEY (id),
        CONSTRAINT FK_FacturaIDDevolucion FOREIGN KEY (id_factura) REFERENCES gestion_venta.Factura(id),
        CONSTRAINT FK_ProductoIDDevolucion FOREIGN KEY (id_producto) REFERENCES gestion_producto.Producto(id),
        CONSTRAINT FK_SupervisorIDDevolucion FOREIGN KEY (id_supervisor) REFERENCES gestion_sucursal.Empleado(id),
        CONSTRAINT FK_NotaCreditoIDDevolucion FOREIGN KEY (id_notaCredito) REFERENCES gestion_venta.NotaCredito(id),
        CONSTRAINT CK_CantidadDevolucion CHECK (cantidad > 0),
        CONSTRAINT CK_FacturaPagadaDevolucion CHECK (
            EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = id_factura AND pagada = 1)
        )
    )
END
GO

-- Otorgar permisos al rol Supervisor
GRANT INSERT, SELECT, UPDATE ON gestion_venta.Devolucion TO Supervisor;

CREATE PROCEDURE gestion_venta.RegistrarDevolucion
    @id_factura INT,
    @id_producto INT,
    @cantidad INT,
    @motivo VARCHAR(255),
    @id_supervisor INT,
    @emitir_notaCredito BIT = 0
AS
BEGIN
    -- Validar que la factura esté pagada
    IF NOT EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = @id_factura AND pagada = 1)
    BEGIN
        RAISERROR('La factura no está pagada. No se puede procesar la devolución.', 16, 1);
        RETURN;
    END

    -- Validar que el producto existe en la factura
    IF NOT EXISTS (
        SELECT 1
        FROM gestion_venta.DetalleVenta
        WHERE id_factura = @id_factura AND id_producto = @id_producto
    )
    BEGIN
        RAISERROR('El producto no está presente en la factura.', 16, 1);
        RETURN;
    END

    -- Insertar la devolución
    DECLARE @id_devolucion INT;
    INSERT INTO gestion_venta.Devolucion (id_factura, id_producto, cantidad, motivo, id_supervisor)
    VALUES (@id_factura, @id_producto, @cantidad, @motivo, @id_supervisor);

    SET @id_devolucion = SCOPE_IDENTITY();

    -- Emitir nota de crédito si se solicita
    IF @emitir_notaCredito = 1
    BEGIN
        DECLARE @valor_credito DECIMAL(7,2);
        SELECT @valor_credito = precio * @cantidad
        FROM gestion_producto.Producto
        WHERE id = @id_producto;

        INSERT INTO gestion_venta.NotaCredito (id_factura, id_producto, valor_credito, id_supervisor)
        VALUES (@id_factura, @id_producto, @valor_credito, @id_supervisor);

        DECLARE @id_notaCredito INT = SCOPE_IDENTITY();

        -- Actualizar la devolución con la referencia a la nota de crédito
        UPDATE gestion_venta.Devolucion
        SET id_notaCredito = @id_notaCredito
        WHERE id = @id_devolucion;

        PRINT 'Nota de crédito generada y asociada a la devolución.';
    END

    PRINT 'Devolución registrada exitosamente.';
END
GO

-----REVISAR ESTO-----
-- Crear un nuevo usuario de base de datos
CREATE USER JuanPerez FOR LOGIN JuanPerezLogin;

-- Asignar el rol Supervisor al usuario creado
EXEC sp_addrolemember 'Supervisor', 'JuanPerez';
