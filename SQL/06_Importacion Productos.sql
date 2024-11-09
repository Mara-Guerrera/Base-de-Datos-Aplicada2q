-- ============================ STORED PROCEDURES IMPORTACION ============================
USE Com5600G05
GO

-- ============================ SP IMPORTACION PRODUCTOS ============================

CREATE OR ALTER PROCEDURE Importar_Productos
    @rutaArchivo NVARCHAR(100),
	@nombreHoja	NVARCHAR(30)
AS
BEGIN
    -- Declaro la tabla temporal: Los campos deben coincidir con los de las columnas del Excel
    CREATE TABLE #TempProductos (
        idProducto			INT,
		NombreProducto		VARCHAR(60), --descri
        Proveedor			CHAR(60),
		Categoria			CHAR(15),
		CantidadPorUnidad	VARCHAR(25),
		PrecioUnidad		DECIMAL(7,2)
    );
/*
    INSERT INTO #TempProductos (idProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad)
	SELECT 
		idProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
	'Excel 12.0;HDR=YES;Database=C:\data\Productos_importados.xlsx',
	'SELECT idProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad FROM [Listado de Productos$]');
*/	
	DECLARE @importacion NVARCHAR(MAX);

    -- Construir la cadena SQL dinámica
    SET @importacion = N'
    INSERT INTO #TempProductos (idProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad)
    SELECT 
		idProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad
    FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'', 
        ''Excel 12.0;HDR=YES;Database=' + @rutaArchivo + ''', 
        ''SELECT idProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad FROM [' + @nombreHoja + '$]'')';

    -- Ejecutar el SQL dinámico
    EXEC sp_executesql @importacion;

	SELECT * FROM #TempProductos

	-- Falta revisar cuando existe el Proveedor y la Categoria
	INSERT INTO gestion_producto.Proveedor(nombre)
	SELECT DISTINCT Proveedor
	FROM #TempProductos
	WHERE Proveedor IS NOT NULL
	
	INSERT INTO gestion_producto.Categoria(nombre)
	SELECT DISTINCT Categoria
	FROM #TempProductos
	WHERE Categoria IS NOT NULL
	
	WITH CTE AS
	(
		SELECT 
			te.idProducto,
			te.NombreProducto,
			p.id AS proveedorID,  
			c.id AS categoriaID, 
			te.CantidadPorUnidad,
			te.PrecioUnidad
		FROM #TempProductos te
		JOIN gestion_producto.Producto ON id = te.idProducto
		JOIN gestion_producto.Proveedor p ON p.nombre = te.Proveedor
		JOIN gestion_producto.Categoria c ON c.nombre = te.Categoria
		
		WHERE NOT EXISTS ( -- Si no existe el Producto
            	SELECT 1 
            	FROM gestion_producto.Producto
           		WHERE descripcion = te.NombreProducto
       	 	)
	)
	INSERT INTO gestion_producto.Producto (descripcion, precio, id_categoria, cant_por_unidad, id_proveedor)
	SELECT 
		CTE.NombreProducto,
		CTE.PrecioUnidad,
		CTE.categoriaID,
		CTE.CantidadPorUnidad,
		CTE.proveedorID
	FROM CTE;

	WITH CTE2 AS
	(
		SELECT 
			te.idProducto,
			te.NombreProducto,
			p.id AS proveedorID,  
			c.id AS categoriaID, 
			te.CantidadPorUnidad,
			te.PrecioUnidad
		FROM #TempProductos te
		JOIN gestion_producto.Producto ON id = te.idProducto
		JOIN gestion_producto.Proveedor p ON p.nombre = te.Proveedor
		JOIN gestion_producto.Categoria c ON c.nombre = te.Categoria
		
		WHERE EXISTS ( -- Si ya existe el Producto
            	SELECT 1 
            	FROM gestion_producto.Producto
           		WHERE descripcion = te.NombreProducto
       	 	)
	)
	UPDATE gestion_producto.Producto
	SET 
		descripcion = ISNULL(CTE2.NombreProducto, descripcion),
		precio = ISNULL(CTE2.PrecioUnidad, precio),
		id_categoria = ISNULL(CTE2.categoriaID, id_categoria),
		cant_por_unidad = ISNULL(CTE2.CantidadPorUnidad, cant_por_unidad),
		id_proveedor = ISNULL(CTE2.proveedorID, id_proveedor)
	FROM CTE2;

    -- Limpiar la tabla temporal
    DROP TABLE #TempProductos;

    -- Confirmar que todo se completo sin errores
    PRINT 'Importación y registro de Productos: Se completaron exitosamente.';
END;
GO
EXEC Importar_Productos
	'C:\data\Productos_importados.xlsx',
	'Listado de Productos'
GO



