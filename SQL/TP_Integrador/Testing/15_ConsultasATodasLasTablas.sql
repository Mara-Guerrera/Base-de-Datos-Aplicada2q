USE Com5600G05
GO
-- ================== CONSULTAS A TODAS LAS TABLAS ==================

--Gesti�n sucursal--
SELECT * FROM gestion_sucursal.Cargo
SELECT * FROM gestion_sucursal.Sucursal
SELECT * FROM gestion_sucursal.Empleado
SELECT * FROM gestion_sucursal.Turno
SELECT * FROM gestion_sucursal.TipoCliente
SELECT * FROM gestion_sucursal.Genero
SELECT * FROM gestion_sucursal.Empresa
SELECT * FROM gestion_sucursal.Empleado

--Gesti�n venta--
SELECT * FROM gestion_venta.MedioDePago
SELECT * FROM gestion_venta.Factura
SELECT * FROM gestion_venta.DetalleVenta
SELECT * FROM gestion_venta.TipoFactura

--Gesti�n producto--
SELECT * FROM gestion_producto.Categoria
SELECT * FROM gestion_producto.TipoProducto
SELECT * FROM gestion_producto.Producto
SELECT * FROM gestion_producto.Proveedor

--Ejecutar luego de ejecutar 13_CreacionTablaSPNotaDeCredito--
SELECT * FROM gestion_venta.NotaCredito 
SELECT * FROM gestion_venta.DetalleNota
SELECT * FROM gestion_venta.TipoComprobante