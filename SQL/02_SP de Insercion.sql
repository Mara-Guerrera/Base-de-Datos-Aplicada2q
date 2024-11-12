-- ============================ STORE PROCEDURES INSERCION ============================
USE Com5600G05
GO
-- ============================ SP INSERCION GESTION_SUCURSAL =======================

CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_Sucursal
    @nombre VARCHAR(30),
    @direccion VARCHAR(100),
    @horario VARCHAR(50),
    @telefono CHAR(9)
AS
BEGIN
    -- Verificar si el teléfono tiene el formato correcto
    IF NOT @telefono LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
    BEGIN
        PRINT 'Error: El formato del teléfono no es válido. Debe ser 1234-5678.';
        RETURN;
    END

    -- Verificar si la sucursal ya existe (por nombre y teléfono)
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE nombre = @nombre COLLATE Latin1_General_CI_AI AND activo = 1)
    BEGIN
        PRINT 'Error: La sucursal con ese nombre y teléfono ya existe.';
        RETURN;
    END

    -- Verificar si la sucursal está inactiva, en cuyo caso se reactiva
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE nombre = @nombre COLLATE Latin1_General_CI_AI AND telefono = @telefono AND activo = 0)
    BEGIN
        UPDATE gestion_sucursal.Sucursal
        SET activo = 1, direccion = @direccion, horario = @horario, telefono = @telefono
        WHERE nombre = @nombre AND telefono = @telefono AND activo = 0;
        
        PRINT 'La sucursal se dió de alta.';
        RETURN;
    END

    -- Insertar nueva sucursal
    INSERT INTO gestion_sucursal.Sucursal (nombre, direccion, horario, telefono, activo)
    VALUES (@nombre, @direccion, @horario, @telefono, 1);

    PRINT 'Sucursal insertada exitosamente.';
END
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_Turno
    @descripcion VARCHAR(16)
AS
BEGIN
    -- Verificar si el turno con la misma descripción ya existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Turno WHERE descripcion = @descripcion COLLATE Latin1_General_CI_AI AND activo = 1)
    BEGIN
        PRINT 'Error: Ya existe un turno con esa descripción.';
        RETURN;
    END

    -- Si el turno está inactivo, se reactiva
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Turno WHERE descripcion = @descripcion COLLATE Latin1_General_CI_AI AND activo = 0)
    BEGIN
        UPDATE gestion_sucursal.Turno
        SET activo = 1
        WHERE descripcion = @descripcion AND activo = 0;
        
        PRINT 'El turno se dió de alta.';
        RETURN;
    END

    -- Insertar nuevo turno
    INSERT INTO gestion_sucursal.Turno (descripcion, activo)
    VALUES (@descripcion, 1);

    PRINT 'Turno insertado exitosamente.';
END
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_Cargo
    @nombre VARCHAR(20)
AS
BEGIN
    -- Verificar si el cargo con el mismo nombre ya existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Cargo WHERE nombre = @nombre COLLATE Latin1_General_CI_AI AND activo = 1)
    BEGIN
        PRINT 'Error: Ya existe un cargo con ese nombre.';
        RETURN;
    END

    -- Si el cargo está inactivo, se reactiva
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Cargo WHERE nombre = @nombre COLLATE Latin1_General_CI_AI AND activo = 0)
    BEGIN
        UPDATE gestion_sucursal.Cargo
        SET activo = 1
        WHERE nombre = @nombre AND activo = 0;
        
        PRINT 'El cargo se dió de alta.';
        RETURN;
    END

    -- Insertar nuevo cargo
    INSERT INTO gestion_sucursal.Cargo (nombre, activo)
    VALUES (@nombre, 1);

    PRINT 'Cargo insertado exitosamente.';
END
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_Empleado
	@legajo				INT,
	@nombre				VARCHAR(30),
	@apellido			VARCHAR(30),
	@dni				BIGINT,
	@direccion			VARCHAR(160),
	@cuil				CHAR(13),
	@email				VARCHAR(60),
	@email_empresa		VARCHAR(60),
	@id_cargo			INT,
	@id_sucursal		INT,
	@id_turno			INT
AS
BEGIN
	IF @legajo IS NULL
	BEGIN
		RAISERROR('El legajo no puede ser nulo', 16, 1);
		RETURN;
	END

	-- Si el empleado esta activo en la misma sucursal
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE legajo = @legajo AND id_sucursal = @id_sucursal AND activo = 1)
    BEGIN
        PRINT 'Error: El empleado ya existe.';
        RETURN;
    END

	-- Si la sucursal esta activa
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal AND activo = 1)
	BEGIN
	--  pero el empleado no
		IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE legajo = @legajo AND activo = 0)
		BEGIN
			UPDATE gestion_sucursal.Empleado
            SET activo = 1
            WHERE legajo = @legajo AND activo = 0;
			
			PRINT 'El empleado se dió de alta.';
			RETURN;
		END
		-- Si no hay empleados con ese legajo
		IF @nombre IS NULL OR @apellido IS NULL OR @dni IS NULL OR @email_empresa IS NULL OR
			@id_cargo IS NULL OR @id_sucursal IS NULL OR @id_turno IS NULL
		BEGIN
			RAISERROR('Los campos: nombre, apellido, dni, email_empresa, id_cargo, id_sucursal y id_turno NO pueden ser NULL.', 16, 1);
			RETURN;
		END

		-- Verificar si el nombre contiene solo letras y espacios
		IF PATINDEX('%[^a-zA-Z ]%', @nombre) > 0 OR PATINDEX('%[^a-zA-Z ]%', @apellido) > 0
		BEGIN
			RAISERROR('El nombre y apellido solo pueden contener letras (sin números ni caracteres especiales).', 16, 1);
			RETURN;
		END
		 -- Verificar que haya solo un espacio si tiene mas de un nombre o apellido
		IF LEN(@nombre) - LEN(REPLACE(@nombre, ' ', '')) > 1 OR LEN(@apellido) - LEN(REPLACE(@apellido, ' ', '')) > 1
		BEGIN
			RAISERROR('El nombre solo pueden contener un único espacio entre los dos nombres. Lo mismo con el apellido.', 16, 1);
			RETURN;
		END

		IF @direccion IS NOT NULL AND PATINDEX('%[^A-Za-z0-9, ]%', @direccion) > 0
		BEGIN
			RAISERROR('La direccion solo puede contener letras, números, comas y espacios.', 16, 1);
			RETURN;
		END

		IF @cuil IS NOT NULL AND @cuil LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'
		BEGIN
			RAISERROR('El cuil no tiene un formato válido', 16, 1);
			RETURN;
		END
		-- Verificar si el correo electronico tiene un formato básico válido
		IF @email IS NOT NULL AND PATINDEX('%[A-Za-z0-9._%+-]%@[A-Za-z0-9.-]%.[A-Za-z]{2,4}%', @email) = 0
		BEGIN
			RAISERROR('El email no tiene un formato de correo electrónico válido.', 16, 1);
			RETURN;
		END

		IF PATINDEX('%[A-Za-z0-9._%+-]%@[A-Za-z0-9.-]%.[A-Za-z]{2,4}%', @email_empresa) = 0
		BEGIN
			RAISERROR('El email_empresa no tiene un formato de correo electrónico válido.', 16, 1);
			RETURN;
		END

		INSERT INTO gestion_sucursal.Empleado(legajo, nombre, apellido, dni, direccion, cuil, email, email_empresa, id_cargo, id_sucursal, id_turno)
		VALUES (@legajo, @nombre, @apellido, @dni, @direccion, @cuil, @email, @email_empresa, @id_cargo, @id_sucursal, @id_turno)
		PRINT 'Nuevo empleado insertado con exito.'
	END
	ELSE
	BEGIN
		PRINT 'El id de sucursal: ' + CAST(@id_sucursal AS VARCHAR(10)) + ' no es válido.';
	END
END
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_TipoCliente
    @descripcion VARCHAR(10)
AS
BEGIN
    -- Verificar si el tipo de cliente con la misma descripción ya existe y está activo
    IF EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE descripcion = @descripcion COLLATE Latin1_General_CI_AI AND activo = 1)
    BEGIN
        PRINT 'Error: Ya existe un tipo de cliente con esa descripción.';
        RETURN;
    END

    -- Si el tipo de cliente existe pero está inactivo, se reactiva
    IF EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE descripcion = @descripcion COLLATE Latin1_General_CI_AI AND activo = 0)
    BEGIN
        UPDATE gestion_sucursal.TipoCliente
        SET activo = 1
        WHERE descripcion = @descripcion AND activo = 0;
        
        PRINT 'El tipo de cliente se dió de alta.';
        RETURN;
    END

    -- Insertar nuevo tipo de cliente
    INSERT INTO gestion_sucursal.TipoCliente (descripcion, activo)
    VALUES (@descripcion, 1);

    PRINT 'Tipo de cliente insertado exitosamente.';
END
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_Genero
    @descripcion VARCHAR(10)
AS
BEGIN
    -- Verificar si el género con la misma descripción ya existe y está activo
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE descripcion = @descripcion COLLATE Latin1_General_CI_AI AND activo = 1)
    BEGIN
        PRINT 'Error: Ya existe un género con esa descripción.';
        RETURN;
    END

    -- Si el género existe pero está inactivo, se reactiva
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE descripcion = @descripcion COLLATE Latin1_General_CI_AI AND activo = 0)
    BEGIN
        UPDATE gestion_sucursal.Genero
        SET activo = 1
        WHERE descripcion = @descripcion AND activo = 0;
        
        PRINT 'El género se dió de alta.';
        RETURN;
    END

    -- Insertar nuevo género
    INSERT INTO gestion_sucursal.Genero (descripcion, activo)
    VALUES (@descripcion, 1);

    PRINT 'Género insertado exitosamente.';
END
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Insertar_Cliente
	@name VARCHAR(50),
	@surname VARCHAR(50),
	@type INT,
	@gender INT,
	--@id_city INT
AS
BEGIN
	IF EXISTS (	SELECT 1 FROM gestion_sucursal.Cliente
				WHERE nombre = @name  COLLATE Latin1_General_CI_AI AND apellido = @surname  COLLATE Latin1_General_CI_AI
				AND id_tipo = @type AND id_genero = @gender AND activo = 1 )
	BEGIN
		PRINT 'El cliente ya existe.';
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
				AND id_tipo = @type AND id_genero = @gender AND activo = 0 )
	BEGIN
		UPDATE gestion_sucursal.Cliente
        SET activo = 1
        WHERE nombre = @name  COLLATE Latin1_General_CI_AI AND apellido = @surname  COLLATE Latin1_General_CI_AI
		AND id_tipo = @type AND id_genero = @gender AND activo = 0

		PRINT 'El cliente se dió de alta.';
		RETURN;
	END

	--Inserción del nuevo cliente
	INSERT INTO gestion_sucursal.Cliente (nombre, apellido, id_tipo, id_genero,activo)
	VALUES (@name, @surname, @type, @gender,1);
	PRINT 'Cliente insertado con éxito.';
END
GO
-- ============================ SP INSERCION GESTION_PRODUCTO ============================

CREATE OR ALTER PROCEDURE gestion_producto.Insertar_Proveedor
    @nombre VARCHAR(40)
AS
BEGIN
    -- Verificar si el proveedor con el mismo nombre ya existe y está activo
    IF EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE nombre = @nombre COLLATE Latin1_General_CI_AI AND activo = 1)
    BEGIN
        PRINT 'Error: Ya existe un proveedor con ese nombre.';
        RETURN;
    END

    -- Si el proveedor existe pero está inactivo, se reactiva
    IF EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE nombre = @nombre COLLATE Latin1_General_CI_AI AND activo = 0)
    BEGIN
        UPDATE gestion_producto.Proveedor
        SET activo = 1
        WHERE nombre = @nombre AND activo = 0;
        
        PRINT 'El proveedor se dió de alta nuevamente.';
        RETURN;
    END

    -- Insertar nuevo proveedor
    INSERT INTO gestion_producto.Proveedor (nombre, activo)
    VALUES (@nombre, 1);

    PRINT 'Proveedor insertado exitosamente.';
END
GO

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

CREATE OR ALTER PROCEDURE gestion_producto.Insertar_Categoria
    @nombre VARCHAR(50),
    @id_tipoProducto INT
AS
BEGIN
    -- Verificar si el tipo de producto existe
    IF NOT EXISTS (SELECT 1 FROM gestion_producto.TipoProducto WHERE id = @id_tipoProducto)
    BEGIN
        PRINT 'Error: El tipo de producto especificado no existe.';
        RETURN;
    END

    -- Verificar si la categoría con el mismo nombre ya existe y está activa
    IF EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE nombre = @nombre COLLATE Latin1_General_CI_AI AND id_tipoProducto = @id_tipoProducto AND activo = 1)
    BEGIN
        PRINT 'Error: Ya existe una categoría con ese nombre para el tipo de producto especificado.';
        RETURN;
    END

    -- Reactivar la categoría si ya existe pero está inactiva
    IF EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE nombre = @nombre COLLATE Latin1_General_CI_AI AND id_tipoProducto = @id_tipoProducto AND activo = 0)
    BEGIN
        UPDATE gestion_producto.Categoria
        SET activo = 1
        WHERE nombre = @nombre AND id_tipoProducto = @id_tipoProducto AND activo = 0;
        
        PRINT 'La categoría se reactivó exitosamente.';
        RETURN;
    END

    -- Insertar nueva categoría
    INSERT INTO gestion_producto.Categoria (nombre, id_tipoProducto, activo)
    VALUES (@nombre, @id_tipoProducto, 1);

    PRINT 'Categoría insertada exitosamente.';
END
GO

CREATE OR ALTER PROCEDURE gestion_producto.Insertar_Producto
    @descrip VARCHAR(50),
    @precio DECIMAL(7,2),
    @id_categoria INT,
    @precio_ref DECIMAL(7,2) = NULL,
    @unidad_ref CHAR(3) = NULL,
    @cant_por_unidad VARCHAR(25) = NULL,
    @id_proveedor INT
AS
BEGIN
    -- Verificar si el proveedor existe y está activo
    IF NOT EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE id = @id_proveedor AND activo = 1)
    BEGIN
        PRINT 'Error: El proveedor especificado no existe o está inactivo.';
        RETURN;
    END

    -- Verificar si la categoría existe y está activa
    IF NOT EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE id = @id_categoria AND activo = 1)
    BEGIN
        PRINT 'Error: La categoría especificada no existe o está inactiva.';
        RETURN;
    END

    -- Verificar si el producto ya existe y está activo
    IF EXISTS (SELECT 1 FROM gestion_producto.Producto
               WHERE descripcion = @descrip COLLATE Latin1_General_CI_AI
               AND id_categoria = @id_categoria
               AND id_proveedor = @id_proveedor
               AND activo = 1)
    BEGIN
        PRINT 'Error: El producto ya existe para el proveedor especificado.';
        RETURN;
    END

    -- Reactivar el producto si ya existe pero está inactivo
    IF EXISTS (SELECT 1 FROM gestion_producto.Producto
               WHERE descripcion = @descrip COLLATE Latin1_General_CI_AI
               AND id_categoria = @id_categoria
               AND id_proveedor = @id_proveedor
               AND activo = 0)
    BEGIN
        UPDATE gestion_producto.Producto
        SET activo = 1
        WHERE descripcion = @descrip COLLATE Latin1_General_CI_AI
          AND id_categoria = @id_categoria
          AND id_proveedor = @id_proveedor
          AND activo = 0;
        
        PRINT 'El producto se reactivó exitosamente.';
        RETURN;
    END

    -- Insertar el nuevo producto
    INSERT INTO gestion_producto.Producto (descripcion, precio, id_categoria, precio_ref, unidad_ref, cant_por_unidad, id_proveedor, activo)
    VALUES (@descrip, @precio, @id_categoria, @precio_ref, @unidad_ref, @cant_por_unidad, @id_proveedor, 1);

    PRINT 'Nuevo producto insertado con éxito.';
END
GO

CREATE OR ALTER PROCEDURE gestion_producto.Insertar_AccesorioElectronico
    @nombre VARCHAR(30),
    @precioDolar DECIMAL(6,2)
AS
BEGIN
    -- Validar que el precio sea positivo
    IF @precioDolar <= 0
    BEGIN
        PRINT 'Error: El precio debe ser mayor a 0.';
        RETURN;
    END

    -- Verificar si el accesorio electrónico ya existe y está activo
    IF EXISTS (SELECT 1
               FROM gestion_producto.AccesorioElectronico
               WHERE nombre = @nombre COLLATE Latin1_General_CI_AI
               AND activo = 1)
    BEGIN
        PRINT 'Error: El accesorio electrónico ya existe.';
        RETURN;
    END

    -- Reactivar el accesorio si ya existe pero está inactivo
    IF EXISTS (SELECT 1
               FROM gestion_producto.AccesorioElectronico
               WHERE nombre = @nombre COLLATE Latin1_General_CI_AI
               AND activo = 0)
    BEGIN
        UPDATE gestion_producto.AccesorioElectronico
        SET activo = 1,
            precioDolar = @precioDolar
        WHERE nombre = @nombre COLLATE Latin1_General_CI_AI
          AND activo = 0;

        PRINT 'El accesorio electrónico se reactivó exitosamente.';
        RETURN;
    END

    -- Insertar el nuevo accesorio electrónico
    INSERT INTO gestion_producto.AccesorioElectronico (nombre, precioDolar, activo)
    VALUES (@nombre, @precioDolar, 1);

    PRINT 'Nuevo accesorio electrónico insertado con éxito.';
END
GO

-- ============================ SP INSERCION GESTION_VENTA ============================

CREATE OR ALTER PROCEDURE gestion_venta.Insertar_MedioDePago
    @nombre VARCHAR(11),
    @descripcion VARCHAR(30)
AS
BEGIN
    -- Validar que los campos requeridos no sean nulos
    IF @nombre IS NULL OR @descripcion IS NULL
    BEGIN
        PRINT 'Error: El nombre y la descripción no pueden ser nulos.';
        RETURN;
    END

    -- Verificar si el medio de pago ya existe y está activo
    IF EXISTS (SELECT 1
               FROM gestion_venta.MedioDePago
               WHERE nombre = @nombre COLLATE Latin1_General_CI_AI
               AND activo = 1)
    BEGIN
        PRINT 'Error: El medio de pago ya existe.';
        RETURN;
    END

    -- Reactivar el medio de pago si ya existe pero está inactivo
    IF EXISTS (SELECT 1
               FROM gestion_venta.MedioDePago
               WHERE nombre = @nombre COLLATE Latin1_General_CI_AI
               AND activo = 0)
    BEGIN
        UPDATE gestion_venta.MedioDePago
        SET activo = 1,
            descripcion = @descripcion
        WHERE nombre = @nombre COLLATE Latin1_General_CI_AI
          AND activo = 0;

        PRINT 'El medio de pago se reactivó exitosamente.';
        RETURN;
    END

    -- Insertar el nuevo medio de pago
    INSERT INTO gestion_venta.MedioDePago (nombre, descripcion, activo)
    VALUES (@nombre, @descripcion, 1);

    PRINT 'Nuevo medio de pago insertado con éxito.';
END
GO

CREATE OR ALTER PROCEDURE gestion_venta.Insertar_TipoFactura
    @nombre CHAR(1)
AS
BEGIN
    -- Validar que el campo nombre no sea nulo
    IF @nombre IS NULL
    BEGIN
        PRINT 'Error: El nombre no puede ser nulo.';
        RETURN;
    END

    -- Verificar si el tipo de factura ya existe y está activo
    IF EXISTS (SELECT 1
               FROM gestion_venta.TipoFactura
               WHERE nombre = @nombre COLLATE Latin1_General_CI_AI
               AND activo = 1)
    BEGIN
        PRINT 'Error: El tipo de factura ya existe.';
        RETURN;
    END

    -- Reactivar el tipo de factura si ya existe pero está inactivo
    IF EXISTS (SELECT 1
               FROM gestion_venta.TipoFactura
               WHERE nombre = @nombre COLLATE Latin1_General_CI_AI
               AND activo = 0)
    BEGIN
        UPDATE gestion_venta.TipoFactura
        SET activo = 1
        WHERE nombre = @nombre COLLATE Latin1_General_CI_AI
          AND activo = 0;

        PRINT 'El tipo de factura se reactivó exitosamente.';
        RETURN;
    END

    -- Insertar el nuevo tipo de factura
    INSERT INTO gestion_venta.TipoFactura (nombre, activo)
    VALUES (@nombre, 1);

    PRINT 'Nuevo tipo de factura insertado con éxito.';
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
