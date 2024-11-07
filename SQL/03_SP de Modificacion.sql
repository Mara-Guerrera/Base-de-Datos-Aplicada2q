-- ============================ STORE PROCEDURES MODIFICACION ============================
USE Com5600G05
GO

-- ============================ SP MODIFICACION GESTION_SUCURSAL ============================

CREATE OR ALTER PROCEDURE gestion_sucursal.Modificar_Ciudad
    @id INT,
    @nombre VARCHAR(50)
AS
BEGIN
    -- Verificar si la ciudad existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Ciudad WHERE id = @id)
    BEGIN
        -- Validar el nombre (mismo chequeo que la restricción)
        IF LEN(@nombre) <= 50
        BEGIN
            -- Realizar la actualización
            UPDATE gestion_sucursal.Ciudad
            SET nombre = @nombre
            WHERE id = @id;
            
            PRINT 'Registro actualizado exitosamente.';
        END
    END
    ELSE
    BEGIN
        -- El registro no existe
        PRINT 'Error: No se encontró una ciudad con el ID especificado.';
    END
END;
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Modificar_Sucursal
    @id INT,
    @nombre VARCHAR(30),
    @id_ciudad INT
AS
BEGIN
    -- Verificar si la ciudad existe
    IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Ciudad WHERE id = @id_ciudad)
    BEGIN
        PRINT 'Error: La ciudad especificada no existe.';
        RETURN;
    END

    -- Verificar si la sucursal existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id AND activo = 1)
    BEGIN
        -- Validar el nombre (mismo chequeo que la restricción)
        IF LEN(@nombre) <= 30
        BEGIN
            -- Actualizar el registro
            UPDATE gestion_sucursal.Sucursal
            SET 
                nombre = CASE WHEN @nombre IS NOT NULL THEN @nombre ELSE nombre END,
                id_ciudad = CASE WHEN @id_ciudad IS NOT NULL THEN @id_ciudad ELSE id_ciudad END
            WHERE id = @id;
            
            PRINT 'Registro de Sucursal actualizado exitosamente.';
        END
        ELSE
        BEGIN
            PRINT 'Error en la modificacion de la sucursal';
        END
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró una Sucursal con el ID especificado.';
    END
END;
GO
-- FALTARIA MODIFICAR CARGO Y TURNO

CREATE OR ALTER PROCEDURE gestion_sucursal.Modificar_Empleado
    @id				INT NOT NULL,
	@cuil			CHAR(13) = NULL,
	@email			VARCHAR(60) = NULL,
	@email_empresa	VARCHAR(60) = NULL,
	@id_cargo		INT = NULL,
	@id_sucursal	INT = NULL,
	@id_turno		INT = NULL
AS
BEGIN
	IF @cuil IS NULL AND @email IS NULL AND @email_empresa IS NULL
		AND @id_cargo IS NULL AND @id_sucursal IS NULL AND @id_turno IS NULL
    BEGIN
		PRINT 'Error: No ingresó los datos que se quieren modificar.';
		RETURN;
	END

    -- Verificar si el empleado existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @id AND activo = 1)
    BEGIN
	-- Los campos no nulos se modifican, el resto quedan con los datos iniciales
		UPDATE gestion_sucursal.Empleado
		SET
			cuil = ISNULL(@cuil, cuil),
			email = ISNULL(@email, email),
			email_empresa = ISNULL(@email_empresa, email_empresa),
			id_cargo = ISNULL(@id_cargo, id_cargo),
			id_sucursal = ISNULL(@id_sucursal, id_sucursal),
			id_turno = ISNULL(@id_turno, id_turno)
		WHERE id = @id

        -- Mensaje de confirmación si hubo al menos un cambio
        PRINT 'Actualización de Empleado completada.';
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró un Empleado con el ID especificado.';
    END
END;
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Modificar_TipoCliente
    @id INT,
    @descripcion VARCHAR(10)
AS
BEGIN
    -- Verificar si el tipo de cliente existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE id = @id and activo = 1)
    BEGIN
        -- Validar la longitud de la descripción
        IF LEN(@descripcion) <= 10
        BEGIN
            -- Actualizar el registro
            UPDATE gestion_sucursal.TipoCliente
            SET descripcion = @descripcion
            WHERE id = @id;
            
            PRINT 'Registro de TipoCliente actualizado exitosamente.';
        END
        ELSE
        BEGIN
            PRINT 'Error: La descripción excede el límite de 10 caracteres.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró un TipoCliente con el ID especificado.';
    END
END;
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Modificar_Genero
    @id INT,
    @descripcion VARCHAR(10)
AS
BEGIN
    -- Verificar si el género existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE id = @id and activo = 1)
    BEGIN
        -- Validar la longitud de la descripción
        IF LEN(@descripcion) <= 10
        BEGIN
            -- Actualizar el registro
            UPDATE gestion_sucursal.Genero
            SET descripcion = @descripcion
            WHERE id = @id;
            
            PRINT 'Registro de Genero actualizado exitosamente.';
        END
        ELSE
        BEGIN
            PRINT 'Error: La descripción excede el límite de 10 caracteres.';
        END
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró un Genero con el ID especificado.';
    END
END;
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Modificar_Cliente
    @id INT,
    @nombre VARCHAR(50) = NULL,
    @apellido VARCHAR(50) = NULL,
    @tipo INT = NULL,
    @id_genero INT = NULL,
    @id_ciudad INT = NULL
AS
BEGIN
	IF  @nombre IS NULL AND @apellido IS NULL AND @tipo IS NULL AND @id_genero IS NULL AND @id_ciudad IS NULL
	BEGIN
		PRINT 'Error: No ingresó los datos que se quieren modificar.';
		RETURN;
	END

    -- Verificar si el cliente existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Cliente WHERE id = @id and activo = 1)
    BEGIN

        -- Actualizar tipo (id_tipoCliente) si se proporciona y es válido
        IF @tipo IS NOT NULL
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM gestion_sucursal.TipoCliente 
                WHERE id = @tipo and activo = 1
            )
            BEGIN
                UPDATE gestion_sucursal.Cliente
                SET id_tipo = @tipo
                WHERE id = @id;
            END
            ELSE
            BEGIN
                PRINT 'Error: No existe un TipoCliente con el ID especificado.';
				RETURN;
            END
        END

        -- Actualizar id_genero si se proporciona y es válido
        IF @id_genero IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE id = @id_genero and activo = 1)
            BEGIN
                UPDATE gestion_sucursal.Cliente
                SET id_genero = @id_genero
                WHERE id = @id;
            END
            ELSE
            BEGIN
                PRINT 'Error: No existe un Genero con el ID especificado.';
				RETURN;
            END
        END

        -- Actualizar id_ciudad si se proporciona y es válido
        IF @id_ciudad IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM gestion_sucursal.Ciudad WHERE id = @id_ciudad)
            BEGIN
                UPDATE gestion_sucursal.Cliente
                SET id_ciudad = @id_ciudad
                WHERE id = @id;
            END
            ELSE
            BEGIN
                PRINT 'Error: No existe una Ciudad con el ID especificado.';
				RETURN;
            END
        END

		-- Validar y actualizar nombre si se proporciona
        IF @nombre IS NOT NULL
        BEGIN
            IF LEN(@nombre) <= 50
            BEGIN
                UPDATE gestion_sucursal.Cliente
                SET nombre = @nombre
                WHERE id = @id;
            END
        END

        -- Validar y actualizar apellido si se proporciona
        IF @apellido IS NOT NULL
        BEGIN
            IF LEN(@apellido) <= 50
            BEGIN
                UPDATE gestion_sucursal.Cliente
                SET apellido = @apellido
                WHERE id = @id;
            END
            
        END

        -- Mensaje de confirmación si hubo al menos un cambio
        PRINT 'Actualización de Cliente completada.';
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró un Cliente con el ID especificado.';
    END
END;
GO
-- ============================ SP MODIFICACION GESTION_PRODUCTO ============================

CREATE OR ALTER PROCEDURE gestion_producto.Modificar_TipoProducto
    @id INT,
    @nombre VARCHAR(40) = NULL
AS
BEGIN
    -- Verificar si el tipo de producto existe
    IF EXISTS (SELECT 1 FROM gestion_producto.TipoProducto WHERE id = @id and activo = 1)
    BEGIN
        -- Validar y actualizar nombre si se proporciona
        IF @nombre IS NOT NULL
        BEGIN
            IF LEN(@nombre) <= 40
            BEGIN
                UPDATE gestion_producto.TipoProducto
                SET nombre = @nombre
                WHERE id = @id;
            END
            ELSE
            BEGIN
                PRINT 'Error: El nombre excede el límite de 40 caracteres.';
            END
        END

        -- Confirmación si hubo un cambio
        PRINT 'Actualización de TipoProducto completada.';
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró un TipoProducto con el ID especificado.';
    END
END;
GO

CREATE OR ALTER PROCEDURE gestion_producto.Modificar_Producto
    @id INT,
    @descripcion VARCHAR(50) = NULL,
    @precio DECIMAL(7,2) = NULL,
    @id_tipoProducto INT = NULL, --FK
	@precio_ref DECIMAL(7,2) = NULL,
	@unidad_ref CHAR(3) = NULL,
	@cant_por_unidad VARCHAR(25) = NULL
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM gestion_producto.Producto WHERE id = @id)
    BEGIN
        PRINT 'Error: El Producto no existe.';
        RETURN;
    END
	IF @id_tipoProducto IS NOT NULL
		AND NOT EXISTS (SELECT 1 FROM gestion_producto.TipoProducto WHERE id = @id_tipoProducto AND activo = 1)
    BEGIN
        PRINT 'Error: El tipo de producto especificado no existe.';
        RETURN;
    END
		UPDATE a
		SET descripcion = ISNULL(@descripcion, descripcion),
		precio = ISNULL(@precio, precio),
		id_tipoProducto = ISNULL(@id_tipoProducto, id_tipoProducto),
		precio_ref = ISNULL(@precio_ref, precio_ref),
		unidad_ref = ISNULL(@unidad_ref, unidad_ref),
		cant_x_unidad = ISNULL(@cant_por_unidad, cant_por_unidad)
		FROM gestion_producto.Producto a
		WHERE id = @id
	PRINT 'Producto modificado con éxito.';
END;
GO
-- ============================ SP MODIFICACION GESTION_VENTA ============================

CREATE OR ALTER PROCEDURE gestion_venta.Modificar_MedioDePago
    @id INT,
    @descripcion VARCHAR(30) = NULL
AS
BEGIN

		IF  @descripcion IS NULL 
        BEGIN
                PRINT 'Error: No ingresó los datos que se quieren modificar.';
				RETURN;
		END

    -- Verificar si el medio de pago existe
    IF EXISTS (SELECT 1 FROM gestion_venta.MedioDePago WHERE id = @id and activo = 1)
    BEGIN
        -- Validar y actualizar descripción si se proporciona
        IF @descripcion IS NOT NULL
        BEGIN
            IF LEN(@descripcion) <= 30
            BEGIN
                UPDATE gestion_venta.MedioDePago
                SET descripcion = @descripcion
                WHERE id = @id;
            END
         
        END

        -- Confirmación si hubo un cambio
        PRINT 'Actualización de MedioDePago completada.';
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró un MedioDePago con el ID especificado.';
    END
END;
GO

CREATE OR ALTER PROCEDURE gestion_venta.Modificar_TipoFactura
    @id INT,
    @nombre CHAR(1) = NULL
AS
BEGIN
    -- Verificar si el tipo de factura existe
    IF EXISTS (SELECT 1 FROM gestion_venta.TipoFactura WHERE id = @id and activo = 1)
    BEGIN
        -- Validar y actualizar nombre si se proporciona
        IF @nombre IS NOT NULL
        BEGIN
            IF PATINDEX('[A-Za-z]', @nombre) = 1
            BEGIN
                UPDATE gestion_venta.TipoFactura
                SET nombre = @nombre
                WHERE id = @id;
            END
            ELSE
            BEGIN
                PRINT 'Error: El nombre debe ser un solo carácter alfabético.';
            END
        END

        -- Confirmación si hubo un cambio
        PRINT 'Actualización de TipoFactura completada.';
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró un TipoFactura con el ID especificado.';
    END
END;
GO

CREATE OR ALTER PROCEDURE gestion_venta.Modificar_Factura
    @id_factura CHAR(11),
    @id_tipofactura INT = NULL,
    @id_cliente INT = NULL,
    @total DECIMAL(8,2) = NULL,
    @fecha DATE = NULL,
    @hora TIME = NULL,
    @id_medioDePago INT = NULL,
    @id_empleado INT = NULL,
    @id_sucursal INT = NULL
AS
BEGIN
    -- Verificar si la factura existe
    IF EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id_factura = @id_factura and activo = 1)
    BEGIN
        -- Validación y actualización de cada campo
        IF @id_tipofactura IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM gestion_venta.TipoFactura WHERE id = @id_tipofactura and activo = 1)
            BEGIN
                UPDATE gestion_venta.Factura
				SET id_tipofactura = @id_tipofactura
				WHERE id_factura = @id_factura;
            END
            ELSE
            BEGIN
                PRINT 'Error: TipoFactura no existe.';
            END
        END

        IF @id_cliente IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM gestion_sucursal.Cliente WHERE id = @id_cliente and activo = 1)
            BEGIN
                UPDATE gestion_venta.Factura
				SET id_cliente = @id_cliente
				WHERE id_factura = @id_factura;
            END
            ELSE
            BEGIN
                PRINT 'Error: Cliente no existe.';
            END
        END


        IF @fecha IS NOT NULL
        BEGIN
            UPDATE gestion_venta.Factura
			SET fecha = @fecha
			WHERE id_factura = @id_factura;
        END

        IF @hora IS NOT NULL
        BEGIN
            UPDATE gestion_venta.Factura
			SET hora = @hora
			WHERE id_factura = @id_factura;
        END

        IF @id_medioDePago IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM gestion_venta.MedioDePago WHERE id = @id_medioDePago and activo = 1)
            BEGIN
                UPDATE gestion_venta.Factura
				SET id_medioDePago = @id_medioDePago
				WHERE id_factura = @id_factura;
            END
            ELSE
            BEGIN
                PRINT 'Error: MedioDePago no existe.';
            END
        END

        IF @id_empleado IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @id_empleado and activo = 1)
            BEGIN
                UPDATE gestion_venta.Factura
				SET id_empleado = @id_empleado
				WHERE id_factura = @id_factura;
            END
            ELSE
            BEGIN
                PRINT 'Error: Empleado no existe.';
            END
        END

        IF @id_sucursal IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal and activo = 1)
            BEGIN
                UPDATE gestion_venta.Factura
				SET id_sucursal = @id_sucursal
				WHERE id_factura = @id_factura;
            END
            ELSE
            BEGIN
                PRINT 'Error: Sucursal no existe.';
            END
        END

        -- Mensaje de confirmación si se realizó al menos un cambio
        PRINT 'Actualización de Factura completada.';
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró una Factura con el ID especificado.';
    END
END;
GO

CREATE OR ALTER PROCEDURE gestion_venta.Modificar_DetalleVenta
    @id_detalle INT,
    @id_factura CHAR(11),
    @id_producto INT = NULL,
    @cantidad INT = NULL,
    @subtotal DECIMAL(8,2) = NULL,
    @precio_unitario DECIMAL(7,2) = NULL
AS
BEGIN
    -- Verificar si el detalle existe
    IF EXISTS (	SELECT 1 FROM gestion_venta.DetalleVenta
				WHERE id_detalle = @id_detalle AND id_factura = @id_factura and activo = 1)
    BEGIN
        -- Validación y actualización de cada campo
        IF @id_producto IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM gestion_producto.Producto WHERE id = @id_producto and activo = 1)
            BEGIN
                UPDATE gestion_venta.DetalleVenta
				SET id_producto = @id_producto
				WHERE id_detalle = @id_detalle AND id_factura = @id_factura;
            END
            ELSE
            BEGIN
                PRINT 'Error: Producto no existe.';
            END
        END

        IF @cantidad IS NOT NULL
        BEGIN
            IF @cantidad > 0
            BEGIN
                UPDATE gestion_venta.DetalleVenta
				SET cantidad = @cantidad
				WHERE id_detalle = @id_detalle AND id_factura = @id_factura;
            END
            ELSE
            BEGIN
                PRINT 'Error: Cantidad debe ser mayor que 0.';
            END
        END

        IF @subtotal IS NOT NULL
        BEGIN
            IF @subtotal > 0
            BEGIN
                UPDATE gestion_venta.DetalleVenta
				SET subtotal = @subtotal
				WHERE id_detalle = @id_detalle AND id_factura = @id_factura;
            END
            ELSE
            BEGIN
                PRINT 'Error: Subtotal debe ser mayor que 0.';
            END
        END

        IF @precio_unitario IS NOT NULL
        BEGIN
            IF @precio_unitario > 0
            BEGIN
                UPDATE gestion_venta.DetalleVenta
				SET precio_unitario = @precio_unitario
				WHERE id_detalle = @id_detalle AND id_factura = @id_factura;
            END
            ELSE
            BEGIN
                PRINT 'Error: Precio unitario debe ser mayor que 0.';
            END
        END

        -- Mensaje de confirmación si se realizó al menos un cambio
        PRINT 'Actualización de DetalleVenta completada.';
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró un DetalleVenta con el ID especificado y el ID de factura.';
    END
END;
GO
