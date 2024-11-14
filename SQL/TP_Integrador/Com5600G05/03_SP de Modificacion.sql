-- ============================ STORE PROCEDURES MODIFICACION ============================
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
    @telefono CHAR(9) = NULL
AS
BEGIN
    -- Verificar si la sucursal existe y está activa
	    IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id)
	    BEGIN
	-- Validar la direccion
		IF @direccion IS NOT NULL AND PATINDEX('%[^A-Za-z0-9, ]%', @direccion) > 0
		BEGIN
			RAISERROR('La direccion solo puede contener letras, números, comas y espacios.', 16, 1);
			RETURN;
		END

		-- Validar el teléfono
/*		IF PATINDEX('[^0-9-]', @telefono) > 0
		BEGIN
			RAISERROR('El telefono incluye carácteres no válidos.', 16, 1);
			RETURN;
		END
*/
		IF PATINDEX('[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]', @telefono) = 0
		BEGIN
			RAISERROR('Error: El formato del teléfono no es válido. Ej: 5555-5555.', 16, 1);
			RETURN;
		END

		-- Actualizar el registro
		UPDATE gestion_sucursal.Sucursal
		SET 
			nombre = COALESCE(@nombre, nombre),
			direccion = COALESCE(@direccion, direccion),
			horario = COALESCE(@horario, horario),
			telefono = COALESCE(@telefono, telefono)
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
    -- Verificar si el turno existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Turno WHERE id = @id)
    BEGIN
        -- Validar la descripción
        IF @descripcion IS NOT NULL AND LEN(@descripcion) > 16
        BEGIN
            PRINT 'Error: La descripción supera el límite de 16 caracteres.';
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
        RAISERROR('Error: No se encontró un Turno con el ID especificado.',16,1);
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
    -- Verificar si el cargo existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Cargo WHERE id = @id)
    BEGIN
        -- Validar el nombre
        IF @nombre IS NOT NULL AND LEN(@nombre) > 20
        BEGIN
            PRINT 'Error: El nombre del cargo supera el límite de 20 caracteres.';
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
		RAISERROR('Error: No se encontró un Cargo con el ID especificado.',16,1);
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
	@id_turno			INT = NULL
AS
BEGIN
	IF @legajo IS NULL AND @nombre IS NULL AND @apellido IS NULL AND @dni IS NULL AND @direccion IS NULL AND
		@cuil IS NULL AND @email IS NULL AND @email_empresa IS NULL
		AND @id_cargo IS NULL AND @id_sucursal IS NULL AND @id_turno IS NULL
    BEGIN
		RAISERROR('No se ingresó los datos que se quieren modificar.', 16, 1);
		RETURN;
	END

    -- Verificar si el empleado existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @id AND activo = 1)
    BEGIN
		-- Verificar si el nombre contiene solo letras y espacios
		IF @nombre IS NOT NULL
		BEGIN
			IF PATINDEX('%[^a-zA-Z ]%', @nombre) > 0 
			BEGIN
				RAISERROR('El nombre solo puede contener letras (sin números ni caracteres especiales).', 16, 1);
				RETURN;
			END
		END

		IF @apellido IS NOT NULL
		BEGIN
			IF PATINDEX('%[^a-zA-Z ]%', @apellido) > 0
			BEGIN
				RAISERROR('El apellido solo puede contener letras (sin números ni caracteres especiales).', 16, 1);
				RETURN;
			END
		END

		IF @direccion IS NOT NULL AND PATINDEX('%[^A-Za-z0-9, ]%', @direccion) > 0
		BEGIN
			RAISERROR('La direccion solo puede contener letras, números, comas y espacios.', 16, 1);
			RETURN;
		END

		IF @cuil IS NOT NULL AND @cuil LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'
		BEGIN
			RAISERROR('El cuil no tiene un formato válido: XX-XXXXXXXX-X', 16, 1);
			RETURN;
		END
		-- Verificar si el correo electronico tiene un formato básico válido
		IF (@email IS NOT NULL AND PATINDEX('%@%.%', @email) = 0) 
		OR (@email_empresa IS NOT NULL AND PATINDEX('%@%.%', @email_empresa) = 0)
		BEGIN
			RAISERROR('El email o el email_empresa no tienen un formato básico válido (deben contener un "@" y un punto).', 16, 1);
			RETURN;
		END

		-- Los campos no nulos se modifican, el resto quedan con los datos iniciales
		UPDATE gestion_sucursal.Empleado
		SET
			legajo = ISNULL(@legajo, legajo),
			nombre = ISNULL(@nombre, nombre),
			apellido = ISNULL(@apellido, apellido),
			dni = ISNULL(@dni, dni),
			direccion = ISNULL(@direccion, direccion),
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
IF OBJECT_ID('[gestion_sucursal].[Modificar_TipoCliente]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Modificar_TipoCliente];
GO
CREATE  PROCEDURE gestion_sucursal.Modificar_TipoCliente
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
IF OBJECT_ID('[gestion_sucursal].[Modificar_Genero]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Modificar_Genero];
GO
CREATE PROCEDURE gestion_sucursal.Modificar_Genero
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
IF OBJECT_ID('[gestion_sucursal].[Modificar_Cliente]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Modificar_Cliente];
GO
CREATE PROCEDURE gestion_sucursal.Modificar_Cliente
    @id INT,
    @nombre VARCHAR(50) = NULL,
    @apellido VARCHAR(50) = NULL,
    @id_tipo INT = NULL,
    @id_genero INT = NULL,
    @activo BIT = NULL
AS
BEGIN
    -- Verificar si el cliente existe
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Cliente WHERE id = @id)
    BEGIN
        -- Validar el nombre y apellido
        IF @nombre IS NOT NULL AND LEN(@nombre) > 50
        BEGIN
            PRINT 'Error: El nombre supera el límite de 50 caracteres.';
            RETURN;
        END

        IF @apellido IS NOT NULL AND LEN(@apellido) > 50
        BEGIN
            PRINT 'Error: El apellido supera el límite de 50 caracteres.';
            RETURN;
        END

        -- Validar id_tipo (referencia a TipoCliente)
        IF @id_tipo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE id = @id_tipo)
        BEGIN
            PRINT 'Error: El Tipo de Cliente especificado no existe.';
            RETURN;
        END

        -- Validar id_genero (referencia a Genero)
        IF @id_genero IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE id = @id_genero)
        BEGIN
            PRINT 'Error: El Género especificado no existe.';
            RETURN;
        END

        -- Actualizar el registro
        UPDATE gestion_sucursal.Cliente
        SET 
            nombre = COALESCE(@nombre, nombre),
            apellido = COALESCE(@apellido, apellido),
            id_tipo = COALESCE(@id_tipo, id_tipo),
            id_genero = COALESCE(@id_genero, id_genero),
            activo = COALESCE(@activo, activo)
        WHERE id = @id;

        PRINT 'Registro de Cliente actualizado exitosamente.';
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró un Cliente con el ID especificado.';
    END
END;
GO
IF OBJECT_ID('[gestion_producto].[Modificar_Proveedor]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Modificar_Proveedor];
GO
CREATE  PROCEDURE gestion_producto.Modificar_Proveedor
    @id INT,
    @nombre VARCHAR(40) = NULL,
    @activo BIT = NULL
AS
BEGIN
    -- Verificar si el proveedor existe
    IF EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE id = @id)
    BEGIN
        -- Validar el nombre
        IF @nombre IS NOT NULL AND LEN(@nombre) > 40
        BEGIN
            PRINT 'Error: El nombre del proveedor supera el límite de 40 caracteres.';
            RETURN;
        END

        -- Actualizar el registro
        UPDATE gestion_producto.Proveedor
        SET 
            nombre = COALESCE(@nombre, nombre),
            activo = COALESCE(@activo, activo)
        WHERE id = @id;

        PRINT 'Registro de Proveedor actualizado exitosamente.';
    END
    ELSE
    BEGIN
        PRINT 'Error: No se encontró un Proveedor con el ID especificado.';
    END
END;
GO

-- ============================ SP MODIFICACION GESTION_PRODUCTO ============================
IF OBJECT_ID('[gestion_producto].[Modificar_TipoProducto]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Modificar_TipoProducto];
GO
CREATE  PROCEDURE gestion_producto.Modificar_TipoProducto
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
IF OBJECT_ID('[gestion_producto].[Modificar_Categoria]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Modificar_Categoria];
GO
CREATE  PROCEDURE gestion_producto.Modificar_Categoria
    @id INT,
    @nombre VARCHAR(50) = NULL,
    @id_tipoProducto INT = NULL,
    @activo BIT = NULL
AS
BEGIN
    -- Verificar si la categoría existe
    IF EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE id = @id)
    BEGIN
        -- Validar el nombre
        IF @nombre IS NOT NULL AND LEN(@nombre) > 50
        BEGIN
            PRINT 'Error: El nombre de la categoría supera el límite de 50 caracteres.';
            RETURN;
        END

        -- Validar id_tipoProducto (referencia a TipoProducto)
        IF @id_tipoProducto IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_producto.TipoProducto WHERE id = @id_tipoProducto)
        BEGIN
            PRINT 'Error: El Tipo de Producto especificado no existe.';
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
        PRINT 'Error: No se encontró una Categoría con el ID especificado.';
    END
END;
GO
IF OBJECT_ID('[gestion_producto].[Modificar_Producto]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Modificar_Producto];
GO
CREATE  PROCEDURE gestion_producto.Modificar_Producto
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
    -- Verificar si el producto existe
    IF EXISTS (SELECT 1 FROM gestion_producto.Producto WHERE id = @id)
    BEGIN
        -- Validar la descripción
        IF @descripcion IS NOT NULL AND LEN(@descripcion) > 50
        BEGIN
            PRINT 'Error: La descripción supera el límite de 50 caracteres.';
            RETURN;
        END

        -- Validar el precio
        IF @precio IS NOT NULL AND @precio <= 0
        BEGIN
            PRINT 'Error: El precio debe ser mayor a 0.';
            RETURN;
        END

        -- Validar id_categoria (referencia a Categoria)
        IF @id_categoria IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE id = @id_categoria)
        BEGIN
            PRINT 'Error: La Categoría especificada no existe.';
            RETURN;
        END

        -- Validar id_proveedor (referencia a Proveedor)
        IF @id_proveedor IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE id = @id_proveedor)
        BEGIN
            PRINT 'Error: El Proveedor especificado no existe.';
            RETURN;
        END

        -- Validar la longitud de unidad_ref
        IF @unidad_ref IS NOT NULL AND LEN(@unidad_ref) <> 3
        BEGIN
            PRINT 'Error: La unidad de referencia debe tener exactamente 3 caracteres.';
            RETURN;
        END

        -- Validar la longitud de cant_por_unidad
        IF @cant_por_unidad IS NOT NULL AND LEN(@cant_por_unidad) > 25
        BEGIN
            PRINT 'Error: La cantidad por unidad supera el límite de 25 caracteres.';
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
        PRINT 'Error: No se encontró un Producto con el ID especificado.';
    END
END;
GO

-- ============================ SP MODIFICACION GESTION_VENTA ============================
IF OBJECT_ID('[gestion_venta].[Modificar_MedioDePago]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Modificar_MedioDePago];
GO
CREATE  PROCEDURE gestion_venta.Modificar_MedioDePago
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
IF OBJECT_ID('[gestion_venta].[Modificar_TipoFactura]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Modificar_TipoFactura];
GO
CREATE  PROCEDURE gestion_venta.Modificar_TipoFactura
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
IF OBJECT_ID('[gestion_venta].[Modificar_Factura]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Modificar_Factura];
GO
CREATE  PROCEDURE gestion_venta.Modificar_Factura
    @id CHAR(11),
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
    -- Verificar si la factura existe
    IF EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = @id)
    BEGIN
        -- Validar id_tipoFactura
        IF @id_tipoFactura IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_venta.TipoFactura WHERE id = @id_tipoFactura)
        BEGIN
            PRINT 'Error: El Tipo de Factura especificado no existe.';
            RETURN;
        END

        -- Validar id_cliente
        IF @id_cliente IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_sucursal.Cliente WHERE id = @id_cliente)
        BEGIN
            PRINT 'Error: El Cliente especificado no existe.';
            RETURN;
        END

        -- Validar id_medioDePago
        IF @id_medioDePago IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_venta.MedioDePago WHERE id = @id_medioDePago)
        BEGIN
            PRINT 'Error: El Medio de Pago especificado no existe.';
            RETURN;
        END

        -- Validar id_empleado
        IF @id_empleado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @id_empleado)
        BEGIN
            PRINT 'Error: El Empleado especificado no existe.';
            RETURN;
        END

        -- Validar id_sucursal
        IF @id_sucursal IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal)
        BEGIN
            PRINT 'Error: La Sucursal especificada no existe.';
            RETURN;
        END

        -- Actualizar el registro
        UPDATE gestion_venta.Factura
        SET 
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
        PRINT 'Error: No se encontró una Factura con el ID especificado.';
    END
END;
GO
IF OBJECT_ID('[gestion_venta].[Modificar_DetalleVenta]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Modificar_DetalleVenta];
GO
CREATE  PROCEDURE gestion_venta.Modificar_DetalleVenta
    @id INT,
    @id_factura CHAR(11),
    @id_producto INT = NULL,
    @cantidad INT = NULL,
    @subtotal DECIMAL(8,2) = NULL,
    @precio_unitario DECIMAL(7,2) = NULL,
    @activo BIT = NULL
AS
BEGIN
    -- Verificar si el detalle de venta existe
    IF EXISTS (SELECT 1 FROM gestion_venta.DetalleVenta WHERE id = @id AND id_factura = @id_factura)
    BEGIN
        -- Validar id_producto
        IF @id_producto IS NOT NULL AND NOT EXISTS (SELECT 1 FROM gestion_producto.Producto WHERE id = @id_producto)
        BEGIN
            PRINT 'Error: El Producto especificado no existe.';
            RETURN;
        END

        -- Validar id_factura
        IF NOT EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = @id_factura)
        BEGIN
            PRINT 'Error: La Factura especificada no existe.';
            RETURN;
        END

        -- Validar cantidad
        IF @cantidad IS NOT NULL AND @cantidad <= 0
        BEGIN
            PRINT 'Error: La cantidad debe ser mayor a 0.';
            RETURN;
        END

        -- Validar subtotal
        IF @subtotal IS NOT NULL AND @subtotal <= 0
        BEGIN
            PRINT 'Error: El subtotal debe ser mayor a 0.';
            RETURN;
        END

        -- Validar precio unitario
        IF @precio_unitario IS NOT NULL AND @precio_unitario <= 0
        BEGIN
            PRINT 'Error: El precio unitario debe ser mayor a 0.';
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
        PRINT 'Error: No se encontró un Detalle de Venta con el ID y Factura especificados.';
    END
END;
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
