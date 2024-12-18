/*
		BASE DE DATOS APLICADA
		GRUPO: 05
		COMISION: 02-5600
		INTEGRANTES:
			María del Pilar Bourdieu 45289653
			Abigail Karina Peñafiel Huayta	41913506
			Federico Pucci 41106855
			Mara Verónica Guerrera 40538513

		FECHA DE ENTREGA: 29/11/2024

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
-- ============================ STORED PROCEDURES MODIFICACION ============================
USE Com5600G05
GO

-- ============================ SP MODIFICACION GESTION_SUCURSAL ============================

IF OBJECT_ID('[gestion_sucursal].[Modificar_Sucursal]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Modificar_Sucursal];
GO

CREATE PROCEDURE gestion_sucursal.Modificar_Sucursal
	@id INT,
	@nombre VARCHAR(30) = NULL,
	@direccion VARCHAR(100) = NULL,
	@horario VARCHAR(50) = NULL,
	@telefono VARCHAR(15) = NULL,
	@activo	BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID de la sucursal.', 16, 1);
		RETURN;
	END
	-- Verificar si la sucursal existe y está activa
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id)
	BEGIN

		-- Validar el teléfono
		IF @telefono IS NOT NULL AND (gestion_validacion.Validar_Telefono(@telefono) = 0)
		BEGIN
			RAISERROR('Error: El formato del teléfono no es válido.', 16, 1);
			RETURN;
		END

		-- Actualizar el registro
		UPDATE gestion_sucursal.Sucursal
		SET 
			nombre = COALESCE(@nombre, nombre),
			direccion = COALESCE(@direccion, direccion),
			horario = COALESCE(@horario, horario),
			telefono = COALESCE(@telefono, telefono),
			activo = COALESCE(@activo, activo)
		WHERE id = @id;
 
		PRINT 'Registro de Sucursal actualizado exitosamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: No se encontró una Sucursal con ID %d.', 16, 1, @id);
	END
END;
GO

IF OBJECT_ID('[gestion_sucursal].[Modificar_Turno]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Modificar_Turno];
GO

CREATE PROCEDURE gestion_sucursal.Modificar_Turno
	@id INT,
	@descripcion VARCHAR(16) = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del turno.', 16, 1);
		RETURN;
	END

	-- Verificar si el turno existe
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Turno WHERE id = @id)
	BEGIN
		-- Validar la descripción
		IF @descripcion IS NOT NULL AND PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ ]%', @descripcion) > 0
		BEGIN
			RAISERROR('Error: La direccion solo puede contener letras y espacios (sin números ni caracteres especiales).', 16, 1);
			RETURN;
		END

		-- Actualizar el registro
		UPDATE gestion_sucursal.Turno
		SET 
			descripcion = COALESCE(@descripcion, descripcion),
			activo = COALESCE(@activo, activo)
        WHERE id = @id;

        PRINT 'Registro de Turno actualizado exitosamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: No se encontró un Turno con el ID %d.', 16, 1, @id);
	END
END;
GO

IF OBJECT_ID('[gestion_sucursal].[Modificar_Cargo]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Modificar_Cargo];
GO

CREATE PROCEDURE gestion_sucursal.Modificar_Cargo
    @id INT,
    @nombre VARCHAR(20) = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del cargo.', 16, 1);
		RETURN;
	END
	-- Verificar si el cargo existe
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Cargo WHERE id = @id)
	BEGIN
        -- Validar el nombre
		IF @nombre IS NOT NULL AND PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ ]%', @nombre) > 0
		BEGIN
			RAISERROR('Error: El nombre solo puede contener letras y espacios.', 16, 1);
			RETURN;
		END

        -- Actualizar el registro
		UPDATE gestion_sucursal.Cargo
		SET 
			nombre = COALESCE(@nombre, nombre),
			activo = COALESCE(@activo, activo)
		WHERE id = @id;

        PRINT 'Registro de Cargo actualizado exitosamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: No se encontró un Cargo con ID %d.', 16, 1, @id);
	END
END;
GO

IF OBJECT_ID('[gestion_sucursal].[Modificar_Empleado]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Modificar_Empleado];
GO

CREATE PROCEDURE gestion_sucursal.Modificar_Empleado
    @id					INT,
	@legajo				INT = NULL,
	@nombre				VARCHAR(30) = NULL,
	@apellido			VARCHAR(30) = NULL,
	@dni				BIGINT = NULL,
	@direccion			VARCHAR(160) = NULL,
	@cuil				CHAR(13) = NULL,
	@email				VARCHAR(60) = NULL,
	@email_empresa		VARCHAR(60) = NULL,
	@id_cargo			INT = NULL,
	@id_sucursal		INT = NULL,
	@id_turno			INT = NULL,
	@activo				BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del empleado.', 16, 1);
		RETURN;
	END

	-- Verificar si el empleado existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @id AND activo = 1)
    BEGIN
		-- Verificar si el nombre contiene solo letras y espacios
		IF @nombre IS NOT NULL AND PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ ]%', @nombre) > 0 
		BEGIN
			RAISERROR('Error: El nombre solo puede contener letras y un espacio (sin números ni caracteres especiales).', 16, 1);
			RETURN;
		END

		IF @apellido IS NOT NULL AND PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ ]%', @apellido) > 0
		BEGIN
			RAISERROR('Error: El apellido solo puede contener letras y un espacio (sin números ni caracteres especiales).', 16, 1);
			RETURN;
		END

		IF @direccion IS NOT NULL AND PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ0-9, ]%', @direccion) > 0
		BEGIN
			RAISERROR('Error: La direccion solo puede contener letras, números, comas y espacios.', 16, 1);
			RETURN;
		END

		IF @cuil IS NOT NULL AND (gestion_validacion.Validar_Cuil(@cuil) = 0)
		BEGIN
			RAISERROR('Error: El formato del CUIL no es válido.', 16, 1);
			RETURN;
		END
		-- Verificar si el correo electronico tiene un formato básico válido
		IF (@email IS NOT NULL AND gestion_validacion.Validar_Email(@email) = 0)
		OR (@email_empresa IS NOT NULL AND gestion_validacion.Validar_Email(@email_empresa) = 0)
		BEGIN
			RAISERROR('Error: El email o el email_empresa no tienen un formato básico válido (deben contener un "@" y un punto).', 16, 1);
			RETURN;
		END

		-- Los campos no nulos se modifican, el resto quedan con los datos iniciales
		UPDATE gestion_sucursal.Empleado
		SET
			legajo = COALESCE(@legajo, legajo),
			nombre = COALESCE(@nombre, nombre),
			apellido = COALESCE(@apellido, apellido),
			dni = COALESCE(@dni, dni),
			direccion = COALESCE(@direccion, direccion),
			cuil = COALESCE(@cuil, cuil),
			email = COALESCE(@email, email),
			email_empresa = COALESCE(@email_empresa, email_empresa),
			id_cargo = COALESCE(@id_cargo, id_cargo),
			id_sucursal = COALESCE(@id_sucursal, id_sucursal),
			id_turno = COALESCE(@id_turno, id_turno),
			activo = COALESCE(@activo, activo)
		WHERE id = @id

        -- Mensaje de confirmación si hubo al menos un cambio
        PRINT 'Actualización de Empleado completada.';
    END
    ELSE
    BEGIN
        RAISERROR('Error: No se encontró un Empleado con ID %d.', 16, 1, @id);
    END
END;
GO
	
IF OBJECT_ID('[gestion_sucursal].[Modificar_TipoCliente]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Modificar_TipoCliente];
GO

CREATE PROCEDURE gestion_sucursal.Modificar_TipoCliente
	@id INT,
	@descripcion VARCHAR(10) = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del Tipo de cliente.', 16, 1);
		RETURN;
	END

	-- Verificar si el tipo de cliente existe
	IF EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE id = @id and activo = 1)
	BEGIN
		IF @descripcion IS NOT NULL AND PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ ]%', @descripcion) > 0
		BEGIN
			RAISERROR('Error: La descripcion solo puede contener letras y espacios (sin números ni caracteres especiales).', 16, 1);
			RETURN;
		END
		-- Actualizar el registro
		UPDATE gestion_sucursal.TipoCliente
		SET
			descripcion = COALESCE(@descripcion, descripcion),
			activo = COALESCE(@activo, activo)
		WHERE id = @id;
     
		PRINT 'Registro de TipoCliente actualizado exitosamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: No se encontró un Tipo de cliente con ID %d.', 16, 1, @id);
    END
END;
GO

IF OBJECT_ID('[gestion_sucursal].[Modificar_Genero]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Modificar_Genero];
GO

CREATE PROCEDURE gestion_sucursal.Modificar_Genero
	@id INT,
	@descripcion VARCHAR(10) = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del género.', 16, 1);
		RETURN;
	END

	-- Verificar si el genero existe
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE id = @id and activo = 1)
	BEGIN
		IF @descripcion IS NOT NULL AND PATINDEX('%[^a-zA-Z ]%', @descripcion) > 0
		BEGIN
			RAISERROR('Error: La descripcion solo puede contener letras y espacios (sin números ni caracteres especiales).', 16, 1);
			RETURN;
		END
		-- Actualizar el registro
		UPDATE gestion_sucursal.Genero
		SET
			descripcion = COALESCE(@descripcion, descripcion),	
			activo = COALESCE(@activo, activo)
		WHERE id = @id;

		PRINT 'Registro de Genero actualizado exitosamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: No se encontró un Género con ID %d.', 16, 1, @id);
    END
END;
GO

IF OBJECT_ID('[gestion_sucursal].[Modificar_Cliente]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Modificar_Cliente];
GO

CREATE PROCEDURE gestion_sucursal.Modificar_Cliente
	@id INT,
	@nombre VARCHAR(50) = NULL,
	@apellido VARCHAR(50) = NULL,
	@id_tipo INT = NULL,
	@id_genero INT = NULL,
	@dni BIGINT = NULL,
	@domicilio VARCHAR(100) = NULL,
	@cuit CHAR(13) = NULL,
	@telefono VARCHAR(15) = NULL,
	@email VARCHAR(60) = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del cliente.', 16, 1);
		RETURN;
	END

	-- Verificar si el cliente existe
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Cliente WHERE id = @id)
	BEGIN
		-- Validar el nombre y apellido
		IF @nombre IS NOT NULL AND PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ ]%', @nombre) > 0
		BEGIN
			RAISERROR('Error: El nombre solo puede contener letras y un espacio (sin números ni caracteres especiales).', 16, 1);
			RETURN;
		END

		IF @apellido IS NOT NULL AND PATINDEX('%[^a-zA-ZáéíóúÁÉÍÓÚ ]%', @apellido) > 0
		BEGIN
			RAISERROR('Error: El apellido solo puede contener letras y un espacio (sin números ni caracteres especiales).', 16, 1);
			RETURN;
		END

		-- Validar id_tipo (referencia a TipoCliente)
		IF @id_tipo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE id = @id_tipo)
		BEGIN
			RAISERROR('Error: El Tipo de cliente especificado no existe.', 16, 1);
			RETURN;
		END

		-- Validar id_genero (referencia a Genero)
		IF @id_genero IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE id = @id_genero)
		BEGIN
			RAISERROR('Error: El Género especificado no existe.', 16, 1);
			RETURN;
		END

		IF @domicilio IS NOT NULL AND PATINDEX('%[^a-zA-Z0-9áéíóúÁÉÍÓÚ .-]%', @domicilio) > 0
		BEGIN
			RAISERROR('Error: La dirección contiene caracteres no permitidos.', 16, 1);
			RETURN;
		END

		IF @cuit IS NOT NULL AND (gestion_validacion.Validar_Cuil(@cuit) = 0)
		BEGIN
			RAISERROR('Error: El formato del CUIT no es válido.', 16, 1);
			RETURN;
		END
	
		IF @telefono IS NOT NULL AND (gestion_validacion.Validar_Telefono(@telefono) = 0)
		BEGIN
			RAISERROR('Error: El formato del teléfono no es válido.', 16, 1);
			RETURN;
		END
	
		-- Validación del email (si se proporciona)
		IF @email IS NOT NULL AND (gestion_validacion.Validar_Email(@email) = 0)
		BEGIN
			RAISERROR('Error: El email no tiene un formato válido.', 16, 1);
			RETURN;
		END

		-- Actualizar el registro
		UPDATE gestion_sucursal.Cliente
		SET 
			nombre = COALESCE(@nombre, nombre),
			apellido = COALESCE(@apellido, apellido),
			id_tipo = COALESCE(@id_tipo, id_tipo),
			id_genero = COALESCE(@id_genero, id_genero),
			direccion = COALESCE(@domicilio, direccion),
			dni = COALESCE(@dni, dni),
			cuit = COALESCE(@cuit , cuit),
			telefono = COALESCE(@telefono, telefono),
			email = COALESCE(@email, email),
			activo = COALESCE(@activo, activo)
        WHERE id = @id;

		PRINT 'Registro de Cliente actualizado exitosamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: No se encontró un Cliente con el ID %d.', 16, 1, @id);
	END
END;
GO
-- ============================ SP MODIFICACION GESTION_PRODUCTO ============================

IF OBJECT_ID('[gestion_producto].[Modificar_Proveedor]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_producto].[Modificar_Proveedor];
GO

CREATE PROCEDURE gestion_producto.Modificar_Proveedor
	@id INT,
	@nombre VARCHAR(100) = NULL,
	@telefono VARCHAR(15) = NULL,	
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del proveedor.', 16, 1);
		RETURN;
	END

	-- Verificar si el proveedor existe
	IF EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE id = @id)
	BEGIN
		--Si el telefono se proporciono, se verifica que tenga un formato valido--
		IF @telefono IS NOT NULL AND (gestion_validacion.Validar_Telefono(@telefono) = 0)
		BEGIN
			RAISERROR('El formato del teléfono no es válido.', 16, 1);
			RETURN;
		END
	
		-- Actualizar el registro
		UPDATE gestion_producto.Proveedor
		SET 
			nombre = COALESCE(@nombre, nombre),
			telefono = COALESCE(@telefono, telefono),
			activo = COALESCE(@activo, activo)
		WHERE id = @id;
		
		PRINT 'Registro de Proveedor actualizado exitosamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: No se encontró un Proveedor con ID %d.', 16, 1, @id);
	END
END;
GO

IF OBJECT_ID('[gestion_producto].[Modificar_TipoProducto]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_producto].[Modificar_TipoProducto];
GO

CREATE PROCEDURE gestion_producto.Modificar_TipoProducto
	@id INT,
	@nombre VARCHAR(40) = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del Tipo de producto.', 16, 1);
		RETURN;
	END

    -- Verificar si el tipo de producto existe
    IF EXISTS (SELECT 1 FROM gestion_producto.TipoProducto WHERE id = @id and activo = 1)
    BEGIN
		UPDATE gestion_producto.TipoProducto
		SET
			nombre = COALESCE(@nombre, nombre),
			activo = COALESCE(@activo, activo)
		WHERE id = @id;

        -- Confirmación si hubo un cambio
        PRINT 'Actualización de Tipo de producto completada.';
    END
    ELSE
    BEGIN
        RAISERROR('Error: No se encontró un Tipo de producto con ID %d.', 16, 1, @id);
    END
END;
GO

IF OBJECT_ID('[gestion_producto].[Modificar_Categoria]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_producto].[Modificar_Categoria];
GO

CREATE PROCEDURE gestion_producto.Modificar_Categoria
	@id INT,
	@nombre VARCHAR(50) = NULL,
	@id_tipoProducto INT = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID de la categoría.', 16, 1);
		RETURN;
	END

	-- Verificar si la categoría existe
	IF EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE id = @id)
	BEGIN
		-- Validar id_tipoProducto (referencia a TipoProducto)
		IF @id_tipoProducto IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_producto.TipoProducto WHERE id = @id_tipoProducto)
		BEGIN
			RAISERROR('Error: El Tipo de producto especificado no existe.', 16, 1);
			RETURN;
		END

		-- Actualizar el registro
		UPDATE gestion_producto.Categoria
		SET 
			nombre = COALESCE(@nombre, nombre),
			id_tipoProducto = COALESCE(@id_tipoProducto, id_tipoProducto),
			activo = COALESCE(@activo, activo)
		WHERE id = @id;

		PRINT 'Registro de Categoría actualizado exitosamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: No se encontró una Categoría con ID %d', 16, 1, @id);
	END
END;
GO

IF OBJECT_ID('[gestion_producto].[Modificar_Producto]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_producto].[Modificar_Producto];
GO

CREATE PROCEDURE gestion_producto.Modificar_Producto
	@id INT,
	@descripcion VARCHAR(50) = NULL,
	@precio DECIMAL(7,2) = NULL,
	@id_categoria INT = NULL,
	@precio_ref DECIMAL(7,2) = NULL,
	@unidad_ref CHAR(3) = NULL,
	@cant_por_unidad VARCHAR(25) = NULL,
	@id_proveedor INT = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del producto.', 16, 1);
		RETURN;
	END

	-- Verificar si el producto existe
	IF EXISTS (SELECT 1 FROM gestion_producto.Producto WHERE id = @id)
	BEGIN
		-- Validar el precio
		IF @precio IS NOT NULL AND @precio <= 0
		BEGIN
			RAISERROR('Error: El precio debe ser mayor a 0.', 16, 1);
			RETURN;
		END

		-- Validar id_categoria (referencia a Categoria)
		IF @id_categoria IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE id = @id_categoria)
		BEGIN
			RAISERROR('Error: La Categoría especificada no existe.', 16, 1);
			RETURN;
		END

		-- Validar id_proveedor (referencia a Proveedor)
		IF @id_proveedor IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE id = @id_proveedor)
		BEGIN
			RAISERROR('Error: El Proveedor especificado no existe.', 16, 1);
			RETURN;
		END

		-- Actualizar el registro
		UPDATE gestion_producto.Producto
		SET 
			descripcion = COALESCE(@descripcion, descripcion),
			precio = COALESCE(@precio, precio),
			id_categoria = COALESCE(@id_categoria, id_categoria),
			precio_ref = COALESCE(@precio_ref, precio_ref),
			unidad_ref = COALESCE(@unidad_ref, unidad_ref),
			cant_por_unidad = COALESCE(@cant_por_unidad, cant_por_unidad),
			id_proveedor = COALESCE(@id_proveedor, id_proveedor),
			activo = COALESCE(@activo, activo)
		WHERE id = @id;

		PRINT 'Registro de Producto actualizado exitosamente.';
	END
	ELSE
	BEGIN
		RAISERROR('No se encontró un Producto con ID %d.', 16, 1, @id)
	END
END;
GO

-- ============================ SP MODIFICACION GESTION_VENTA ============================

IF OBJECT_ID('[gestion_venta].[Modificar_MedioDePago]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Modificar_MedioDePago];
GO

CREATE PROCEDURE gestion_venta.Modificar_MedioDePago
    @id INT,
    @descripcion VARCHAR(30) = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del Medio de pago.', 16, 1);
		RETURN;
	END

    -- Verificar si el medio de pago existe
    IF EXISTS (SELECT 1 FROM gestion_venta.MedioDePago WHERE id = @id and activo = 1)
    BEGIN
		UPDATE gestion_venta.MedioDePago
		SET
			descripcion = COALESCE(@descripcion, descripcion),
			activo = COALESCE(@activo, activo)
		WHERE id = @id;
        -- Confirmación si hubo un cambio
        PRINT 'Actualización de Medio de pago completada.';
    END
    ELSE
    BEGIN
		RAISERROR('Error: No se encontró un Medio de pago con ID %d.', 16, 1, @id)
    END
END;
GO

IF OBJECT_ID('[gestion_venta].[Modificar_TipoFactura]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_venta].[Modificar_TipoFactura];
GO

CREATE PROCEDURE gestion_venta.Modificar_TipoFactura
    @id INT,
    @nombre CHAR(1) = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del Tipo de factura.', 16, 1);
		RETURN;
	END

    -- Verificar si el tipo de factura existe
    IF EXISTS (SELECT 1 FROM gestion_venta.TipoFactura WHERE id = @id and activo = 1)
    BEGIN
        -- Validar y actualizar nombre si se proporciona
		IF PATINDEX('[A-Za-z]', @nombre) = 1
        BEGIN
            UPDATE gestion_venta.TipoFactura
            SET
				nombre = COALESCE(@nombre, nombre),
				activo = COALESCE(@activo, activo)
            WHERE id = @id;

		-- Confirmación si hubo un cambio
			PRINT 'Actualización de Tipo de factura completada.';
        END
        ELSE
        BEGIN
			RAISERROR('Error: El nombre debe ser un solo caracter alfabético.', 16, 1);
        END
    END
    ELSE
    BEGIN
		RAISERROR('Error: No se encontró un Tipo de factura con ID %d.', 16, 1, @id);
    END
END;
GO

IF OBJECT_ID('[gestion_venta].[Modificar_Factura]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_venta].[Modificar_Factura];
GO

CREATE PROCEDURE gestion_venta.Modificar_Factura
    @id INT,
	@id_factura CHAR(11),
    @id_tipoFactura INT = NULL,
    @id_cliente INT = NULL,
    @fecha DATE = NULL,
    @hora TIME = NULL,
    @id_medioDePago INT = NULL,
    @id_empleado INT = NULL,
    @id_sucursal INT = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID de la factura.', 16, 1);
		RETURN;
	END

    -- Verificar si la factura existe
    IF EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = @id)
    BEGIN
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
		IF @id_factura IS NOT NULL AND @id_factura NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'
		BEGIN
            RAISERROR('Error: El identificador de la factura no tiene un formato válido.', 16, 1)
            RETURN;
        END

        -- Actualizar el registro
        UPDATE gestion_venta.Factura
        SET 
			id_factura = COALESCE(@id_factura, id_factura),
            id_tipoFactura = COALESCE(@id_tipoFactura, id_tipoFactura),
            id_cliente = COALESCE(@id_cliente, id_cliente),
            fecha = COALESCE(@fecha, fecha),
            hora = COALESCE(@hora, hora),
            id_medioDePago = COALESCE(@id_medioDePago, id_medioDePago),
            id_empleado = COALESCE(@id_empleado, id_empleado),
            id_sucursal = COALESCE(@id_sucursal, id_sucursal),
			activo = COALESCE(@activo, activo)
         WHERE id = @id;

        PRINT 'Registro de Factura actualizado exitosamente.';
    END
    ELSE
    BEGIN
        RAISERROR('Error: No se encontró una Factura con el ID especificado.', 16, 1);
    END
END;
GO

IF OBJECT_ID('[gestion_venta].[Modificar_DetalleVenta]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_venta].[Modificar_DetalleVenta];
GO

CREATE PROCEDURE gestion_venta.Modificar_DetalleVenta
    @id INT,
    @id_factura INT,
    @id_producto INT = NULL,
    @cantidad INT = NULL,
    @subtotal DECIMAL(8,2) = NULL,
    @precio_unitario DECIMAL(7,2) = NULL,
	@activo BIT = NULL
AS
BEGIN
	IF @id IS NULL AND @id_factura IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del detalle de venta y el ID de la factura.', 16, 1);
		RETURN;
	END

    -- Verificar si el detalle de venta existe
    IF EXISTS (SELECT 1 FROM gestion_venta.DetalleVenta WHERE id = @id AND id_factura = @id_factura)
    BEGIN
        -- Validar id_producto
        IF @id_producto IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_producto.Producto WHERE id = @id_producto)
        BEGIN
            RAISERROR('El Producto especificado no existe.', 16, 1);
            RETURN;
        END

        -- Validar id_factura
        IF NOT EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = @id_factura)
        BEGIN
            RAISERROR('Error: La Factura especificada no existe.', 16, 1);
            RETURN;
        END

        -- Validar cantidad
        IF @cantidad IS NOT NULL AND @cantidad <= 0
        BEGIN
            RAISERROR('Error: La cantidad debe ser mayor a 0.', 16, 1);
            RETURN;
        END

        -- Validar subtotal
        IF @subtotal IS NOT NULL AND @subtotal <= 0
        BEGIN
            RAISERROR('Error: El subtotal debe ser mayor a 0.', 16, 1);
            RETURN;
        END

        -- Validar precio unitario
        IF @precio_unitario IS NOT NULL AND @precio_unitario <= 0
        BEGIN
            RAISERROR('Error: El precio unitario debe ser mayor a 0.', 16, 1);
            RETURN;
        END

        -- Actualizar el registro
        UPDATE gestion_venta.DetalleVenta
        SET 
            id_producto = COALESCE(@id_producto, id_producto),
            cantidad = COALESCE(@cantidad, cantidad),
            subtotal = COALESCE(@subtotal, subtotal),
            precio_unitario = COALESCE(@precio_unitario, precio_unitario),
			activo = COALESCE(@activo, activo)
        WHERE id = @id AND id_factura = @id_factura;

        PRINT 'Registro de Detalle de Venta actualizado exitosamente.';
    END
    ELSE
    BEGIN
        RAISERROR('Error: No se encontró un Detalle de Venta con el ID y Factura especificados.', 16, 1);
    END
END;
GO
-- ============================ STORED PROCEDURES OBTENCION DE ID ============================

IF OBJECT_ID('[gestion_sucursal].[Obtener_Id_Sucursal]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_sucursal].[Obtener_Id_Sucursal];
GO

CREATE PROCEDURE gestion_sucursal.Obtener_Id_Sucursal 
	@nombreSucursal VARCHAR(30),
	@id INT OUTPUT
AS
BEGIN
	-- Inicializamos el valor del id como NULL
	SET @id = NULL;

	-- Buscar el id del producto
	SELECT @id = id
	FROM gestion_sucursal.Sucursal
	WHERE nombre = @nombreSucursal;

	-- Si no se encuentra el producto, el valor de @id será NULL
	IF @id IS NULL
	BEGIN
		PRINT 'Producto no encontrado.';
	END
END
GO

IF OBJECT_ID('[gestion_producto].[Obtener_Id_Producto]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_producto].[Obtener_Id_Producto];
GO

CREATE PROCEDURE gestion_producto.Obtener_Id_Producto
	@nombreProducto VARCHAR(100),
	@id INT OUTPUT
AS
BEGIN
	-- Inicializamos el valor del id como NULL
	SET @id = NULL;

	-- Buscar el id del producto
	SELECT @id = id
	FROM gestion_producto.Producto
	WHERE descripcion = @nombreProducto;

	-- Si no se encuentra el producto, el valor de @id será NULL
	IF @id IS NULL
	BEGIN
		PRINT 'Producto no encontrado.';
	END
END
GO

IF OBJECT_ID('[gestion_producto].[Obtener_Id_Categoria]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_producto].[Obtener_Id_Categoria];
GO

CREATE PROCEDURE gestion_producto.Obtener_Id_Categoria
	@nombreCategoria VARCHAR(50),
	@id_tipoProducto INT,
	@id INT OUTPUT
AS
BEGIN
	SET @id = NULL;

	SELECT @id = id
	FROM gestion_producto.Categoria
	WHERE nombre = @nombreCategoria AND id_tipoProducto = @id_tipoProducto

	IF @id IS NULL
	BEGIN
		PRINT 'Categoría no encontrada.';
	END
END
GO

IF OBJECT_ID('[gestion_producto].[Obtener_Id_Tipo]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_producto].[Obtener_Id_Tipo];
GO

CREATE PROCEDURE gestion_producto.Obtener_Id_Tipo
	@nombreTipo VARCHAR(40),
	@id INT OUTPUT
AS
BEGIN
	SET @id = NULL;

	SELECT @id = id
	FROM gestion_producto.TipoProducto
	WHERE nombre = @nombreTipo;

	IF @id IS NULL
	BEGIN
		PRINT 'Tipo de producto no encontrado.';
	END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Obtener_Id_Cliente]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_sucursal].[Obtener_Id_Cliente];
GO

CREATE PROCEDURE gestion_sucursal.Obtener_Id_Cliente
	@dni BIGINT,
	@id INT OUTPUT
AS
BEGIN
	-- Inicializamos el valor del id como NULL
	SET @id = NULL;

	-- Buscar el id del cliente
	SELECT @id = id
	FROM gestion_sucursal.Cliente
	WHERE dni = @dni;

	-- Si no se encuentra el cliente, el valor de @id será NULL
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: El cliente con DNI %I64d no existe.', 16, 1, @dni);
	END
END
GO

IF OBJECT_ID('[gestion_venta].[Obtener_Id_Factura]', 'P') IS NOT NULL
	DROP PROCEDURE [gestion_venta].[Obtener_Id_Factura];
GO

CREATE PROCEDURE gestion_venta.Obtener_Id_Factura
	@id_factura CHAR(11),
	@id INT OUTPUT
AS
BEGIN
	-- Inicializamos el valor del id como NULL
	SET @id = NULL;

	-- Buscar el id de la factura
	SELECT @id = id
	FROM gestion_venta.Factura
	WHERE id_factura = @id_factura;

	-- Si no se encuentra la factura, el valor de @id será NULL
	IF @id IS NULL
	BEGIN
		RAISERROR('Error: La factura con id %s no existe.', 16, 1, @id_factura);
	END
END
GO
