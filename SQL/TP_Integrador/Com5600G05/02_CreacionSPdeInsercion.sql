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
-- ============================ STORED PROCEDURES INSERCION ============================
USE Com5600G05
GO

-- ============================ SP INSERCION GESTION_SUCURSAL ============================

/****** Object:  StoredProcedure [gestion_sucursal].[Insertar_Sucursal]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[gestion_sucursal].[Insertar_Sucursal]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Insertar_Sucursal];
GO

CREATE PROCEDURE gestion_sucursal.Insertar_Sucursal
	@nombre VARCHAR(30),
	@direccion VARCHAR(150),
	@horario VARCHAR(50) = NULL,
	@telefono VARCHAR(15) = NULL,
	@id_empresa INT
AS
BEGIN
	-- Verifico que mis campos minimos a insertar no sean nulos
	IF @nombre IS NULL AND @direccion IS NULL AND @id_empresa IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el nombre, dirección y la empresa como mínimo.', 16, 1)
		RETURN;
	END

	IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Empresa WHERE id = @id_empresa AND activo = 1)
	BEGIN
		RAISERROR('Error: La empresa no existe.', 16, 1)
		RETURN;
	END

    -- Verificar si el teléfono tiene el formato correcto
	IF @telefono IS NOT NULL AND (gestion_validacion.Validar_Telefono(@telefono) = 0)
	BEGIN
		RAISERROR('Error: El formato del teléfono no es válido.', 16, 1);
		RETURN;
	END
	
    -- Verificar si la sucursal ya existe (por nombre)
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE nombre = @nombre AND activo = 1)
	BEGIN
		RAISERROR('Error: Ya existe la sucursal.', 16, 1);
		RETURN;
	END

	-- Verificar si la sucursal está inactiva, en cuyo caso se reactiva
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE nombre = @nombre AND activo = 0)
	BEGIN
		UPDATE gestion_sucursal.Sucursal
		SET	activo = 1
		WHERE nombre = @nombre AND activo = 0;
		PRINT 'La sucursal se dió de alta.';
		RETURN;
	END

	-- Insertar nueva sucursal
	INSERT INTO gestion_sucursal.Sucursal (nombre, direccion, horario, telefono, id_empresa)
	VALUES (@nombre, @direccion, @horario, @telefono, @id_empresa);

	PRINT 'Sucursal insertada exitosamente.';
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

CREATE PROCEDURE gestion_sucursal.Insertar_Turno
    @descripcion VARCHAR(16)
AS
BEGIN
	IF @descripcion IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar la descripción del Turno.', 16, 1);
		RETURN;
	END

    -- Verificar si el turno con la misma descripción ya existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Turno WHERE descripcion = @descripcion  AND activo = 1)
    BEGIN
        RAISERROR('Error: Ya existe el turno que se desea insertar.', 16, 1);
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
    INSERT INTO gestion_sucursal.Turno (descripcion)
    VALUES (@descripcion);

    PRINT 'Turno insertado exitosamente.';
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
CREATE PROCEDURE gestion_sucursal.Insertar_Cargo
    @nombre VARCHAR(20)
AS
BEGIN
	IF @nombre IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el nombre del Cargo.', 16, 1);
		RETURN;
	END

    -- Verificar si el cargo con el mismo nombre ya existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Cargo WHERE nombre = @nombre  AND activo = 1)
    BEGIN
        RAISERROR('Error: Ya existe un cargo con ese nombre.', 16, 1);
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
    INSERT INTO gestion_sucursal.Cargo (nombre)
    VALUES (@nombre);

    PRINT 'Cargo insertado exitosamente.';
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

CREATE PROCEDURE gestion_sucursal.Insertar_Empleado
	@legajo	INT,
	@nombre	VARCHAR(30),
	@apellido VARCHAR(30),
	@dni BIGINT,
	@direccion VARCHAR(160) = NULL,
	@cuil CHAR(13) = NULL,
	@email VARCHAR(60) = NULL,
	@email_empresa VARCHAR(60) = NULL,
	@id_cargo INT,
	@id_sucursal INT,
	@id_turno INT
AS
BEGIN

	IF @legajo IS NULL AND @id_sucursal IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar legajo y sucursal como mínimo.', 16, 1);
		RETURN;
	END

	-- Verificación de la existencia de la sucursal (foranea)
	IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal AND activo = 1)
    BEGIN
        RAISERROR('Error: La sucursal con ID %d no existe o no está activa.', 16, 1, @id_sucursal);
        RETURN;
    END

	-- Si el empleado esta activo en la misma sucursal.
	IF EXISTS ( SELECT 1 FROM gestion_sucursal.Empleado
				WHERE legajo = @legajo AND id_sucursal = @id_sucursal AND activo = 1 )
    BEGIN
        RAISERROR('Error: El empleado ya existe.', 16, 1);
        RETURN;
    END

	-- El empleado fue dado de baja para esa sucursal.
	IF EXISTS ( SELECT 1 FROM gestion_sucursal.Empleado 
				WHERE legajo = @legajo AND id = @id_sucursal AND activo = 0 )
	BEGIN
		UPDATE gestion_sucursal.Empleado
        SET activo = 1
        WHERE legajo = @legajo AND activo = 0 AND id_sucursal = @id_sucursal;
		PRINT 'El empleado se dió de alta nuevamente en esta sucursal.';
		RETURN;
	END

	IF @nombre IS NULL AND @apellido IS NULL AND @dni IS NULL AND @id_turno IS NULL AND @id_cargo IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar nombre, apellido, DNI, turno y cargo para el nuevo empleado como mínimo.', 16, 1);
		RETURN;
	END

	-- Verificación de la existencia del turno y cargo (foraneas)
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

	-- Validar el nombre y apellido
	IF PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ ]%', @nombre) > 0
	BEGIN
		RAISERROR('Error: El nombre solo puede contener letras y un espacio (sin números ni caracteres especiales).', 16, 1);
		RETURN;
	END

	IF PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ ]%', @apellido) > 0
	BEGIN
		RAISERROR('Error: El apellido solo puede contener letras y un espacio (sin números ni caracteres especiales).', 16, 1);
		RETURN;
	END

	--Verificación del formato de CUIL
	IF @cuil IS NOT NULL AND (gestion_validacion.Validar_Cuil(@cuil) = 0)
	BEGIN
		RAISERROR('Error: El cuil no tiene un formato válido: XX-XXXXXXXX-X', 16, 1);
		RETURN;
	END

	--Verificación del formato de los correos electrónicos
	IF (@email IS NOT NULL AND gestion_validacion.Validar_Email(@email) = 0)
	OR (@email_empresa IS NOT NULL AND gestion_validacion.Validar_Email(@email_empresa) = 0)
	BEGIN
		RAISERROR('Error: El email o el email_empresa no tienen un formato básico válido (deben tener un "@" y un punto como mínimo).', 16, 1);
		RETURN;
	END

	--Inserción de los valores en la tabla gestion_sucursal.Empleado
	INSERT INTO gestion_sucursal.Empleado(legajo, nombre, apellido, dni, direccion, cuil, email, email_empresa, id_cargo, id_sucursal, id_turno)
	VALUES (@legajo, @nombre, @apellido, @dni, @direccion, @cuil, @email, @email_empresa, @id_cargo, @id_sucursal, @id_turno)

	PRINT 'Nuevo empleado insertado con exito.'
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

CREATE PROCEDURE gestion_sucursal.Insertar_TipoCliente
    @descripcion VARCHAR(10)
AS
BEGIN
	IF @descripcion IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar la descripción del Tipo de cliente.', 16, 1);
		RETURN;
	END
    -- Verificar si el tipo de cliente con la misma descripción ya existe y está activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE descripcion = @descripcion  AND activo = 1)
	BEGIN
		RAISERROR('Error: Ya existe el tipo de cliente que se desea insertar.', 16, 1);
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
    INSERT INTO gestion_sucursal.TipoCliente (descripcion)
    VALUES (@descripcion);

    PRINT 'Tipo de cliente insertado exitosamente.';
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

CREATE PROCEDURE gestion_sucursal.Insertar_Genero
    @descripcion VARCHAR(10)
AS
BEGIN
	IF @descripcion IS NULL
	BEGIN
		RAISERROR('Error: Debe insertar la descripcion del Género', 16, 1);
		RETURN;
	END

	-- Verificar si el género con la misma descripción ya existe y está activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE descripcion = @descripcion  AND activo = 1)
	BEGIN
		RAISERROR('Error: Ya existe un género con dicha descripción', 16, 1);
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
	INSERT INTO gestion_sucursal.Genero (descripcion)
	VALUES (@descripcion);

	PRINT 'Género insertado exitosamente.';
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

CREATE PROCEDURE gestion_sucursal.Insertar_Cliente
	@nombre VARCHAR(50),
	@apellido VARCHAR(50) = NULL,
	@id_tipo INT,
	@id_genero INT,
	@dni BIGINT,
	@domicilio VARCHAR(100) = NULL,
	@cuit CHAR(13) = NULL,
	@telefono VARCHAR(15) = NULL,
	@email VARCHAR(80) = NULL
AS
BEGIN
	IF @dni IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el DNI como mínimo.', 16, 1);
		RETURN;
	END

	IF EXISTS (	SELECT 1 FROM gestion_sucursal.Cliente
				WHERE dni = @dni AND activo = 1 )
	BEGIN
		RAISERROR('Error: El cliente ya existe.', 16, 1);
		RETURN;
	END

	-- Si el cliente existe pero no esta activo
	IF EXISTS (	SELECT 1 FROM gestion_sucursal.Cliente
				WHERE dni = @dni AND activo = 0 )
	BEGIN
		UPDATE gestion_sucursal.Cliente
        SET activo = 1
        WHERE dni = @dni
		PRINT 'El cliente se dió de alta.';
		RETURN;
	END

	IF @nombre IS NULL AND @id_tipo IS NULL AND @id_genero IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el nombre, tipo y género del nuevo cliente como mínimo.', 16, 1);
		RETURN;
	END

	 -- Verificación de la existencia del tipo de cliente
	IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE id = @id_tipo)
    BEGIN
        RAISERROR('Error: El Tipo de cliente no existe.', 16, 1);
        RETURN;
    END

    -- Verificación de la existencia del genero
    IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE id = @id_genero)
    BEGIN
        RAISERROR('Error: El género no existe.', 16, 1);
        RETURN;
    END
	
	-- Validar el nombre y apellido
	IF PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ ]%', @nombre) > 0
	BEGIN
		RAISERROR('Error: El nombre solo puede contener letras y un espacio (sin números ni caracteres especiales).', 16, 1);
		RETURN;
	END

	IF @apellido IS NOT NULL AND PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ ]%', @apellido) > 0
	BEGIN
		RAISERROR('Error: El apellido solo puede contener letras y un espacio (sin números ni caracteres especiales).', 16, 1);
		RETURN;
	END

	IF @domicilio IS NOT NULL AND PATINDEX('%[^a-zA-Z0-9áéíóúÁÉÍÓÚ .-]%', @domicilio) > 0
	BEGIN
		RAISERROR('La dirección contiene caracteres no permitidos.', 16, 1);
		RETURN;
	END

	IF @cuit IS NOT NULL AND (gestion_validacion.Validar_Cuil(@cuit) = 0)
	BEGIN
		RAISERROR('Error: El formato del CUIT no es válido.', 16, 1);
		RETURN;
	END

	IF @telefono IS NOT NULL AND (gestion_validacion.Validar_Telefono(@telefono) = 0)
	BEGIN
		RAISERROR('Error: El formato del teléfono no es válido.',16,1);
		RETURN;
	END

	IF @email IS NOT NULL AND (gestion_validacion.Validar_Email(@email) = 0)
	BEGIN
		RAISERROR('Error: El email no tiene un formato válido.', 16, 1);
		RETURN;
	END

	--Inserción del nuevo cliente
	INSERT INTO gestion_sucursal.Cliente (nombre, apellido, id_tipo, id_genero, direccion, dni, cuit, telefono, email)
	VALUES (@nombre, @apellido, @id_tipo, @id_genero, @domicilio, @dni, @cuit, @telefono, @email);
	PRINT 'Cliente insertado con éxito.';
END
GO

-- ============================ SP INSERCION GESTION_PRODUCTO ============================

/****** Object:  StoredProcedure [gestion_producto].[Insertar_Proveedor]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_producto].[Insertar_Proveedor]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Insertar_Proveedor];
GO

CREATE PROCEDURE gestion_producto.Insertar_Proveedor
    @nombre		VARCHAR(100),
	@telefono	VARCHAR(15) = NULL
AS
BEGIN
	IF @nombre IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el nombre como mínimo.', 16, 1);
		RETURN;
	END

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

	IF @telefono IS NOT NULL AND (gestion_validacion.Validar_Telefono(@telefono) = 0)
	BEGIN
		RAISERROR('Error: El formato del teléfono no es válido.',16,1);
		RETURN;
	END
	
    -- Insertar nuevo proveedor
    INSERT INTO gestion_producto.Proveedor (nombre, telefono)
    VALUES (@nombre, @telefono);

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

CREATE PROCEDURE gestion_producto.Insertar_Tipo_Producto
	@nombre VARCHAR(40)
AS
BEGIN
	IF @nombre IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el nombre del Tipo de producto', 16, 1)
		RETURN;
	END

	IF EXISTS (	SELECT 1
				FROM gestion_producto.TipoProducto
				WHERE @nombre = nombre AND activo = 1 )
	BEGIN
		RAISERROR('Error: El tipo de producto "%s" ya existe.', 16, 1, @nombre)
		RETURN;
	END
	ELSE
	BEGIN
		IF EXISTS (	SELECT 1
					FROM gestion_producto.TipoProducto
					WHERE @nombre = nombre AND activo = 0)
		BEGIN
			UPDATE gestion_producto.TipoProducto
            SET activo = 1
            WHERE @nombre = nombre AND activo = 0;
			
			PRINT 'El tipo de producto se dió de alta.';
			RETURN;
		END

		INSERT INTO gestion_producto.TipoProducto(nombre)
		VALUES(@nombre);
		PRINT @nombre + ' fue insertado.';
	END
END
GO

/****** Object:  StoredProcedure [gestion_producto].[Insertar_Categoria]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_producto].[Insertar_Categoria]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Insertar_Categoria];
GO

CREATE PROCEDURE gestion_producto.Insertar_Categoria
    @nombre VARCHAR(50),
    @id_tipoProducto INT
AS
BEGIN
	IF @nombre IS NULL AND @id_tipoProducto IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el nombre el tipo de producto de la Categoría.', 16, 1);
        RETURN;
    END
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
        RAISERROR('Error: Ya existe una categoría con ese nombre para el tipo de producto especificado.', 16, 1);
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
    INSERT INTO gestion_producto.Categoria (nombre, id_tipoProducto)
    VALUES (@nombre, @id_tipoProducto);

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

CREATE PROCEDURE gestion_producto.Insertar_Producto
    @descripcion VARCHAR(50),
    @precio DECIMAL(7,2),
    @id_categoria INT = NULL,
    @precio_ref DECIMAL(7,2) = NULL,
    @unidad_ref CHAR(3) = NULL,
    @cant_por_unidad VARCHAR(25) = NULL,
    @id_proveedor INT = NULL
AS
BEGIN
	IF @descripcion IS NULL AND @precio IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar la descripción y precio del Producto como mínimo.', 16, 1);
        RETURN;
    END
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
               WHERE descripcion = @descripcion
               AND id_categoria = @id_categoria
               AND id_proveedor = @id_proveedor
               AND activo = 1)
    BEGIN
        RAISERROR('Error: El producto ya existe para el proveedor especificado.',16,1);
        RETURN;
    END

    -- Reactivar el producto si ya existe pero está inactivo
    IF EXISTS (SELECT 1 FROM gestion_producto.Producto
               WHERE descripcion = @descripcion
               AND id_categoria = @id_categoria
               AND id_proveedor = @id_proveedor
               AND activo = 0)
    BEGIN
        UPDATE gestion_producto.Producto
        SET activo = 1
        WHERE descripcion = @descripcion 
          AND id_categoria = @id_categoria
          AND id_proveedor = @id_proveedor
          AND activo = 0;
        
        PRINT 'El producto se reactivó exitosamente.';
        RETURN;
    END

    -- Insertar el nuevo producto
    INSERT INTO gestion_producto.Producto (descripcion, precio, id_categoria, precio_ref, unidad_ref, cant_por_unidad, id_proveedor)
    VALUES (@descripcion, @precio, @id_categoria, @precio_ref, @unidad_ref, @cant_por_unidad, @id_proveedor);

    PRINT 'Nuevo producto insertado con éxito.';
END
GO

-- ============================ SP INSERCION GESTION_VENTA ============================

/****** Object:  StoredProcedure [gestion_venta].[Insertar_MedioDePago]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[gestion_venta].[Insertar_MedioDePago]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Insertar_MedioDePago];
GO

CREATE PROCEDURE gestion_venta.Insertar_MedioDePago
    @nombre VARCHAR(11),
    @descripcion VARCHAR(30) = NULL
AS
BEGIN
    IF @nombre IS NULL
    BEGIN
		RAISERROR('Error: Debe ingresar el nombre del Medio de pago', 16, 1);
        RETURN;
    END

    -- Verificar si el medio de pago ya existe y está activo
    IF EXISTS (SELECT 1
               FROM gestion_venta.MedioDePago
               WHERE nombre = @nombre AND activo = 1)
    BEGIN
		RAISERROR('Error: Ya existe el medio de pago.', 16, 1);
        RETURN;
    END

    -- Reactivar el medio de pago si ya existe pero está inactivo
    IF EXISTS (SELECT 1
               FROM gestion_venta.MedioDePago
               WHERE nombre = @nombre 
               AND activo = 0)
    BEGIN
        UPDATE gestion_venta.MedioDePago
        SET activo = 1
        WHERE nombre = @nombre AND activo = 0;

        PRINT 'El medio de pago se reactivó exitosamente.';
        RETURN;
    END

    -- Insertar el nuevo medio de pago
    INSERT INTO gestion_venta.MedioDePago (nombre, descripcion)
    VALUES (@nombre, @descripcion);

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

CREATE PROCEDURE gestion_venta.Insertar_TipoFactura
    @nombre CHAR(1)
AS
BEGIN
    -- Validar que el campo nombre no sea nulo
    IF @nombre IS NULL
    BEGIN
        RAISERROR('Error: Debe ingresar el nombre del Tipo de factura.', 16, 1);
        RETURN;
    END

    -- Verificar si el tipo de factura ya existe y está activo
    IF EXISTS (SELECT 1
               FROM gestion_venta.TipoFactura
               WHERE nombre = @nombre AND activo = 1)
    BEGIN
        RAISERROR('Error: Ya existe el tipo de factura.', 16, 1);
        RETURN;
    END

    -- Reactivar el tipo de factura si ya existe pero está inactivo
    IF EXISTS (SELECT 1
               FROM gestion_venta.TipoFactura
               WHERE nombre = @nombre AND activo = 0)
    BEGIN
        UPDATE gestion_venta.TipoFactura
        SET activo = 1
        WHERE nombre = @nombre AND activo = 0;

        PRINT 'El tipo de factura se reactivó exitosamente.';
        RETURN;
    END

    -- Insertar el nuevo tipo de factura
    INSERT INTO gestion_venta.TipoFactura (nombre)
    VALUES (@nombre);

    PRINT 'Nuevo tipo de factura insertado con éxito.';
END
GO

/****** Object:  StoredProcedure [gestion_venta].[Insertar_Factura]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[gestion_venta].[Insertar_Factura]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Insertar_Factura];
GO

CREATE PROCEDURE gestion_venta.Insertar_Factura
    @id_factura CHAR(11),
    @id_tipoFactura INT,
    @id_cliente INT,
    @fecha DATE,
    @hora TIME(7),
    @id_medioDePago INT,
    @id_empleado INT,
    @id_sucursal INT
AS
BEGIN
	IF @id_factura IS NULL AND @id_tipoFactura IS NULL AND @id_cliente IS NULL
	AND @id_medioDePago IS NULL AND @id_empleado IS NULL AND @id_sucursal IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar los datos mínimos a insertar.', 16, 1);
		RETURN;
	END

    BEGIN TRY
	--Se agrega validacion para dar un mensaje intuitivo para el usuario
		IF EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id_factura = @id_factura AND activo = 1)
		BEGIN
			RAISERROR('Error: La factura ingresada ya existe.', 16, 1)
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

		 -- Validar id_tipoFactura
        IF @id_tipoFactura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_venta.TipoFactura WHERE id = @id_tipoFactura)
        BEGIN
			RAISERROR('Error: El Tipo de Factura especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar id_cliente
        IF @id_cliente IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_sucursal.Cliente WHERE id = @id_cliente)
        BEGIN
            RAISERROR('Error: El Cliente especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar id_medioDePago
        IF @id_medioDePago IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_venta.MedioDePago WHERE id = @id_medioDePago)
        BEGIN
            RAISERROR('Error: El Medio de pago especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar id_empleado
        IF @id_empleado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @id_empleado)
        BEGIN
            RAISERROR('Error: El Empleado especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar id_sucursal
        IF @id_sucursal IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal)
        BEGIN
            RAISERROR('Error: La Sucursal especificada no existe.', 16, 1);
            RETURN;
        END

		-- Validar formato de id_factura
		IF @id_factura NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
		BEGIN
            RAISERROR('Error: El identificador de la factura no tiene un formato válido.', 16, 1)
            RETURN;
        END
		-- Si no me dan la fecha y hora, las obtengo en el momento
		IF @fecha IS NULL
		BEGIN
			SET @fecha = CAST(GETDATE() AS DATE)
		END

		IF @hora IS NULL
		BEGIN
			SET @hora = CAST(GETDATE() AS TIME)
		END
        -- Insertar la nueva factura en la tabla de facturas
        INSERT INTO gestion_venta.Factura (id_factura, id_tipoFactura, id_cliente, fecha, hora, id_medioDePago, id_empleado, id_sucursal)
        VALUES (@id_factura, @id_tipoFactura, @id_cliente, @fecha, @hora, @id_medioDePago, @id_empleado, @id_sucursal);
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

/****** Object:  StoredProcedure [gestion_venta].[Insertar_DetalleVenta]    Script Date: 13/11/2024 14:39:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[gestion_venta].[Insertar_DetalleVenta]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Insertar_DetalleVenta];
GO

CREATE PROCEDURE gestion_venta.Insertar_DetalleVenta
    @id_producto INT,
    @id_factura INT,
    @cantidad INT
AS
BEGIN
	IF @id_factura IS NULL AND @id_producto IS NULL AND @cantidad IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el producto, la factura y cantidad.', 16, 1);
		RETURN;
	END

    -- Declaración de variables
    DECLARE @subtotal_actual DECIMAL(8,2);
    DECLARE @precio_unitario DECIMAL(7,2);

    BEGIN TRY
		IF NOT EXISTS(SELECT 1 FROM gestion_venta.DetalleVenta WHERE id_factura = @id_factura and activo = 1)
		BEGIN
			RAISERROR('Error: La factura no existe.',16,1);
			RETURN;
		END

		IF EXISTS(SELECT 1 FROM gestion_venta.DetalleVenta WHERE id_factura = @id_factura and activo = 0)
		BEGIN
			UPDATE gestion_venta.Factura
			SET activo = 1
			WHERE id = @id_factura and activo = 0

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
			INSERT INTO gestion_venta.DetalleVenta(id_producto, id_factura, cantidad, subtotal, precio_unitario)
			VALUES (@id_producto, @id_factura, @cantidad, @subtotal_actual, @precio_unitario);
			PRINT 'Venta insertada con éxito.';
		END
		ELSE
		BEGIN
			RAISERROR('Error: El producto con ID %d no tiene un precio válido.', 16, 1, @id_producto);
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
