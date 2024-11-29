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
-- ============================ STORED PROCEDURES BORRADO ============================
USE Com5600G05
GO
-- ============================ SP BORRADO GESTION_SUCURSAL ============================
	
IF OBJECT_ID('[gestion_sucursal].[Borrar_Sucursal]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Sucursal];
GO

CREATE PROCEDURE gestion_sucursal.Borrar_Sucursal
	@id_sucursal INT
AS
BEGIN
	IF @id_sucursal IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID de la sucursal.', 16, 1);
		RETURN;
	END
	-- Si la sucursal existe y esta activa
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Empleado
		SET activo = 0
		WHERE id_sucursal = @id_sucursal

		UPDATE gestion_sucursal.Sucursal
		SET activo = 0
		WHERE id = @id_sucursal
		
		PRINT 'La sucursal con ID ' + CAST(@id_sucursal AS VARCHAR) + ' fue dada de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: La sucursal con ID %d no existe o ya fue dada de baja.', 16, 1, @id_sucursal);
	END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_Turno]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Turno];
GO

CREATE PROCEDURE gestion_sucursal.Borrar_Turno
	@id_turno INT
AS
BEGIN
	IF @id_turno IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del turno.', 16, 1);
		RETURN;
	END

	-- Si el turno existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Turno WHERE id = @id_turno AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Turno
		SET activo = 0
		WHERE id = @id_turno;

		PRINT 'El turno con ID ' + CAST(@id_turno AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El turno con ID %d no existe o ya fue dado de baja.', 16, 1, @id_turno);
	END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_Cargo]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Cargo];
GO

CREATE PROCEDURE gestion_sucursal.Borrar_Cargo
	@id_cargo INT
AS
BEGIN
	IF @id_cargo IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del cargo.', 16, 1);
		RETURN;
	END

	-- Si el cargo existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Cargo WHERE id = @id_cargo AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Cargo
		SET activo = 0
		WHERE id = @id_cargo;

		PRINT 'El cargo con ID ' + CAST(@id_cargo AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El cargo con ID %d no existe o ya fue dado de baja.', 16, 1, @id_cargo);
	END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_Empleado]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Empleado];
GO

CREATE PROCEDURE gestion_sucursal.Borrar_Empleado
	@id_empleado INT
AS
BEGIN
	IF @id_empleado IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del empleado.', 16, 1);
		RETURN;
	END

	-- Si el empleado existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @id_empleado AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Empleado
		SET activo = 0
		WHERE id = @id_empleado;

		PRINT 'El empleado con ID ' + CAST(@id_empleado AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El empleado con ID %d no existe o ya fue dado de baja.', 16, 1, @id_empleado);
    END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_TipoCliente]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_TipoCliente];
GO

CREATE PROCEDURE gestion_sucursal.Borrar_TipoCliente
	@id_tipoCliente INT
AS
BEGIN
	IF @id_tipoCliente IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del Tipo de cliente.', 16, 1);
		RETURN;
	END

    -- Si el tipo de cliente existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE id = @id_tipoCliente AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.TipoCliente
		SET activo = 0
		WHERE id = @id_tipoCliente;

		PRINT 'El tipo de cliente con ID ' + CAST(@id_tipoCliente AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El tipo de cliente con ID %d no existe o ya fue dado de baja.', 16, 1, @id_tipoCliente);
	END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_Genero]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Genero];
GO

CREATE PROCEDURE gestion_sucursal.Borrar_Genero
	@id_genero INT
AS
BEGIN
	IF @id_genero IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del género.', 16, 1);
		RETURN;
	END

	-- Si el genero existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE id = @id_genero AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Genero
		SET activo = 0
		WHERE id = @id_genero;

		PRINT 'El genero con ID ' + CAST(@id_genero AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El genero con ID %d no existe o ya fue dado de baja.', 16, 1, @id_genero);
	END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_Cliente]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Cliente];
GO

CREATE PROCEDURE gestion_sucursal.Borrar_Cliente
	@id_cliente INT
AS
BEGIN
	IF @id_cliente IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del cliente.', 16, 1);
		RETURN;
	END

    -- Si el cliente existe y esta activo
	IF EXISTS (SELECT 1FROM gestion_sucursal.Cliente WHERE id = @id_cliente AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Cliente
		SET activo = 0
		WHERE id = @id_cliente;

		PRINT 'El cliente con ID ' + CAST(@id_cliente AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El cliente con ID %d no existe o ya fue dado de baja.', 16, 1, @id_cliente);
	END
END
GO

-- ============================ SP BORRADO GESTION_PRODUCTO ============================
		
IF OBJECT_ID('[gestion_producto].[Borrar_Proveedor]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Borrar_Proveedor];
GO

CREATE PROCEDURE gestion_producto.Borrar_Proveedor
	@id_proveedor INT
AS
BEGIN
	IF @id_proveedor IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del proveedor.', 16, 1);
		RETURN;
	END

	-- Si el proveedor existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE id = @id_proveedor AND activo = 1)
	BEGIN
		UPDATE gestion_producto.Proveedor
		SET activo = 0
		WHERE id = @id_proveedor;

		PRINT 'El proveedor con ID ' + CAST(@id_proveedor AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El proveedor con ID %d no existe o ya fue dado de baja.', 16, 1, @id_proveedor);
	END
END
GO

IF OBJECT_ID('[gestion_producto].[Borrar_TipoProducto]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Borrar_TipoProducto];
GO

CREATE PROCEDURE gestion_producto.Borrar_TipoProducto
	@id_tipoProducto INT
AS
BEGIN
	IF @id_tipoProducto IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del Tipo de producto.', 16, 1);
		RETURN;
	END

	-- Si el tipo de producto existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_producto.TipoProducto WHERE id = @id_tipoProducto AND activo = 1)
	BEGIN
	-- Inactivo a todas las categorias del tipo de producto
		UPDATE gestion_producto.Categoria
		SET activo = 0
		WHERE id_tipoProducto = @id_tipoProducto;

	-- Inactivo al tipo de producto
		UPDATE gestion_producto.TipoProducto
		SET activo = 0
		WHERE id = @id_tipoProducto;

		PRINT 'El tipo de producto con ID ' + CAST(@id_tipoProducto AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El tipo de producto con ID %d no existe o ya fue dado de baja.', 16, 1, @id_tipoProducto);
	END
END
GO
	
IF OBJECT_ID('[gestion_producto].[Borrar_Categoria]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Borrar_Categoria];
GO

CREATE PROCEDURE gestion_producto.Borrar_Categoria
	@id_categoria INT
AS
BEGIN
	IF @id_categoria IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID de la categoría.', 16, 1);
		RETURN;
	END

    -- Si la categoria existe y esta activa
	IF EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE id = @id_categoria AND activo = 1)
	BEGIN
	-- Inactivo a todos los productos de categoria
		UPDATE gestion_producto.Producto
		SET activo = 0
		WHERE id_categoria = @id_categoria;

	-- Inactivo la categoria
		UPDATE gestion_producto.Categoria
		SET activo = 0
		WHERE id = @id_categoria;

		PRINT 'La categoria con ID ' + CAST(@id_categoria AS VARCHAR) + ' fue dada de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: La categoria con ID %d no existe o ya fue dada de baja.', 16, 1, @id_categoria);
    END
END
GO

IF OBJECT_ID('[gestion_producto].[Borrar_Producto]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Borrar_Producto];
GO

CREATE PROCEDURE gestion_producto.Borrar_Producto
	@id_producto INT
AS
BEGIN
	IF @id_producto IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del producto.', 16, 1);
		RETURN;
	END

	-- Si el producto existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_producto.Producto WHERE id = @id_producto AND activo = 1)
	BEGIN
		UPDATE gestion_producto.Producto
		SET activo = 0
		WHERE id = @id_producto;

		PRINT 'El producto con ID ' + CAST(@id_producto AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El producto con ID %d no existe o ya fue dado de baja.', 16, 1, @id_producto);
    END
END
GO

-- ============================ SP BORRADO GESTION_VENTA ============================

IF OBJECT_ID('[gestion_venta].[Borrar_MedioDePago]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Borrar_MedioDePago];
GO

CREATE PROCEDURE gestion_venta.Borrar_MedioDePago
	@id_medioDePago INT
AS
BEGIN
	IF @id_medioDePago IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del Medio de pago.', 16, 1);
		RETURN;
	END

    -- Si el medio de pago existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_venta.MedioDePago WHERE id = @id_medioDePago AND activo = 1)
	BEGIN
		UPDATE gestion_venta.MedioDePago
		SET activo = 0
		WHERE id = @id_medioDePago;

		PRINT 'El medio de pago con ID ' + CAST(@id_medioDePago AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El medio de pago con ID %d no existe o ya fue dado de baja.', 16, 1, @id_medioDePago);
	END
END
GO

IF OBJECT_ID('[gestion_venta].[Borrar_TipoFactura]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Borrar_TipoFactura];
GO

CREATE PROCEDURE gestion_venta.Borrar_TipoFactura
	@id_tipoFactura INT
AS
BEGIN
	IF @id_tipoFactura IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del Tipo de factura.', 16, 1);
		RETURN;
	END

	-- Si el tipo de factura existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_venta.TipoFactura WHERE id = @id_tipoFactura AND activo = 1)
	BEGIN
		UPDATE gestion_venta.TipoFactura
		SET activo = 0
		WHERE id = @id_tipoFactura;

		PRINT 'El tipo de factura con ID ' + CAST(@id_tipoFactura AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El tipo de factura con ID %d no existe o ya fue dado de baja.', 16, 1, @id_tipoFactura);
	END
END
GO

IF OBJECT_ID('[gestion_venta].[Borrar_Factura]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Borrar_Factura];
GO
CREATE PROCEDURE gestion_venta.Borrar_Factura
	@id_factura	INT
AS
BEGIN
	IF @id_factura IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID de la factura.', 16, 1);
		RETURN;
	END

	-- Si la factura existe y esta activa
	IF EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = @id_factura AND activo = 1)
	BEGIN
	-- Inactivo todos los detalles de venta de la factura
		UPDATE gestion_venta.DetalleVenta
		SET activo = 0 
		WHERE id_factura = @id_factura;

	-- Inactivo la factura
		UPDATE gestion_venta.Factura
		SET activo = 0
		WHERE id = @id_factura;

		PRINT 'La factura con ID ' + CAST(@id_factura AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: La factura con ID %d no existe o ya fue dada de baja.', 16, 1, @id_factura);
	END
END
GO

IF OBJECT_ID('[gestion_venta].[Borrar_DetalleVenta]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Borrar_DetalleVenta];
GO

CREATE PROCEDURE gestion_venta.Borrar_DetalleVenta
	@id_detalleVenta INT,
	@id_factura	INT
AS
BEGIN
	IF @id_detalleVenta IS NULL AND @id_factura IS NULL
	BEGIN
		RAISERROR('Error: Debe ingresar el ID del detalle de venta y el ID de la factura.', 16, 1);
		RETURN;
	END

	-- Si existe el detalle de venta para esa factura y esta activo
	IF EXISTS (	SELECT 1 FROM gestion_venta.DetalleVenta
				WHERE id = @id_detalleVenta AND id_factura = @id_factura AND activo = 1)
	BEGIN
		UPDATE gestion_venta.DetalleVenta
		SET activo = 0
		WHERE id = @id_detalleVenta AND id_factura = @id_factura;

		PRINT 'El detalle de venta con ID ' + CAST(@id_detalleVenta AS VARCHAR) +
			' para la factura con ID ' + CAST(@id_factura AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('Error: El detalle de venta con ID %d no existe o ya fue dado de baja.', 16, 1, @id_detalleVenta);
	END
END
GO
