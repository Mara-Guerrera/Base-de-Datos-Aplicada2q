
DECLARE @RutaArchivo NVARCHAR(255);

SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Importar_Sucursales @RutaArchivo

SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx'
EXEC Importar_Empleados @RutaArchivo 

SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx';
EXEC Importar_TipoProducto_Categoria @RutaArchivo;

SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Informacion_complementaria.xlsx';
EXEC Importar_Medios_de_Pago @RutaArchivo;

SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
EXEC Importar_Productos_Importados @RutaArchivo;

SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Productos\catalogo.csv'
EXEC Importar_catalogo_csv @RutaArchivo

SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
EXEC Importar_Electronicos @RutaArchivo

SET @RutaArchivo = N'C:\Users\Public\Downloads\TP_integrador_Archivos\Ventas_registradas.csv'
EXEC Importar_ventas_csv @RutaArchivo