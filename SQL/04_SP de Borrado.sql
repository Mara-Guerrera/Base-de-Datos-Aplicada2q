-- ============================ STORE PROCEDURES BORRADO ============================
USE Com5600G05
GO
-- ============================ SP BORRADO GESTION_SUCURSAL ============================

CREATE OR ALTER PROCEDURE gestion_sucursal.Borrar_Sucursal
    @sucursalID INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @sucursalID AND activo = 1)
	BEGIN
		UPDATE gestion_sucursal.Empleado
		SET activo = 0
		WHERE id_sucursal = @id_sucursal

		UPDATE gestion_sucursal.Sucursal
		SET activo = 0 WHERE id = @sucursalID
		PRINT 'La sucursal ' + CAST(@sucursalID AS VARCHAR) + ' fue dada de baja.'
	END
	ELSE
	BEGIN
		PRINT 'La sucursal no existe o ya fue dada de baja.';
	END		
END
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Borrar_Empleado
    @empleadoID INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @empleadoID AND activo = 1)
    BEGIN
        UPDATE gestion_sucursal.Empleado
        SET activo = 0
        WHERE id = @empleadoID;

        PRINT 'Empleado borrado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El empleado no existe o ya fue dado de baja.';
    END
END
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Borrar_TipoCliente
    @tipoClienteID INT
AS
BEGIN
    -- Si el tipo de cliente existe y esta activo
    IF EXISTS (SELECT 1 FROM gestion_sucursal.TipoCliente WHERE id = @tipoClienteID AND activo = 1)
    BEGIN
        UPDATE gestion_sucursal.TipoCliente
        SET activo = 0
        WHERE id = @tipoClienteID;

        PRINT 'Tipo de cliente borrado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El tipo de cliente no existe o ya fue dado de baja.';
    END
END
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Borrar_Genero
    @generoID INT
AS
BEGIN
    -- Si el genero existe y esta activo
    IF EXISTS (SELECT 1 FROM gestion_sucursal.Genero WHERE id = @generoID AND activo = 1)
    BEGIN
        UPDATE gestion_sucursal.Genero
        SET activo = 0
        WHERE id = @generoID;

        PRINT 'Genero borrado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El genero no existe o ya fue dado de baja.';
    END
END
GO

CREATE OR ALTER PROCEDURE gestion_sucursal.Borrar_Cliente
    @clienteID INT
AS
BEGIN
    -- Si el cliente existe y esta activo
    IF EXISTS (SELECT 1FROM gestion_sucursal.Cliente WHERE id = @clienteID AND activo = 1)
    BEGIN
        UPDATE gestion_sucursal.Cliente
        SET activo = 0
        WHERE id = @clienteID;

        PRINT 'Cliente borrado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El cliente no existe o ya fue dado de baja.';
    END
END
GO

-- ============================ SP BORRADO GESTION_PRODUCTO ============================

CREATE OR ALTER PROCEDURE gestion_producto.Borrar_TipoProducto
    @tipoProductoID INT
AS
BEGIN
    -- Si el tipo de producto existe y esta activo
    IF EXISTS (SELECT 1 FROM gestion_producto.TipoProducto WHERE id = @tipoProductoID AND activo = 1)
    BEGIN
	-- Inactivo a todas la categorias del tipoProductoID
		UPDATE gestion_producto.Categoria
        SET activo = 0
        WHERE id_tipoProducto = @tipoProductoID;

        UPDATE gestion_producto.TipoProducto
        SET activo = 0
        WHERE id = @tipoProductoID;

        PRINT 'Tipo de producto borrado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El tipo de producto no existe o ya esta dado de baja.';
    END
END
GO

CREATE OR ALTER PROCEDURE gestion_producto.Borrar_Categoria
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

        UPDATE gestion_producto.Categoria
        SET activo = 0
        WHERE id = @categoriaID;

        PRINT 'Categoria borrada correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'La categoria no existe o ya esta dada de baja.';
    END
END
GO

CREATE OR ALTER PROCEDURE gestion_producto.Borrar_Producto
    @productoID INT
AS
BEGIN
    -- Si el producto existe y esta activo
    IF EXISTS (SELECT 1 FROM gestion_producto.Producto WHERE id = @productoID AND activo = 1)
    BEGIN
        UPDATE gestion_producto.Producto
        SET activo = 0
        WHERE id = @productoID;

        PRINT 'Producto borrado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El producto no existe o ya fue eliminado.';
    END
END
GO

-- ============================ SP BORRADO GESTION_VENTA ============================

CREATE OR ALTER PROCEDURE gestion_venta.Borrar_MedioDePago
    @medioDePagoID INT
AS
BEGIN
    -- Si el medio de pago existe y esta activo
    IF EXISTS (SELECT 1 FROM gestion_venta.MedioDePago WHERE id = @medioDePagoID AND activo = 1)
    BEGIN
        UPDATE gestion_venta.MedioDePago
        SET activo = 0
        WHERE id = @medioDePagoID;

        PRINT 'Medio de pago borrado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El medio de pago no existe o ya esta inactivo.';
    END
END
GO

CREATE OR ALTER PROCEDURE gestion_venta.Borrar_TipoFactura
    @tipoFacturaID INT
AS
BEGIN
    -- Si el tipo de factura existe y esta activo
    IF EXISTS (SELECT 1 FROM gestion_venta.TipoFactura WHERE id = @tipoFacturaID AND activo = 1)
    BEGIN
        UPDATE gestion_venta.TipoFactura
        SET activo = 0
        WHERE id = @tipoFacturaID;

        PRINT 'Tipo de factura borrado correctamente.';
    END
    ELSE
    BEGIN
        PRINT 'El tipo de factura no existe o ya esta inactivo.';
    END
END
GO

CREATE OR ALTER PROCEDURE gestion_venta.Borrar_Factura
    @facturaID CHAR(11)
AS
BEGIN
    -- Si la factura existe y esta activa
    IF EXISTS (SELECT 1 FROM gestion_venta.Factura WHERE id_factura = @facturaID AND activo = 1)
    BEGIN
	-- Inactivo todos los detalles de venta de facturaID
		UPDATE gestion_venta.DetalleVenta
		SET activo = 0 
		WHERE id_factura = @facturaID;

        UPDATE gestion_venta.Factura
        SET activo = 0
        WHERE id_factura = @facturaID;

        PRINT 'Factura borrada correctamente.';
    END
    ELSE
	BEGIN
        PRINT 'La factura no existe.';
	END
END
GO

CREATE OR ALTER PROCEDURE gestion_venta.Borrar_DetalleVenta
    @detalleVentaID INT,
    @facturaID CHAR(11)
AS
BEGIN
    IF EXISTS (	SELECT 1 FROM gestion_venta.DetalleVenta
				WHERE id = @detalleVentaID AND id_factura = @facturaID AND activo = 1 )
    BEGIN
        UPDATE gestion_venta.DetalleVenta
        SET activo = 0
        WHERE id = @detalleVentaID AND id_factura = @facturaID;

        PRINT 'Detalle de venta borrado correctamente.';
    END
    ELSE
	BEGIN
        PRINT 'El detalle de venta no existe o ya fue eliminado.';
	END
END
GO
