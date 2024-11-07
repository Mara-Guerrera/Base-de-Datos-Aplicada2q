-- ============================ STORE PROCEDURES INSERCION ============================
USE Com5600G05
GO
-- ============================ SP INSERCION GESTION_SUCURSAL =======================

CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_Ciudad
	@nombre VARCHAR(50)
AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM gestion_sucursal.Ciudad WHERE nombre = @nombre COLLATE Latin1_General_CI_AI)
	BEGIN
		INSERT INTO gestion_sucursal.Ciudad(nombre) VALUES (@nombre)
	END
	ELSE
	BEGIN
		PRINT 'La ciudad a insertar ya existe.'
		RETURN; -- acá no haría falta un RETURN porque no hay más sentencias fuera de este IF
	END
END
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_Sucursal
    @nombre VARCHAR(30),
	@id_ciudad INT
AS
BEGIN

	IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Ciudad WHERE id = @id_ciudad)
    BEGIN
        PRINT 'Error: La ciudad especificada no existe.';
        RETURN;
    END

    IF EXISTS (	SELECT 1 FROM gestion_sucursal.Sucursal
				WHERE nombre = @nombre COLLATE Latin1_General_CI_AI and activo = 1 AND id_ciudad = @id_ciudad)
    BEGIN
        PRINT 'Error: La sucursal ya existe.';
		RETURN;
    END

	IF EXISTS (	SELECT 1 FROM gestion_sucursal.Sucursal
				WHERE nombre = @nombre COLLATE Latin1_General_CI_AI AND activo = 0 AND id_ciudad = @id_ciudad)
    BEGIN
        UPDATE gestion_sucursal.Sucursal
		SET activo = 1
		WHERE nombre = @nombre AND id_ciudad = @id_ciudad AND activo = 0;
		
		PRINT 'La sucursal se dió de alta.';
		RETURN;
    END

	INSERT INTO gestion_sucursal.Sucursal(nombre, id_ciudad, activo)
	VALUES (@nombre, @id_ciudad, 1);
	PRINT 'Sucursal insertada exitosamente.';
END
GO
/*
CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_Empleado
	@nombre VARCHAR(50),
	@apellido VARCHAR(50),
	@id_sucursal_empleado INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado
		WHERE id_sucursal = @id_sucursal_empleado AND nombre = @nombre AND apellido = @apellido AND activo = 1 )
    BEGIN
        PRINT 'Error: El empleado ya existe.';
        RETURN;
    END

	IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE @id_sucursal_empleado = id AND activo = 1)
	BEGIN
		IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE nombre = @nombre AND apellido = @apellido AND activo = 0)
		BEGIN
			UPDATE gestion_sucursal.Empleado
            SET activo = 1
            WHERE @nombre = nombre COLLATE Latin1_General_CI_AI and activo = 0;
			
			PRINT 'El empleado se dió de alta.';
			RETURN;
		END

		INSERT INTO gestion_sucursal.Empleado(nombre, apellido, id_sucursal, activo)
		VALUES (@nombre, @apellido, @id_sucursal_empleado, 1)
		PRINT 'Nuevo empleado insertado con exito.'
	END
	ELSE
	BEGIN
		PRINT 'El id de sucursal: ' + CAST(@id_sucursal_empleado AS VARCHAR(10)) + ' no es válido.';
	END
END
GO */

CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_Empleado
	@cuil			CHAR(13), -- puede ser NULL
	@email			VARCHAR(60), -- podria ser NULL
	@email_empresa		VARCHAR(60) NOT NULL,
	@id_cargo		INT NOT NULL,
	@id_sucursal		INT NOT NULL,
	@id_turno		INT NOT NULL
AS
BEGIN
	DECLARE @cantEmpleados INT
	SELECT @cantEmpleados = COUNT(*) FROM gestion_sucursal.Empleado WHERE email_empresa = @email_empresa

	IF @cantEmpleados > 1
	BEGIN
		PRINT 'Existe mas de un empleado con ese correo asignado por la empresa'; -- No deberia pasar
		RETURN;
	END
		-- Si no hay empleados con ese email_empresa y la sucursal esta activa
	IF @cantEmpleados = 0 AND EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal AND activo = 1)
	BEGIN
		INSERT INTO gestion_sucursal.Empleado(cuil, email, email_empresa, id_cargo, id_sucursal, id_turno)
		VALUES (@cuil, @email, @email_empresa, @id_cargo, @id_sucursal, @id_turno)
		PRINT 'Nuevo empleado insertado con exito.'
		RETURN;
	END
	-- Se que solo hay un empleado con dicho email_empresa
	-- Busco su ID. Seria mas seguro con el cuil, pero no siempre me lo daran
	DECLARE @empleadoID INT
	SELECT @empleadoID = id FROM gestion_sucursal.Empleado WHERE email_empresa = @email_empresa

	-- Si el empleado esta activo en la misma sucursal
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @empleadoID AND id_sucursal = @id_sucursal AND activo = 1)
    BEGIN
        PRINT 'Error: El empleado ya existe.';
        RETURN;
    END

	-- Si la sucursal esta activa
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal AND activo = 1)
	BEGIN
	--  pero el empleado no
		IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @empleadoID AND activo = 0)
		BEGIN
			UPDATE gestion_sucursal.Empleado
            		SET activo = 1
            		WHERE email_empresa = @email_empresa AND activo = 0;
			
			PRINT 'El empleado se dió de alta.';
			RETURN;
		END

		INSERT INTO gestion_sucursal.Empleado(cuil, email, email_empresa, id_cargo, id_sucursal, id_turno)
		VALUES (@cuil, @email, @email_empresa, @id_cargo, @id_sucursal, @id_turno)
		PRINT 'Nuevo empleado insertado con exito.'
	END
	ELSE
	BEGIN
		PRINT 'El id de sucursal: ' + CAST(@id_sucursal_empleado AS VARCHAR(10)) + ' no es válido.';
	END
END
GO
-- NO HAY INSERTAR_TIPO_CLIENTE

CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_Cliente
	@name VARCHAR(50),
	@surname VARCHAR(50),
	@type INT,
	@gender INT,
	@id_city INT
AS
BEGIN
	IF EXISTS (	SELECT 1 FROM gestion_sucursal.Cliente
				WHERE nombre = @name  COLLATE Latin1_General_CI_AI AND apellido = @surname  COLLATE Latin1_General_CI_AI
				AND id_tipo = @type AND id_genero = @gender AND id_ciudad = @id_city AND activo = 1 )
	BEGIN
		PRINT 'El cliente ya existe.';
		RETURN;
	END

	IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Ciudad WHERE id = @id_city)
	BEGIN
		PRINT 'La ciudad no existe.';
		RETURN;
	END

	IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE id = @type)
    BEGIN
        PRINT 'El tipo de cliente no existe.';
        RETURN;
    END

    -- Verificación de la existencia del género
    IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE id = @gender)
    BEGIN
        PRINT 'El género no existe.';
        RETURN;
    END

	IF EXISTS (	SELECT 1 FROM gestion_sucursal.Cliente
				WHERE nombre = @name  COLLATE Latin1_General_CI_AI AND apellido = @surname  COLLATE Latin1_General_CI_AI
				AND id_tipo = @type AND id_genero = @gender AND id_ciudad = @id_city AND activo = 0 )
	BEGIN
		UPDATE gestion_sucursal.Cliente
        SET activo = 1
        WHERE nombre = @name  COLLATE Latin1_General_CI_AI AND apellido = @surname  COLLATE Latin1_General_CI_AI
		AND id_tipo = @type AND id_genero = @gender AND id_ciudad = @id_city AND activo = 0

		PRINT 'El cliente se dió de alta.';
		RETURN;
	END

	--Inserción del nuevo cliente
	INSERT INTO gestion_sucursal.Cliente (nombre, apellido, id_tipo, id_genero, id_ciudad,activo)
	VALUES (@name, @surname, @type, @gender, @id_city,1);
	PRINT 'Cliente insertado con éxito.';
END
GO
-- ============================ SP INSERCION GESTION_PRODUCTO ============================

CREATE OR ALTER PROCEDURE gestion_producto.Insertar_Tipo_Producto 
	@nombre VARCHAR(40)
AS
BEGIN
	IF EXISTS (	SELECT 1 FROM gestion_producto.TipoProducto
				WHERE @nombre = nombre COLLATE Latin1_General_CI_AI and activo = 1)
	BEGIN
		PRINT 'El tipo de producto "' + @nombre + '" ya existe.';
		RETURN;
	END
	ELSE
	BEGIN
		IF EXISTS (	SELECT 1 FROM gestion_producto.TipoProducto
					WHERE @nombre = nombre COLLATE Latin1_General_CI_AI and activo = 0)
		BEGIN
			UPDATE gestion_producto.TipoProducto
            SET activo = 1
            WHERE @nombre = nombre COLLATE Latin1_General_CI_AI and activo = 0;
			
			PRINT 'El tipo de producto se dió de alta.';
			RETURN;
		END

		INSERT INTO gestion_productos.TipoProducto(nombre, activo)
		VALUES(@nombre, 1);
		PRINT @nombre + ' fue insertado.';
	END
END
GO

-- FALTA INSERTAR_CATEGORIA

-- Cambio campo id_tipoProducto por id_categoria
CREATE OR ALTER PROCEDURE gestion_producto.Insertar_Producto
	@descrip VARCHAR(50),
	@precio DECIMAL(7,2),
	@id_categoria INT,
	@precio_ref DECIMAL(7,2) = NULL,
	@unidad_ref CHAR(3) = NULL,
	@cant_por_unidad VARCHAR(25) = NULL
AS
BEGIN
	IF EXISTS (SELECT 1 FROM gestion_producto.TipoProducto WHERE id = @id_tipo and activo = 1)
	BEGIN
		IF EXISTS (	SELECT 1 FROM gestion_producto.Producto
					WHERE descripcion = @descrip COLLATE Latin1_General_CI_AI
					AND id_categoria = @id_categoria AND activo = 1 )
		BEGIN
			PRINT 'Error: El Producto ya existe.';
			RETURN;
		END

		IF EXISTS (	SELECT 1 FROM gestion_producto.Producto
					WHERE descripcion = @descrip COLLATE Latin1_General_CI_AI
					AND id_categoria = @id_categoria AND activo = 0 )
		BEGIN
			UPDATE gestion_producto.Producto
            SET activo = 1
            WHERE descripcion = @descrip COLLATE Latin1_General_CI_AI AND id_categoria = @id_categoria AND activo = 0;
			
			PRINT 'El Producto se dió de alta.';
			RETURN;
		END

		INSERT INTO gestion_producto.Producto(descripcion, precio, id_categoria, precio_ref, unidad_ref, cant_por_unidad, activo)
		VALUES(@descrip, @precio, @id_categoria, @precio_ref, @unidad_ref, @cant_por_unidad, 1);
		PRINT 'Nuevo Producto insertado con exito.'
		RETURN;
	END
	ELSE
	BEGIN
		PRINT 'El tipo de producto no existe.';
	END
END
GO

-- ============================ SP INSERCION GESTION_VENTA ============================

CREATE OR ALTER PROCEDURE gestion_venta.Insertar_Medio_De_Pago
	@descripcion VARCHAR(30)
AS
BEGIN
	IF EXISTS (	SELECT 1 FROM gestion_venta.MedioDePago
				WHERE descripcion = @descripcion COLLATE Latin1_General_CI_AI and activo = 1)
	BEGIN
		PRINT 'El medio de pago ya existe.';
		RETURN;
	END
	ELSE
	BEGIN
		IF EXISTS (	SELECT 1 FROM gestion_venta.MedioDePago
					WHERE descripcion = @descripcion COLLATE Latin1_General_CI_AI and activo = 0 )
		BEGIN
			UPDATE gestion_venta.MedioDePago
            SET activo = 1
            WHERE descripcion = @descripcion COLLATE Latin1_General_CI_AI and activo = 0
			
			PRINT 'El medio de pago se dió de alta.';
			RETURN;
		END

		INSERT INTO gestion_venta.MedioDePago(descripcion, activo)
		VALUES(@descripcion, 1)
		PRINT 'Medio de pago insertado con éxito.';
	END
END
GO

CREATE OR ALTER PROCEDURE gestion_venta.Insertar_DetalleVenta
    @id_producto INT,
    @id_factura CHAR(11),
    @cantidad INT
AS
BEGIN
    -- Declaración de variables
    DECLARE @subtotal_actual DECIMAL(8,2);
    DECLARE @precio_unitario DECIMAL(7,2);

    BEGIN TRY
		IF EXISTS(SELECT 1 FROM gestion_venta.DetalleVenta WHERE id_factura = @id_factura and activo = 1)
		BEGIN
			PRINT 'La factura ingresada ya existe.';
			RETURN;
		END

		IF EXISTS(SELECT 1 FROM gestion_venta.DetalleVenta WHERE id_factura = @id_factura and activo = 0)
		BEGIN
			UPDATE gestion_venta.Factura
			SET activo = 1
			WHERE id_factura = @id_factura and activo = 0

			UPDATE gestion_venta.DetalleVenta
			SET activo = 1 
			WHERE id_factura = @id_factura and activo = 0;
			PRINT 'La venta se dió de alta.';
			RETURN;
		END
		-- Obtener el precio del producto
		SELECT @precio_unitario = precio
		FROM gestion_producto.Producto 
		WHERE id = @id_producto;

		IF @precio_unitario IS NOT NULL
		BEGIN
			-- Calcular el subtotal
			SET @subtotal_actual = @cantidad * @precio_unitario;
			-- Insertar el detalle de la venta
			INSERT INTO gestion_venta.DetalleVenta(id_producto, id_factura, cantidad, subtotal, precio_unitario, activo)
			VALUES (@id_producto, @id_factura, @cantidad, @subtotal_actual, @precio_unitario, 1);
			PRINT 'Venta insertada con éxito.';
		END
		ELSE
		BEGIN
			RAISERROR('El producto con ID %d no tiene un precio válido.', 16, 1, @id_producto);
			RETURN;  -- Termina el procedimiento si el precio es NULL
		END
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE gestion_venta.Insertar_Factura
    @id CHAR(11),
    @id_tipo INT,
    @id_cliente INT,
    @fecha DATE,
    @hora TIME(7),
    @id_medio INT,
    @id_empleado INT,
    @id_sucursal INT
AS
BEGIN
    BEGIN TRY
	--Se agrega validacion para dar un mensaje intuitivo para el usuario
		IF EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id_factura = @id_factura AND activo = 1)
		BEGIN
			PRINT 'La factura ingresada ya existe.';
			RETURN;
		END

		IF EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id_factura = @id_factura AND activo = 0)
		BEGIN
			UPDATE gestion_venta.Factura
			SET activo = 1
			WHERE id_factura = @id_factura and activo = 0

			UPDATE gestion_venta.DetalleVenta
			SET activo = 1 
			WHERE id_factura = @id_factura and activo = 0;

			PRINT 'La factura se dió de alta.';
			RETURN;
		END

        -- Insertar la nueva factura en la tabla de facturas
        INSERT INTO gestion_venta.Factura (id, id_tipoFactura, id_cliente, fecha, hora, id_medioDePago, id_empleado, id_sucursal, activo)
        VALUES (@id, @id_tipo, @id_cliente, @fecha, @hora, @id_medio, @id_empleado, @id_sucursal, 1);
		PRINT 'Factura insertada con éxito.';
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
