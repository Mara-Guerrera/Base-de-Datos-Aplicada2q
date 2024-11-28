USE Com5600G05
DECLARE @RutaArchivo NVARCHAR(255);

-- ============================ Inserción de datos de la empresa ============================

DECLARE @telefono VARCHAR(20);
SET @telefono = '11 6846-2003'; 
INSERT INTO gestion_sucursal.Empresa(cuit,razon_social,telefono) VALUES ('20-12801863-9','Aurora S.A.',@telefono)
GO

DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC gestion_sucursal.Importar_Sucursales @RutaArchivo
GO
DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC gestion_sucursal.Importar_Empleados @RutaArchivo 
GO
DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx';
EXEC gestion_producto.Importar_TipoProducto_Categoria @RutaArchivo;
GO
DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx';
EXEC gestion_venta.Importar_Medios_de_Pago @RutaArchivo;
GO
DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
EXEC gestion_producto.Importar_Productos_Importados @RutaArchivo;
GO
DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Productos\catalogo.csv'
EXEC gestion_producto.Importar_catalogo_csv @RutaArchivo
GO
DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
EXEC gestion_producto.Importar_Electronicos @RutaArchivo
GO
DECLARE @RutaArchivo NVARCHAR(255);
SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Ventas_registradas.csv'
EXEC gestion_venta.Importar_ventas_csv @RutaArchivo
GO
