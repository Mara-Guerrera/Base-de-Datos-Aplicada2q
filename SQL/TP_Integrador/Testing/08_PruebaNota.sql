/*Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el
valor del producto o un producto del mismo tipo.
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso
para generarla.
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada.
Asigne los roles correspondientes para poder cumplir con este requisito.
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.*/

USE Com5600G05
SELECT * FROM gestion_venta.DetalleVenta
SELECT * FROM gestion_venta.Factura



/*
SELECT * FROM gestion_venta.Factura
SELECT * FROM gestion_venta.DetalleVenta

SELECT c.id, nombre, apellido, g.descripcion, tc.descripcion
FROM gestion_sucursal.Cliente c INNER JOIN gestion_sucursal.Genero g ON c.id_genero = g.id
INNER JOIN gestion_sucursal.TipoCliente tc ON c.id_tipo = tc.id 
