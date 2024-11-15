-- ============================ STORE PROCEDURES BORRADO ============================
USE Com5600G05
GO
-- ============================ SP BORRADO GESTION_SUCURSAL ============================
	
IF OBJECT_ID('[gestion_sucursal].[Borrar_Sucursal]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Sucursal];
GO
CREATE PROCEDURE gestion_sucursal.Borrar_Sucursal
	@sucursalID INT
AS
BEGIN
	-- Si la sucursal existe y esta activa
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @sucursalID AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Empleado
		SET activo = 0
		WHERE id_sucursal = @sucursalID

		UPDATE gestion_sucursal.Sucursal
		SET activo = 0
		WHERE id = @sucursalID
		
		PRINT 'La sucursal con ID ' + CAST(@sucursalID AS VARCHAR) + ' fue dada de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('La sucursal con ID %d no existe o ya fue dada de baja.', 16, 1, @sucursalID);
	END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_Turno]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Turno];
GO
CREATE PROCEDURE gestion_sucursal.Borrar_Turno
	@turnoID INT
AS
BEGIN
	-- Si el turno existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Turno WHERE id = @turnoID AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Turno
		SET activo = 0
		WHERE id = @turnoID;

		PRINT 'El turno con ID ' + CAST(@turnoID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El turno con ID %d no existe o ya fue dado de baja.', 16, 1, @turnoID);
	END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_Cargo]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Cargo];
GO
CREATE PROCEDURE gestion_sucursal.Borrar_Cargo
	@cargoID INT
AS
BEGIN
	-- Si el cargo existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Cargo WHERE id = @cargoID AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Cargo
		SET activo = 0
		WHERE id = @cargoID;

		PRINT 'El cargo con ID ' + CAST(@cargoID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El cargo con ID %d no existe o ya fue dado de baja.', 16, 1, @cargoID);
	END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_Empleado]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Empleado];
GO
CREATE PROCEDURE gestion_sucursal.Borrar_Empleado
	@empleadoID INT
AS
BEGIN
	-- Si el empleado existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @empleadoID AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Empleado
		SET activo = 0
		WHERE id = @empleadoID;

		PRINT 'El empleado con ID ' + CAST(@empleadoID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El empleado con ID %d no existe o ya fue dado de baja.', 16, 1, @empleadoID);
    END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_TipoCliente]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_TipoCliente];
GO
CREATE PROCEDURE gestion_sucursal.Borrar_TipoCliente
	@tipoClienteID INT
AS
BEGIN
    -- Si el tipo de cliente existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE id = @tipoClienteID AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.TipoCliente
		SET activo = 0
		WHERE id = @tipoClienteID;

		PRINT 'El tipo de cliente con ID ' + CAST(@tipoClienteID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El tipo de cliente con ID %d no existe o ya fue dado de baja.', 16, 1, @tipoClienteID);
	END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_Genero]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Genero];
GO
CREATE PROCEDURE gestion_sucursal.Borrar_Genero
	@generoID INT
AS
BEGIN
	-- Si el genero existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE id = @generoID AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Genero
		SET activo = 0
		WHERE id = @generoID;

		PRINT 'El genero con ID ' + CAST(@generoID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El genero con ID %d no existe o ya fue dado de baja.', 16, 1, @generoID);
	END
END
GO

IF OBJECT_ID('[gestion_sucursal].[Borrar_Cliente]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_sucursal].[Borrar_Cliente];
GO
CREATE PROCEDURE gestion_sucursal.Borrar_Cliente
	@clienteID INT
AS
BEGIN
    -- Si el cliente existe y esta activo
	IF EXISTS (SELECT 1FROM gestion_sucursal.Cliente WHERE id = @clienteID AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Cliente
		SET activo = 0
		WHERE id = @clienteID;

		PRINT 'El cliente con ID ' + CAST(@clienteID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El cliente con ID %d no existe o ya fue dado de baja.', 16, 1, @clienteID);
	END
END
GO

-- ============================ SP BORRADO GESTION_PRODUCTO ============================
		
IF OBJECT_ID('[gestion_producto].[Borrar_Proveedor]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Borrar_Proveedor];
GO
CREATE PROCEDURE gestion_producto.Borrar_Proveedor
	@proveedorID INT
AS
BEGIN
	-- Si el proveedor existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_producto.Proveedor WHERE id = @proveedorID AND activo = 1)
	BEGIN
		UPDATE gestion_producto.Proveedor
		SET activo = 0
		WHERE id = @proveedorID;

		PRINT 'El proveedor con ID ' + CAST(@proveedorID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El proveedor con ID %d no existe o ya fue dado de baja.', 16, 1, @proveedorID);
	END
END
GO

IF OBJECT_ID('[gestion_producto].[Borrar_TipoProducto]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Borrar_TipoProducto];
GO
CREATE PROCEDURE gestion_producto.Borrar_TipoProducto
	@tipoProductoID INT
AS
BEGIN
	-- Si el tipo de producto existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_producto.TipoProducto WHERE id = @tipoProductoID AND activo = 1)
	BEGIN
	-- Inactivo a todas las categorias del tipoProductoID
		UPDATE gestion_producto.Categoria
		SET activo = 0
		WHERE id_tipoProducto = @tipoProductoID;

	-- Inactivo al tipoProductoID
		UPDATE gestion_producto.TipoProducto
		SET activo = 0
		WHERE id = @tipoProductoID;

		PRINT 'El tipo de producto con ID ' + CAST(@tipoProductoID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El tipo de producto con ID %d no existe o ya fue dado de baja.', 16, 1, @tipoProductoID);
	END
END
GO
	
IF OBJECT_ID('[gestion_producto].[Borrar_Categoria]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Borrar_Categoria];
GO
CREATE PROCEDURE gestion_producto.Borrar_Categoria
	@categoriaID INT
AS
BEGIN
    -- Si la categoria existe y esta activa
	IF EXISTS (SELECT 1 FROM gestion_producto.Categoria WHERE id = @categoriaID AND activo = 1)
	BEGIN
	-- Inactivo a todos los productos de categoriaID
		UPDATE gestion_producto.Producto
		SET activo = 0
		WHERE id_categoria = @categoriaID;

	-- Inactivo la categoriaID
		UPDATE gestion_producto.Categoria
		SET activo = 0
		WHERE id = @categoriaID;

		PRINT 'La categoria con ID ' + CAST(@categoriaID AS VARCHAR) + ' fue dada de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('La categoria con ID %d no existe o ya fue dada de baja.', 16, 1, @categoriaID);
    END
END
GO

IF OBJECT_ID('[gestion_producto].[Borrar_Producto]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_producto].[Borrar_Producto];
GO
CREATE PROCEDURE gestion_producto.Borrar_Producto
	@productoID INT
AS
BEGIN
	-- Si el producto existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_producto.Producto WHERE id = @productoID AND activo = 1)
	BEGIN
		UPDATE gestion_producto.Producto
		SET activo = 0
		WHERE id = @productoID;

		PRINT 'El producto con ID ' + CAST(@productoID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El producto con ID %d no existe o ya fue dado de baja.', 16, 1, @productoID);
    END
END
GO

-- ============================ SP BORRADO GESTION_VENTA ============================

IF OBJECT_ID('[gestion_venta].[Borrar_MedioDePago]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Borrar_MedioDePago];
GO
CREATE PROCEDURE gestion_venta.Borrar_MedioDePago
	@medioDePagoID INT
AS
BEGIN
    -- Si el medio de pago existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_venta.MedioDePago WHERE id = @medioDePagoID AND activo = 1)
	BEGIN
		UPDATE gestion_venta.MedioDePago
		SET activo = 0
		WHERE id = @medioDePagoID;

		PRINT 'El medio de pago con ID ' + CAST(@medioDePagoID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El medio de pago con ID %d no existe o ya fue dado de baja.', 16, 1, @medioDePagoID);
	END
END
GO

IF OBJECT_ID('[gestion_venta].[Borrar_TipoFactura]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Borrar_TipoFactura];
GO
CREATE PROCEDURE gestion_venta.Borrar_TipoFactura
	@tipoFacturaID INT
AS
BEGIN
	-- Si el tipo de factura existe y esta activo
	IF EXISTS (SELECT 1 FROM gestion_venta.TipoFactura WHERE id = @tipoFacturaID AND activo = 1)
	BEGIN
		UPDATE gestion_venta.TipoFactura
		SET activo = 0
		WHERE id = @tipoFacturaID;

		PRINT 'El tipo de factura con ID ' + CAST(@tipoFacturaID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El tipo de factura con ID %d no existe o ya fue dado de baja.', 16, 1, @tipoFacturaID);
	END
END
GO

IF OBJECT_ID('[gestion_venta].[Borrar_Factura]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Borrar_Factura];
GO
CREATE PROCEDURE gestion_venta.Borrar_Factura
	@facturaID	INT
AS
BEGIN
	-- Si la factura existe y esta activa
	IF EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id = @facturaID AND activo = 1)
	BEGIN
	-- Inactivo todos los detalles de venta de facturaID
		UPDATE gestion_venta.DetalleVenta
		SET activo = 0 
		WHERE id_factura = @facturaID;

	-- Inactivo la facturaID
		UPDATE gestion_venta.Factura
		SET activo = 0
		WHERE id = @facturaID;

		PRINT 'La factura con ID ' + CAST(@facturaID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('La factura con ID %d no existe o ya fue dada de baja.', 16, 1, @facturaID);
	END
END
GO

IF OBJECT_ID('[gestion_venta].[Borrar_DetalleVenta]', 'P') IS NOT NULL
    DROP PROCEDURE [gestion_venta].[Borrar_DetalleVenta];
GO
CREATE PROCEDURE gestion_venta.Borrar_DetalleVenta
	@detalleVentaID		INT,
	@facturaID			INT
AS
BEGIN
	-- Si existe el detalle de venta para esa factura y esta activo
	IF EXISTS (	SELECT 1 FROM gestion_venta.DetalleVenta
				WHERE id = @detalleVentaID AND id_factura = @facturaID AND activo = 1)
	BEGIN
		UPDATE gestion_venta.DetalleVenta
		SET activo = 0
		WHERE id = @detalleVentaID AND id_factura = @facturaID;

		PRINT 'El detalle de venta con ID ' + CAST(@detalleVentaID AS VARCHAR) +
			' para la factura con ID ' + CAST(@facturaID AS VARCHAR) + ' fue dado de baja correctamente.';
	END
	ELSE
	BEGIN
		RAISERROR('El detalle de venta con ID %d no existe o ya fue dado de baja.', 16, 1, @detalleVentaID);
	END
END
GO
