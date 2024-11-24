-- ============================ LOTE DE PRUEBAS DE STORED PROCEDURES ============================
USE Com5600G05
GO
-- ============================ LOTE DE BORRADO POSTERIOR A IMPORTACION ============================

--Caso Error: no existe Sucursal
EXEC [gestion_sucursal].Borrar_Sucursal 9
GO

--Borrar Tipo de Producto
EXEC [gestion_producto].Borrar_TipoProducto 1
GO

--Borrar Empleado
EXEC [gestion_sucursal].Borrar_Empleado 1
GO
--Borrar Producto
EXEC [gestion_producto].Borrar_Producto 2
GO
--Caso Error: no existe Medio De Pago
EXEC gestion_venta.Borrar_MedioDePago 10
GO
--Borrar Cliente
EXEC gestion_sucursal.Borrar_Cliente 1
GO

