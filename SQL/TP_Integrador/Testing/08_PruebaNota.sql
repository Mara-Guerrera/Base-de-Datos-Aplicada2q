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
--Invocación a SP de generar nota de crédito--
DECLARE @precio_producto DECIMAL(7,2)
SELECT @precio_producto = precio
FROM gestion_producto.Producto WHERE id = 3419 
EXEC gestion_venta.GenerarNotaCredito 10,3419,@precio_producto,1

SELECT @precio_producto = precio
FROM gestion_producto.Producto WHERE id = 2713 
EXEC gestion_venta.GenerarNotaCredito 12,2713,@precio_producto,1


/*
SELECT * FROM gestion_venta.DetalleVenta 
SELECT * FROM gestion_venta.NotaCredito 
*/ 
