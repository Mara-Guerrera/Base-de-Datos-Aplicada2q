/*Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.*/

USE Com5600G05
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

--Se crea porque la tabla tipo_comprobante no tenia datos
INSERT INTO gestion_venta.tipo_comprobante (nombre)
VALUES 
('NC')


--Invocación a SP de registrar devolucion--
DECLARE @precio_producto DECIMAL(7,2)
SELECT @precio_producto = precio
FROM gestion_producto.Producto WHERE id = 3
EXEC gestion_venta.RegistrarDevolucion 4,1, 1, 'A pedido de usuario',9


--Invocación a SP de generar nota de crédito--
DECLARE @precio_producto DECIMAL(7,2)
SELECT @precio_producto = precio
FROM gestion_producto.Producto WHERE id = 3
EXEC gestion_venta.Generar_Nota_Credito 4,1, 1, 2, 'A pedido de usuario',9

--Invocación a SP de generar detalle nota de crédito--
DECLARE @precio_producto DECIMAL(7,2)
SELECT @precio_producto = precio
FROM gestion_producto.Producto WHERE id = 3 
EXEC gestion_venta.Insertar_Detalle_Nota 1,10, 1, 19.00



--CASO ERROR: ya existe detalle nota de credito para ese producto
DECLARE @precio_producto DECIMAL(7,2)
SELECT @precio_producto = precio
FROM gestion_producto.Producto WHERE id = 3 
EXEC gestion_venta.Insertar_Detalle_Nota 1,10, 1, 20.00

--CASO ERROR: no existe nota de credito
DECLARE @precio_producto DECIMAL(7,2)
SELECT @precio_producto = precio
FROM gestion_producto.Producto WHERE id = 3 
EXEC gestion_venta.Insertar_Detalle_Nota 10000, 1, 1, 19.00


--CASO ERROR: no es supervisor
DECLARE @precio_producto DECIMAL(7,2)
SELECT @precio_producto = precio
FROM gestion_producto.Producto WHERE id = 3
EXEC gestion_venta.Generar_Nota_Credito 4,1, 1, 2, 'A pedido de usuario',1



/*
select * from gestion_venta.Factura
SELECT * FROM gestion_venta.DetalleVenta 
SELECT * FROM gestion_venta.NotaCredito 
SELECT * FROM [gestion_venta].[Detalle_Nota]
*/ 
