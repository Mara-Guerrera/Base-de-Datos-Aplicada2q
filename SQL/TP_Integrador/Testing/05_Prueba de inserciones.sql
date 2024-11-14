--Inserción de empleado--
USE Com5600G05
GO
EXEC gestion_sucursal.Insertar_Empleado 204517,'María','Maggio',45289653,'Av. Mayo 1050','27-28033514-8',
'maria@gmail.com','maria_trabajo@empresa.com',1,1,1

--Inserción de líneas de productos--
EXEC gestion_producto.Insertar_Tipo_Producto 'Especias'
--Inserción de categorías--

--Inserción de categoría cuyo nombre ya existe, pero en otra línea de producto (lo consideramos válido)
EXEC gestion_producto.Insertar_Categoria 'aceite_vinagre_y_sal',2
--Caso donde existe el producto pero sin línea asociada, por lo que se le asigna la que va por parámetro
EXEC gestion_producto.Insertar_Categoria 'Lácteos',3
EXEC gestion_producto.Insertar_Categoria 'Bebidas',1

EXEC gestion_venta.Insertar_TipoFactura 'D'
EXEC gestion_sucursal.Insertar_Genero 'Otro'
EXEC gestion_producto.Insertar_Proveedor 'Proveeduría Delta'

--Pruebas de inserción de producto, con obtención de id para posterior actualización--
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