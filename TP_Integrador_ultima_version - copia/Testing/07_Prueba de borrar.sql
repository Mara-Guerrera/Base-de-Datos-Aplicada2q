USE Com5600G05
GO

--Caso Error: no existe Sucursal
EXEC [gestion_sucursal].Borrar_Sucursal 9


--Borrar Tipo de Producto
EXEC [gestion_producto].Borrar_TipoProducto 1


--Borrar Empleado
EXEC [gestion_sucursal].Borrar_Empleado 1

--Borrar Producto
EXEC [gestion_producto].Borrar_Producto 2

--Caso Error: no existe Medio De Pago
EXEC gestion_venta.Borrar_MedioDePago 10

--Borrar Cliente
EXEC gestion_sucursal.Borrar_Cliente 1





