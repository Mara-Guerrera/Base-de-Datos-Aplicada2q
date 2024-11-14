--Inserción de empleado--
--Pruebas de validación--
EXEC gestion_sucursal.Insertar_Empleado NULL,'Juan', 'Perez', 12345678, 'Calle Falsa 123', 
	'27-28033514-8', 
	'juan.perez@mail.com', 
    'juan.perez@empresa.com', 1, 1, 1;

EXEC gestion_sucursal.Insertar_Empleado 1,'Juan', 'Perez', 12345678, 'Calle Falsa 123', 
	'20-123456789', 
	'juan.perez@mail.com', 
    'juan.perez@empresa.com', 1, 1, 1;

EXEC gestion_sucursal.Insertar_Empleado 1,'Juan', 'Perez', 12345678, 'Calle Falsa 123', 
	'27-28033514-8', 
	'juan.perez@mail', 
    'juan.perez@empresa.com', 1, 1, 1;

EXEC gestion_sucursal.Insertar_Empleado 1,'Juan', 'Perez', 12345678, 'Calle Falsa 123', 
	'27-28033514-8', 
	'juan.perez@mail', 
    'juan.perez@empresa.com', 1, 10, 1;
--Inserción exitosa
EXEC gestion_sucursal.Insertar_Empleado 204517,'María','Maggio',45289653,'Av. Mayo 1050','27-28033514-8',
'maria@gmail.com','maria_trabajo@empresa.com',1,1,1

EXEC gestion_sucursal.Insertar_Empleado 257034,'Romina Natalia','PADILLA',38974125,'Lacroze 5910 , Chilavert , Buenos Aires',NULL,
'Romina	Natalia_PADILLA@gmail.com','Romina	Natalia.PADILLA@superA.com',2,2,1
--Inserción de líneas de productos--
EXEC gestion_producto.Insertar_Tipo_Producto 'Especias'
EXEC gestion_producto.Insertar_Tipo_Producto 'Bazar'
--Inserción de categorías--

--Intento de inserción de producto que ya existe (dentro de una misma línea)
EXEC gestion_producto.Insertar_Categoria 'aceite_vinagre_y_sal',1
--Inserción de producto cuyo nombre ya existe, pero en otra línea de producto (lo consideramos válido)
EXEC gestion_producto.Insertar_Categoria 'aceite_vinagre_y_sal',2
--Caso donde existe el producto pero sin línea asociada, por lo que se le asigna la que va por parámetro
EXEC gestion_producto.Insertar_Categoria 'Lácteos',3
EXEC gestion_producto.Insertar_Categoria 'Bebidas',1
EXEC gestion_producto.Insertar_Categoria 'Electrónicos',NULL

--Consultas comentadas para verificaciones--
/*SELECT * FROM gestion_sucursal.Cargo
SELECT * FROM gestion_sucursal.Sucursal
SELECT * FROM gestion_sucursal.Empleado
SELECT * FROM gestion_producto.Categoria
SELECT * FROM gestion_producto.TipoProducto
SELECT * FROM gestion_producto.Producto
SELECT * FROM gestion_venta.MedioDePago*/