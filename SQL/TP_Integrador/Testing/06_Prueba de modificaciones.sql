USE Com5600G05
GO

--Modificación de sucursal
EXEC [gestion_sucursal].Modificar_Sucursal 1, 'Yangon'

--ERROR: Caso de sucursal que no existe
EXEC [gestion_sucursal].Modificar_Sucursal 4, 'No existe'


--Modificación de Tipo de producto
EXEC [gestion_producto].Modificar_TipoProducto 1, 'Bebidas MODIFICADO'


--Modificación de Empleado
EXEC [gestion_sucursal].Modificar_Empleado 1, 257029, 'Maria MODIFICADO', 'Lopez MODIFICADO'


--Modificación de Medio de Pago
EXEC gestion_venta.Modificar_MedioDePago 1, 'Tarjeta MODIFICADA'


--Modificación de Cliente
EXEC gestion_venta.Modificar_TipoFactura 2, 'F'
