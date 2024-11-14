USE Com5600G05
GO

-- ERROR: Caso de sucursal que ya existe
EXEC [gestion_sucursal].Insertar_Sucursal 
    'Ramos Mejia', 
    'Av. de Mayo 791, B1704 Ramos Mejía, Provincia de Buenos Aires',
    'L a V 8 am a 8 pm.',
    '5555-5552';

-- Inserción de Turnos, Cargo y Empleados
EXEC gestion_sucursal.Insertar_Turno 'TN';
EXEC gestion_sucursal.Insertar_Cargo 'Vendedor';
EXEC gestion_sucursal.Insertar_Empleado 
    204517, 'María', 'Maggio', 45289653, 
    'Av. Mayo 1050', '27-28033514-8', 
    'maria@gmail.com', 'maria_trabajo@empresa.com', 
    1, 1, 1;

-- Inserción de líneas de productos
EXEC gestion_producto.Insertar_Tipo_Producto 'Especias';

-- Inserción de categorías
EXEC gestion_producto.Insertar_Categoria 'aceite_vinagre_y_sal', 2;
EXEC gestion_producto.Insertar_Categoria 'Lácteos', 3;
EXEC gestion_producto.Insertar_Categoria 'Bebidas', 1;

-- Inserción de tipo de factura y género
EXEC gestion_venta.Insertar_TipoFactura 'D';
EXEC gestion_sucursal.Insertar_Genero 'Otro';

-- Inserción de proveedor
EXEC gestion_producto.Insertar_Proveedor 'Proveeduría Delta';

-- Pruebas de inserción de producto, con obtención de id para posterior actualización
EXEC gestion_producto.Insertar_Producto 
    'Queso de cabra curado', 12.50, 48, 25, 'kg', NULL, 3;

-- Obtener el id del producto para actualizar
DECLARE @id INT;
EXEC gestion_producto.Obtener_Id_Producto 
    @nombreProducto = 'Queso de cabra curado', 
    @id = @id OUTPUT;

-- Modificar el producto usando el id obtenido
EXEC gestion_producto.Modificar_Producto 
    @id, @precio = 15.6, @precio_ref = 30;

-- Validar modificación
SELECT * FROM gestion_producto.Producto 
WHERE id = @id;

-- Obtener y modificar sucursal
DECLARE @id_2 INT;
EXEC gestion_sucursal.Obtener_Id_Sucursal 
    @nombreSucursal = 'San Justo', 
    @id = @id OUTPUT;

EXEC gestion_sucursal.Modificar_Sucursal 
    @id, @nombre = 'Yangon';

EXEC gestion_sucursal.Modificar_Sucursal 
    @id, @nombre = 'San Justo';

-- Obtener y modificar categoría de producto
EXEC gestion_producto.Obtener_Id_Categoria 
    'labios', @id = @id OUTPUT;

-- Caso de error: Modificar categoría con tipo de producto inválido
EXEC gestion_producto.Modificar_Categoria 
    @id, @id_tipoProducto = 14;

-- Obtener tipo de producto y modificar categoría correctamente
EXEC gestion_producto.Obtener_Id_Tipo 
    'Perfumería', @id = @id_2 OUTPUT;

EXEC gestion_producto.Modificar_Categoria 
    @id, @id_tipoProducto = @id_2;

--Modificación de Tipo de producto
EXEC [gestion_producto].Modificar_TipoProducto 1, 'Bebidas MODIFICADO'
EXEC [gestion_producto].Modificar_TipoProducto 1, 'Bebidas'

--Modificación de Empleado
EXEC [gestion_sucursal].Modificar_Empleado 1, 257029, 'Maria MODIFICADO', 'Lopez MODIFICADO'

SELECT * FROM [gestion_sucursal].Empleado
WHERE legajo=257029 OR id = 1

--Modificación de Medio de Pago
EXEC gestion_venta.Modificar_MedioDePago 1, 'Tarjeta MODIFICADA'
EXEC gestion_venta.Modificar_MedioDePago 1, 'Tarjeta Crédito'


--Modificación de Cliente
EXEC gestion_venta.Modificar_TipoFactura 2, 'F'
EXEC gestion_venta.Modificar_TipoFactura 2, 'B'
--Consultas comentadas para verificaciones--
/*SELECT * FROM gestion_sucursal.Cargo
SELECT * FROM gestion_sucursal.Sucursal
SELECT * FROM gestion_sucursal.Empleado
SELECT * FROM gestion_venta.MedioDePago
SELECT * FROM gestion_producto.Categoria
SELECT * FROM gestion_producto.TipoProducto
SELECT * FROM gestion_producto.Proveedor
SELECT * FROM gestion_producto.Producto
SELECT * FROM gestion_venta.MedioDePago*/
