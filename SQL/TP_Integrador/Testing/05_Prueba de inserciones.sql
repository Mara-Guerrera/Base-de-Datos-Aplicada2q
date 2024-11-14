--Inserci�n de empleado--
USE Com5600G05
GO
EXEC gestion_sucursal.Insertar_Empleado 204517,'Mar�a','Maggio',45289653,'Av. Mayo 1050','27-28033514-8',
'maria@gmail.com','maria_trabajo@empresa.com',1,1,1

--Inserci�n de l�neas de productos--
EXEC gestion_producto.Insertar_Tipo_Producto 'Especias'
--Inserci�n de categor�as--

--Inserci�n de categor�a cuyo nombre ya existe, pero en otra l�nea de producto (lo consideramos v�lido)
EXEC gestion_producto.Insertar_Categoria 'aceite_vinagre_y_sal',2
--Caso donde existe el producto pero sin l�nea asociada, por lo que se le asigna la que va por par�metro
EXEC gestion_producto.Insertar_Categoria 'L�cteos',3
EXEC gestion_producto.Insertar_Categoria 'Bebidas',1

EXEC gestion_venta.Insertar_TipoFactura 'D'
EXEC gestion_sucursal.Insertar_Genero 'Otro'
EXEC gestion_producto.Insertar_Proveedor 'Proveedur�a Delta'

--Pruebas de inserci�n de producto, con obtenci�n de id para posterior actualizaci�n--
EXEC gestion_producto.Insertar_Producto 'Queso de cabra curado',12.50,48,25,kg,null,3
SELECT * FROM gestion_producto.Producto
WHERE descripcion = 'Queso de cabra curado';
DECLARE @id INT
EXEC gestion_producto.Obtener_Id_Producto 
    @nombreProducto = 'Queso de cabra curado', 
    @id = @id OUTPUT;
EXEC gestion_producto.Modificar_Producto @id,@precio = 15.6, @precio_ref = 30

SELECT * FROM gestion_producto.Producto 
WHERE id = @id


--Consultas comentadas para verificaciones--
/*SELECT * FROM gestion_sucursal.Cargo
SELECT * FROM gestion_sucursal.Sucursal
SELECT * FROM gestion_sucursal.Empleado
SELECT * FROM gestion_producto.Categoria
WHERE nombre LIKE 'queso' + '%'
SELECT * FROM gestion_producto.TipoProducto
SELECT * FROM gestion_producto.Proveedor
SELECT * FROM gestion_producto.Producto
WHERE descripcion = 'Queso de cabra curado'
SELECT * FROM gestion_venta.MedioDePago*/