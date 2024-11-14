/*
		BASE DE DATOS APLICADA
		GRUPO: 05
		COMISION: 02-5600
		INTEGRANTES:
			María del Pilar Bourdieu 45289653
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
en la creación de objetos. NO use el esquema “dbo”.*/
USE [Com5600G05]
GO


/****** Object:  StoredProcedure [gestion_producto].[Insertar_Categoria]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_producto].[Insertar_Categoria]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Insertar_Categoria];
GO

CREATE  PROCEDURE [gestion_producto].[Insertar_Categoria]
    @nombre VARCHAR(50),
    @id_tipoProducto INT
AS
BEGIN
    -- Verificar si el tipo de producto existe
    IF NOT EXISTS (SELECT 1 FROM gestion_producto.TipoProducto WHERE id = @id_tipoProducto)
    BEGIN
		RAISERROR('Error: El tipo de producto especificado no existe.', 16, 1);
        RETURN;
    END
	 -- Si el tipo de producto es NULL y la categoría existe con ese nombre sin tipo de producto asociado, actualizar
    IF @id_tipoProducto IS NOT NULL AND EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE nombre = @nombre AND id_tipoProducto IS NULL AND activo = 1)
    BEGIN
        PRINT 'La categoría ya existe sin tipo de producto asociado, por lo que se le asignará el tipo de producto.';
        UPDATE gestion_producto.Categoria
        SET id_tipoProducto = @id_tipoProducto 
        WHERE nombre = @nombre AND activo = 1;
        RETURN;
    END
    -- Verificar si la categoría con el mismo nombre ya existe y está activa
    IF EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE nombre = @nombre  AND id_tipoProducto = @id_tipoProducto AND activo = 1)
    BEGIN
        RAISERROR('Error: Ya existe una categoría con ese nombre para el tipo de producto especificado.',16,1);
        RETURN;
    END

    -- Reactivar la categoría si ya existe pero está inactiva
    IF EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE nombre = @nombre  AND id_tipoProducto = @id_tipoProducto AND activo = 0)
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

/****** Object:  StoredProcedure [gestion_producto].[Insertar_Producto]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_producto].[Insertar_Producto]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Insertar_Producto];
GO

CREATE  PROCEDURE [gestion_producto].[Insertar_Producto]
    @descrip VARCHAR(50),
    @precio DECIMAL(7,2),
    @id_categoria INT = NULL,
    @precio_ref DECIMAL(7,2) = NULL,
    @unidad_ref CHAR(3) = NULL,
    @cant_por_unidad VARCHAR(25) = NULL,
    @id_proveedor INT = NULL
AS
BEGIN
    -- Verificar si el proveedor existe y está activo
	IF @id_proveedor IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE id = @id_proveedor AND activo = 1)
		BEGIN
			RAISERROR('Error: El proveedor especificado no existe o está inactivo.',16,1);
        RETURN;
		END
	END

	IF @id_categoria IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE id = @id_categoria AND activo = 1)
		BEGIN
			RAISERROR('Error: La categoría especificada no existe o está inactiva.',16,1);
			RETURN;
		END
	END

    -- Verificar si el producto ya existe y está activo
    IF EXISTS (SELECT 1 FROM gestion_producto.Producto
               WHERE descripcion = @descrip 
               AND id_categoria = @id_categoria
               AND id_proveedor = @id_proveedor
               AND activo = 1)
    BEGIN
        RAISERROR('Error: El producto ya existe para el proveedor especificado.',16,1);
        RETURN;
    END

    -- Reactivar el producto si ya existe pero está inactivo
    IF EXISTS (SELECT 1 FROM gestion_producto.Producto
               WHERE descripcion = @descrip 
               AND id_categoria = @id_categoria
               AND id_proveedor = @id_proveedor
               AND activo = 0)
    BEGIN
        UPDATE gestion_producto.Producto
        SET activo = 1
        WHERE descripcion = @descrip 
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
/****** Object:  StoredProcedure [gestion_producto].[Insertar_Proveedor]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_producto].[Insertar_Proveedor]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Insertar_Proveedor];
GO

CREATE PROCEDURE [gestion_producto].[Insertar_Proveedor]
    @nombre VARCHAR(40)
AS
BEGIN
    -- Verificar si el proveedor con el mismo nombre ya existe y está activo
    IF EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE nombre = @nombre  AND activo = 1)
    BEGIN
        RAISERROR('Error: Ya existe un proveedor con ese nombre.',16,1);
        RETURN;
    END

    -- Si el proveedor existe pero está inactivo, se reactiva
    IF EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE nombre = @nombre  AND activo = 0)
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
/****** Object:  StoredProcedure [gestion_producto].[Insertar_Tipo_Producto]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_producto].[Insertar_Tipo_Producto]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Insertar_Tipo_Producto];
GO

CREATE PROCEDURE [gestion_producto].[Insertar_Tipo_Producto] 
	@nombre VARCHAR(40)
AS
BEGIN
	IF EXISTS (	SELECT 1 FROM gestion_producto.TipoProducto
				WHERE @nombre = nombre  and activo = 1)
	BEGIN
		RAISERROR('El tipo de producto "%s" ya existe.', 16, 1, @nombre)
		RETURN;
	END
	ELSE
	BEGIN
		IF EXISTS (	SELECT 1 FROM gestion_producto.TipoProducto
					WHERE @nombre = nombre  and activo = 0)
		BEGIN
			UPDATE gestion_producto.TipoProducto
            SET activo = 1
            WHERE @nombre = nombre  and activo = 0;
			
			PRINT 'El tipo de producto se dió de alta.';
			RETURN;
		END

		INSERT INTO gestion_producto.TipoProducto(nombre, activo)
		VALUES(@nombre, 1);
		PRINT @nombre + ' fue insertado.';
	END
END
GO
/****** Object:  StoredProcedure [gestion_sucursal].[Insertar_Cargo]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_sucursal].[Insertar_Cargo]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Insertar_Cargo];
GO

CREATE PROCEDURE [gestion_sucursal].[Insertar_Cargo]
    @nombre VARCHAR(20)
AS
BEGIN
    -- Verificar si el cargo con el mismo nombre ya existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Cargo WHERE nombre = @nombre  AND activo = 1)
    BEGIN
        RAISERROR('Error: Ya existe un cargo con ese nombre.',16,1);
        RETURN;
    END

    -- Si el cargo está inactivo, se reactiva
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Cargo WHERE nombre = @nombre  AND activo = 0)
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
/****** Object:  StoredProcedure [gestion_sucursal].[Insertar_Cliente]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_sucursal].[Insertar_Cliente]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Insertar_Cliente];
GO

CREATE PROCEDURE [gestion_sucursal].[Insertar_Cliente]
	@name VARCHAR(50),
	@surname VARCHAR(50),
	@type INT,
	@gender INT
AS
BEGIN
	IF EXISTS (	SELECT 1 FROM gestion_sucursal.Cliente
				WHERE nombre = @name   AND apellido = @surname  
				AND id_tipo = @type AND id_genero = @gender AND activo = 1 )
	BEGIN
		RAISERROR('El cliente ya existe.',16,1);
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
				WHERE nombre = @name   AND apellido = @surname  
				AND id_tipo = @type AND id_genero = @gender AND activo = 0 )
	BEGIN
		UPDATE gestion_sucursal.Cliente
        SET activo = 1
        WHERE nombre = @name   AND apellido = @surname  
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
/****** Object:  StoredProcedure [gestion_sucursal].[Insertar_Empleado]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_sucursal].[Insertar_Empleado]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Insertar_Empleado];
GO

CREATE PROCEDURE [gestion_sucursal].[Insertar_Empleado]
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
	--Verificación de la existencia de la sucursal, turno y cargo (foráneas)

    IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal AND activo = 1)
    BEGIN
        RAISERROR('Error: La sucursal con ID %d no existe o no está activa.', 16, 1, @id_sucursal);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Turno WHERE id = @id_turno AND activo = 1)
    BEGIN
        RAISERROR('Error: El turno con ID %d no existe o no está activo.', 16, 1, @id_turno);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Cargo WHERE id = @id_cargo AND activo = 1)
    BEGIN
        RAISERROR('Error: El cargo con ID %d no existe o no está activo.', 16, 1, @id_cargo);
        RETURN;
    END

	-- Si el empleado esta activo en la misma sucursal.
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado
			   WHERE legajo = @legajo 
			   AND id_sucursal = @id_sucursal 
			   AND activo = 1)
    BEGIN
        RAISERROR('Error: El empleado ya existe.', 16, 1);
        RETURN;
    END

	-- El empleado fue dado de baja para esa sucursal.
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado 
				WHERE legajo = @legajo 
				AND id = @id_sucursal 
				AND activo = 0)
	BEGIN
		UPDATE gestion_sucursal.Empleado
        SET activo = 1
        WHERE legajo = @legajo AND activo = 0 AND id_sucursal = @id_sucursal;
		PRINT 'El empleado se dió de alta nuevamente en esta sucursal.';
		RETURN;
	END

	--Verificación del formato de CUIL
	IF @cuil IS NOT NULL AND @cuil NOT LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'
	BEGIN
		RAISERROR('El cuil no tiene un formato válido: 99-99999999-9', 16, 1);
		RETURN;
	END
	--Verificación del formato de los correos electrónicos
	IF (@email IS NOT NULL AND PATINDEX('%@%.%', @email) = 0) 
    OR (@email_empresa IS NOT NULL AND PATINDEX('%@%.%', @email_empresa) = 0)
	BEGIN
		RAISERROR('El email o el email_empresa no tienen un formato básico válido (deben contener un "@" y un punto).', 16, 1);
		RETURN;
	END
	--Inserción de los valores en la tabla gestion_sucursal.Empleado
	INSERT INTO gestion_sucursal.Empleado(legajo, nombre, apellido, dni, direccion, cuil, email, email_empresa, id_cargo, id_sucursal, id_turno)
	VALUES (@legajo, @nombre, @apellido, @dni, @direccion, @cuil, @email, @email_empresa, @id_cargo, @id_sucursal, @id_turno)

	PRINT 'Nuevo empleado insertado con exito.'
END
GO
/****** Object:  StoredProcedure [gestion_sucursal].[Insertar_Genero]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_sucursal].[Insertar_Genero]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Insertar_Genero];
GO

CREATE PROCEDURE [gestion_sucursal].[Insertar_Genero]
    @descripcion VARCHAR(10)
AS
BEGIN
    -- Verificar si el género con la misma descripción ya existe y está activo
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE descripcion = @descripcion  AND activo = 1)
    BEGIN
        RAISERROR('Ya existe un género con dicha descripción', 16, 1);
        RETURN;
    END

    -- Si el género existe pero está inactivo, se reactiva
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE descripcion = @descripcion  AND activo = 0)
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
/****** Object:  StoredProcedure [gestion_sucursal].[Insertar_Sucursal]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================ SP INSERCION GESTION_SUCURSAL =======================
IF OBJECT_ID('[gestion_sucursal].[Insertar_Sucursal]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Insertar_Sucursal];
GO
CREATE PROCEDURE [gestion_sucursal].[Insertar_Sucursal]
    @nombre VARCHAR(30),
    @direccion VARCHAR(100),
    @horario VARCHAR(50),
    @telefono CHAR(9)
AS
BEGIN
    -- Verificar si el teléfono tiene el formato correcto
    IF PATINDEX('[^0-9-]', @telefono) > 0
    BEGIN
        RAISERROR('El telefono incluye carácteres no válidos.', 16, 1);
        RETURN;
    END

    -- Verificar si la sucursal ya existe (por nombre)
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE nombre = @nombre AND activo = 1)
    BEGIN
         RAISERROR('Ya existe la sucursal.', 16, 1);
        RETURN;
    END

    -- Verificar si la sucursal está inactiva, en cuyo caso se reactiva
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE nombre = @nombre AND activo = 0)
    BEGIN
        UPDATE gestion_sucursal.Sucursal
        SET activo = 1, direccion = @direccion, horario = @horario, telefono = @telefono
        WHERE nombre = @nombre AND activo = 0;
        PRINT 'La sucursal se dió de alta.';
        RETURN;
    END

    -- Insertar nueva sucursal
    INSERT INTO gestion_sucursal.Sucursal (nombre, direccion, horario, telefono, activo)
    VALUES (@nombre, @direccion, @horario, @telefono, 1);

    PRINT 'Sucursal insertada exitosamente.';
END
GO
/****** Object:  StoredProcedure [gestion_sucursal].[Insertar_TipoCliente]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_sucursal].[Insertar_TipoCliente]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Insertar_TipoCliente];
GO

CREATE PROCEDURE [gestion_sucursal].[Insertar_TipoCliente]
    @descripcion VARCHAR(10)
AS
BEGIN
    -- Verificar si el tipo de cliente con la misma descripción ya existe y está activo
    IF EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE descripcion = @descripcion  AND activo = 1)
    BEGIN
        RAISERROR('Ya existe el tipo de cliente que se desea insertar.', 16, 1);
        RETURN;
    END

    -- Si el tipo de cliente existe pero está inactivo, se reactiva
    IF EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE descripcion = @descripcion  AND activo = 0)
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
/****** Object:  StoredProcedure [gestion_sucursal].[Insertar_Turno]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[gestion_sucursal].[Insertar_Turno]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Insertar_Turno];
GO
CREATE PROCEDURE [gestion_sucursal].[Insertar_Turno]
    @descripcion VARCHAR(16)
AS
BEGIN
    -- Verificar si el turno con la misma descripción ya existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Turno WHERE descripcion = @descripcion  AND activo = 1)
    BEGIN
        RAISERROR('Ya existe el turno que se desea insertar.', 16, 1);
        RETURN;
    END

    -- Si el turno está inactivo, se reactiva
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Turno WHERE descripcion = @descripcion  AND activo = 0)
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
/****** Object:  StoredProcedure [gestion_venta].[Insertar_DetalleVenta]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[gestion_venta].[Insertar_DetalleVenta]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Insertar_DetalleVenta];
GO

CREATE PROCEDURE [gestion_venta].[Insertar_DetalleVenta]
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
			RAISERROR('La factura ingresada ya existe.',16,1);
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
/****** Object:  StoredProcedure [gestion_venta].[Insertar_Factura]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================ SP INSERCION GESTION_VENTA ============================
IF OBJECT_ID('[gestion_venta].[Insertar_Factura]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Insertar_Factura];
GO

CREATE PROCEDURE [gestion_venta].[Insertar_Factura]
    @id_factura CHAR(11),
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
			RAISERROR('La factura ingresada ya existe.',16,1)
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
        INSERT INTO gestion_venta.Factura (id_factura, id_tipoFactura, id_cliente, fecha, hora, id_medioDePago, id_empleado, id_sucursal, activo)
        VALUES (@id_factura, @id_tipo, @id_cliente, @fecha, @hora, @id_medio, @id_empleado, @id_sucursal, 1);
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
/****** Object:  StoredProcedure [gestion_venta].[Insertar_MedioDePago]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[gestion_venta].[Insertar_MedioDePago]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Insertar_MedioDePago];
GO
CREATE PROCEDURE [gestion_venta].[Insertar_MedioDePago]
    @nombre VARCHAR(11),
    @descripcion VARCHAR(30)
AS
BEGIN
    -- Validar que los campos requeridos no sean nulos
    IF @nombre IS NULL OR @descripcion IS NULL
    BEGIN
		RAISERROR('El nombre y la descripción no pueden ser nulos.', 16, 1);
        RETURN;
    END

    -- Verificar si el medio de pago ya existe y está activo
    IF EXISTS (SELECT 1
               FROM gestion_venta.MedioDePago
               WHERE nombre = @nombre 
               AND activo = 1)
    BEGIN
		RAISERROR('Ya existe el medio de pago.', 16, 1);
        RETURN;
    END

    -- Reactivar el medio de pago si ya existe pero está inactivo
    IF EXISTS (SELECT 1
               FROM gestion_venta.MedioDePago
               WHERE nombre = @nombre 
               AND activo = 0)
    BEGIN
        UPDATE gestion_venta.MedioDePago
        SET activo = 1,
            descripcion = @descripcion
        WHERE nombre = @nombre 
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
/****** Object:  StoredProcedure [gestion_venta].[Insertar_TipoFactura]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_venta].[Insertar_TipoFactura]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Insertar_TipoFactura];
GO

CREATE  PROCEDURE [gestion_venta].[Insertar_TipoFactura]
    @nombre CHAR(1)
AS
BEGIN
    -- Validar que el campo nombre no sea nulo
    IF @nombre IS NULL
    BEGIN
        RAISERROR('El nombre no puede ser nulo.', 16, 1);
        RETURN;
    END

    -- Verificar si el tipo de factura ya existe y está activo
    IF EXISTS (SELECT 1
               FROM gestion_venta.TipoFactura
               WHERE nombre = @nombre 
               AND activo = 1)
    BEGIN
        RAISERROR('Ya existe el tipo de factura.', 16, 1);
        RETURN;
    END

    -- Reactivar el tipo de factura si ya existe pero está inactivo
    IF EXISTS (SELECT 1
               FROM gestion_venta.TipoFactura
               WHERE nombre = @nombre 
               AND activo = 0)
    BEGIN
        UPDATE gestion_venta.TipoFactura
        SET activo = 1
        WHERE nombre = @nombre 
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
