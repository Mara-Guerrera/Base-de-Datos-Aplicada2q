USE Com5600G05
GO
-- ERROR: Caso de sucursal que ya existe
EXEC gestion_sucursal.Insertar_Sucursal 
    'Ramos Mejia', 
    'Av. de Mayo 791, B1704 Padua, Provincia de Buenos Aires',
    'L a V 8 am a 8 pm.',
    '5555-5554',1
--Modificaciones en sucursal--
EXEC gestion_sucursal.Modificar_Sucursal @id = 1, @telefono = '6891-2244';
EXEC gestion_sucursal.Modificar_Sucursal @id = 1, @telefono = '5555-5551'
-- Inserción de Turnos, Cargo y Empleados
EXEC gestion_sucursal.Insertar_Turno 'TN';
EXEC gestion_sucursal.Borrar_Turno 4

EXEC gestion_sucursal.Insertar_Cargo 'Vendedor';
EXEC gestion_sucursal.Borrar_Cargo 4
--Inserto un empleado nuevo--
EXEC gestion_sucursal.Insertar_Empleado 
    204517, 'María', 'Maggio', 45289653, 
    'Av. Mayo 1050', '27-28033514-8', 
    'maria@gmail.com', 'maria_trabajo@empresa.com', 
    1, 1, 1;
--Lo doy de baja--
EXEC gestion_sucursal.Borrar_Empleado 16
-- Inserción de líneas de productos
EXEC gestion_producto.Insertar_Tipo_Producto 'Especias';

-- Inserción de categorías
EXEC gestion_producto.Insertar_Categoria 'Lácteos', 3;
EXEC gestion_producto.Insertar_Categoria 'Bebidas', 1;

-- Inserción de tipo de factura y género
EXEC gestion_venta.Insertar_TipoFactura 'D';
EXEC gestion_sucursal.Insertar_Genero 'Otro';

-- Inserción de proveedor
EXEC gestion_producto.Insertar_Proveedor 'Proveeduría Delta';

-- Pruebas de inserción de producto, con obtención de id para posterior actualización
DECLARE @id INT
EXEC gestion_producto.Insertar_Producto 
    'Queso de cabra curado', 12.50, 48, 25, 'kg', NULL, 3;

-- Obtener el id del producto para actualizar
EXEC gestion_producto.Obtener_Id_Producto 
    @nombreProducto = 'Queso de cabra curado', 
    @id = @id OUTPUT;

-- Modificar el producto usando el id obtenido
EXEC gestion_producto.Modificar_Producto 
    @id, @precio = 15.6, @precio_ref = 30;

--Borrar producto--
EXEC gestion_producto.Borrar_Producto @id
SELECT * FROM gestion_producto.Producto WHERE id = @id

-- Validar modificación
SELECT * FROM gestion_producto.Producto 
WHERE id = @id;

-- Obtener y modificar sucursal
EXEC gestion_sucursal.Obtener_Id_Sucursal 
    @nombreSucursal = 'San Justo', 
    @id = @id OUTPUT;

SELECT id,nombre FROM gestion_sucursal.Sucursal
WHERE id = @id

EXEC gestion_sucursal.Modificar_Sucursal 
    @id, @nombre = 'Yangon';

SELECT id,nombre FROM gestion_sucursal.Sucursal
WHERE id = @id

EXEC gestion_sucursal.Modificar_Sucursal 
    @id, @nombre = 'San Justo';


-- Obtener y modificar categoría de producto

EXEC gestion_producto.Obtener_Id_Categoria 
    'labios', 11, @id = @id OUTPUT

-- Caso de error: Modificar categoría con tipo de producto inválido
EXEC gestion_producto.Modificar_Categoria 
    @id, @id_tipoProducto = 11;

-- Obtener tipo de producto y modificar categoría correctamente
EXEC gestion_producto.Obtener_Id_Tipo 
    'Perfumería', @id = @id OUTPUT;

EXEC gestion_producto.Modificar_Categoria 
    @id, @id_tipoProducto = @id;

--Modificación de Tipo de producto
EXEC [gestion_producto].Modificar_TipoProducto 1, 'Bebidas MODIFICADO'
EXEC [gestion_producto].Modificar_TipoProducto 1, 'Bebidas'


--Modificación de Medio de Pago
EXEC gestion_venta.Modificar_MedioDePago 1, 'Tarjeta MODIFICADA'
EXEC gestion_venta.Modificar_MedioDePago 1, 'Tarjeta Crédito'


--Modificación de Tipo Factura
EXEC gestion_venta.Modificar_TipoFactura 2, 'F'
EXEC gestion_venta.Modificar_TipoFactura 2, 'B'
--Inserción de géneros--
EXEC gestion_sucursal.Insertar_Genero 'Female'
EXEC gestion_sucursal.Insertar_Genero 'Male'
--Inserción de tipos de clientes--
EXEC gestion_sucursal.Insertar_TipoCliente 'Normal'
EXEC gestion_sucursal.Insertar_TipoCliente 'Member'

--Inserción lote de clientes--

INSERT INTO gestion_sucursal.Cliente(nombre, apellido, id_tipo, id_genero, dni)
VALUES
('Juan', 'Pérez', 1, 2, '12345678'),
('Ana', 'González', 2, 1, '23456789'),
('Carlos', 'Martínez', 1, 2, '34567890'),
('Laura', 'López', 2, 1, '45678901'),
('Pedro', 'Rodríguez', 1, 2, '56789012'),
('María', 'Fernández', 2, 2, '67890123'),
('Luis', 'Sánchez', 1, 2, '78901234'),
('Carmen', 'Ramírez', 2, 1, '89012345'),
('José', 'Gómez', 1, 2, '90123456'),
('Elena', 'Vázquez', 2, 1, '1234567');

--Modificación de cliente--
DECLARE @id_cliente INT;
EXEC gestion_sucursal.Obtener_Id_Cliente @dni = 67890123, @id = @id_cliente OUTPUT;

SELECT * FROM gestion_sucursal.Cliente WHERE id = @id_cliente

EXEC gestion_sucursal.Modificar_Cliente @id_cliente,@id_genero = 1

SELECT * FROM gestion_sucursal.Cliente WHERE id = @id_cliente


--Borrado de categoría--
EXEC gestion_producto.Obtener_Id_Categoria 'aceite_vinagre_y_sal',2,@id = @id OUTPUT
EXEC gestion_producto.Borrar_Categoria @id

--Verificación--
SELECT nombre, id_tipoProducto, activo
FROM gestion_producto.Categoria 
WHERE nombre = 'aceite_vinagre_y_sal' AND id_tipoProducto = 2

--Inserción factura--
EXEC gestion_venta.Insertar_Factura '752-68-8428', 1, 2, '2024-11-15', '14:30:00', 2, 5, 3;
EXEC gestion_venta.Obtener_Id_Factura '752-68-8428', @id OUTPUT
EXEC gestion_venta.Insertar_DetalleVenta 1,@id,4
--Intento de inserción de una factura cuyo id no existe--
EXEC gestion_venta.Insertar_DetalleVenta 1,1010,4


--Consultas comentadas para verificaciones--
/*SELECT * FROM gestion_sucursal.Cargo
SELECT * FROM gestion_sucursal.Sucursal
SELECT * FROM gestion_venta.Factura WHERE id_factura = '752-68-8428'
SELECT * FROM gestion_sucursal.Empleado
SELECT * FROM gestion_venta.MedioDePago
SELECT * FROM gestion_sucursal.Turno
SELECT * FROM gestion_sucursal.Cliente
SELECT * FROM gestion_sucursal.Genero
SELECT * FROM gestion_sucursal.Cargo
SELECT * FROM gestion_producto.Producto
SELECT * FROM gestion_producto.Categoria
*/