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

ENTREGA 5:

Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.
*/
-- ============================ LOTE POSTERIOR A IMPORTACION ============================
USE Com5600G05
GO

--Muestro el rol actual--
SELECT 
    dp.name AS RoleName
FROM 
    sys.database_role_members drm
JOIN 
    sys.database_principals dp 
    ON drm.role_principal_id = dp.principal_id
WHERE 
    drm.member_principal_id = USER_ID();

SELECT dp.name AS Supervisor, 
       dp2.name AS Grupo5
FROM   sys.database_role_members drm
       JOIN sys.database_principals dp 
       ON drm.role_principal_id = dp.principal_id
       JOIN sys.database_principals dp2
       ON drm.member_principal_id = dp2.principal_id
WHERE  dp2.name = 'Grupo5';

-- ============================ LOTE DE PRUEBAS DE SP PARA NOTA DE CREDITO ============================

DECLARE @id_producto INT
DECLARE @cantidad INT
DECLARE @precio_producto DECIMAL(7,2)
DECLARE @cantidad_modificada INT

--Invocación a SP de generar nota de crédito--
EXEC gestion_venta.Generar_Nota_Credito 4,2,1,2,'Anulación de la operación',8
GO

--Invocación a SP de generar detalle nota de crédito--
SELECT @id_producto = id_producto, @cantidad = cantidad,@precio_producto = precio_unitario
FROM gestion_venta.DetalleVenta WHERE id_factura = 4
GO
PRINT 'Producto que aparece en la factura: ' + CAST(@id_producto AS CHAR(4));
GO

-- ============================ PRUEBA DE ERRORES ============================

--Cantidad mayor a la del detalle de la venta--
SET @cantidad_modificada = @cantidad + 1
EXEC gestion_venta.Insertar_Detalle_Nota 1,@id_producto, @cantidad_modificada, @precio_producto
GO

--Valor de crédito igual a 0--
EXEC gestion_venta.Insertar_Detalle_Nota 1,@id_producto, @cantidad_modificada, 0
GO

--Producto que no existe--
EXEC gestion_venta.Insertar_Detalle_Nota 1,6000, @cantidad_modificada, @precio_producto
GO

--Producto que no aparece en la factura--
EXEC gestion_venta.Insertar_Detalle_Nota 1,1000, @cantidad_modificada, @precio_producto
GO

--CASO ERROR: ya existe detalle nota de credito para ese producto
SELECT @precio_producto = precio
FROM gestion_producto.Producto WHERE id = @id_producto
EXEC gestion_venta.Insertar_Detalle_Nota 1,@id_producto, 1, 20.00
GO

--CASO ERROR: no existe nota de credito
SELECT @precio_producto = precio
FROM gestion_producto.Producto WHERE id = 3 
EXEC gestion_venta.Insertar_Detalle_Nota 10000, 1, 1, 19.00
GO
--CASO ERROR: no es supervisor
SELECT @precio_producto = precio
FROM gestion_producto.Producto WHERE id = 3
EXEC gestion_venta.Generar_Nota_Credito 4, 1, 1, 2, 'A pedido de usuario',1
GO
--Inserción exitosa--
EXEC gestion_venta.Insertar_Detalle_Nota 1,@id_producto,@cantidad,@precio_producto
GO
/*
SELECT * from gestion_venta.Factura
GO
SELECT * FROM gestion_producto.Producto
GO
SELECT * FROM gestion_venta.DetalleVenta 
GO
SELECT * FROM gestion_sucursal.Empleado
GO
SELECT * FROM gestion_sucursal.Cargo
GO
SELECT * FROM gestion_sucursal.Sucursal
GO
SELECT * FROM gestion_venta.NotaCredito 
GO
DELETE FROM gestion_venta.NotaCredito
GO
SELECT * FROM [gestion_venta].[Detalle_Nota]
GO
*/ 
