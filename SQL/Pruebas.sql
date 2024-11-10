
USE Com5600G05

select * from gestion_sucursal.Ciudad

EXEC [gestion_sucursal].Insertar_Ciudad 'San Justo'
EXEC [gestion_sucursal].Insertar_Ciudad 'Ramos Mejia'
EXEC [gestion_sucursal].Insertar_Ciudad 'Lomas del Mirador'

EXEC [gestion_sucursal].Modificar_Ciudad 1, 'San Justo MODIFICADO'
--Caso Error: no existe
EXEC [gestion_sucursal].Modificar_Ciudad 4, 'No existe'

select * from gestion_sucursal.Sucursal

EXEC [gestion_sucursal].Insertar_Sucursal 'San Justo', 1
EXEC [gestion_sucursal].Insertar_Sucursal 'Ramos Mejia', 2
EXEC [gestion_sucursal].Insertar_Sucursal 'Lomas del Mirador', 2

--Caso Error: no existe ciudad
EXEC [gestion_sucursal].Insertar_Sucursal 'Lomas del Mirador', 16


EXEC [gestion_sucursal].Borrar_Sucursal 9

EXEC [gestion_sucursal].Modificar_Sucursal 4, 'No existe', 3

select * from gestion_sucursal.TipoProducto

EXEC [gestion_sucursal].Insertar_Tipo_Producto 'Bebidas'
EXEC [gestion_sucursal].Insertar_Tipo_Producto 'Electronic accesories'
EXEC [gestion_sucursal].Insertar_Tipo_Producto 'Home and lifestyle'

EXEC [gestion_sucursal].Modificar_TipoProducto 1, 'Bebidas MODIFICADO'

EXEC [gestion_sucursal].Borrar_TipoProducto 1


select * from gestion_sucursal.Empleado

EXEC [gestion_sucursal].Insertar_Empleado 'Emilce', 'MA',2
EXEC [gestion_sucursal].Insertar_Empleado 'RominaAlejandra', 'ALIAS', 2
EXEC [gestion_sucursal].Insertar_Empleado 'RominaSoledad', 'SA',3

EXEC [gestion_sucursal].Modificar_Empleado 5, 'Emilce MODIFICADO', 'MA MODIFICADO',2

EXEC gestion_sucursal.Borrar_Empleado 5


select * from gestion_sucursal.Producto

EXEC gestion_sucursal.Insertar_Producto 
    @descrip = 'Laptop', 
    @precio = 250.00, 
    @id_tipo = 2;  -- Electronic accesories

EXEC gestion_sucursal.Insertar_Producto 
    @descrip = 'Sofá', 
    @precio = 300.00, 
    @id_tipo = 3;  -- Home and lifestyle

	EXEC [gestion_sucursal].Modificar_Producto 3 , 'Laptop nueva MODIFICADO', 500.00, 3


EXEC gestion_sucursal.Borrar_Producto 1


select * from gestion_venta.MedioDePago

EXEC gestion_venta.Insertar_Medio_De_Pago 'Ewallet'

EXEC gestion_venta.Modificar_MedioDePago 2, 'Cash'

EXEC gestion_venta.Borrar_MedioDePago 1

INSERT INTO gestion_sucursal.TipoCliente(descripcion) VALUES ('Normal'),('Member'); 
INSERT INTO gestion_sucursal.Genero(descripcion) VALUES ('Female'),('Male');

select * from gestion_sucursal.TipoCliente
select * from gestion_sucursal.Genero

select * from gestion_sucursal.Cliente

EXEC gestion_sucursal.Insertar_Cliente 'Melisa', 'Ge', 1, 1, 2
EXEC gestion_sucursal.Insertar_Cliente 'Matias', 'Go', 2, 2, 2


EXEC gestion_sucursal.Borrar_Cliente 1


EXEC gestion_sucursal.Modificar_Cliente 1, 'Melisa MODIFICADO', 'Ge MODIFICADO', 1, 1, 2


INSERT INTO gestion_venta.TipoFactura(nombre) VALUES ('A'),('B'),('C'); 

select * from gestion_venta.TipoFactura

select * from gestion_venta.Factura

EXEC gestion_venta.Insertar_Factura '750-67-8428', 1, 2, '2024-10-31', '14:30:00', 1, 1, 2 
EXEC gestion_venta.Insertar_Factura '750-67-8429', 1, 2, '2024-10-31', '14:33:00', 1, 1, 2


EXEC gestion_venta.Borrar_Factura '750-67-8428'


select * from gestion_venta.DetalleVenta

EXEC gestion_venta.Insertar_DetalleVenta 1, '750-67-8428', 2
EXEC gestion_venta.Insertar_DetalleVenta 2, '750-67-8429', 2

EXEC gestion_venta.Borrar_DetalleVenta 1, '750-67-8428'

delete gestion_venta.DetalleVenta
where id_detalle= 4