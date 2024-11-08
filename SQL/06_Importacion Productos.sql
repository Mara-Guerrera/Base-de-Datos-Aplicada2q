/*
		BASE DE DATOS APLICADA
		GRUPO: 05
		COMISION: 02-5600
		INTEGRANTES:
			María del Pilar Bourdieu
			Abigail Karina Peñafiel Huayta	41913506
			Federico Pucci
			Mara Verónica Guerrera

		FECHA DE ENTREGA: 08/11/2024

ENTREGA 4:

Se proveen los archivos en el TP_integrador_Archivos.zip
Ver archivo “Datasets para importar” en Miel.
Se requiere que importe toda la información antes mencionada a la base de datos:
• Genere los objetos necesarios (store procedures, funciones, etc.) para importar los
archivos antes mencionados. Tenga en cuenta que cada mes se recibirán archivos de
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.
• Considere este comportamiento al generar el código. Debe admitir la importación de
novedades periódicamente.
• Cada maestro debe importarse con un SP distinto. No se aceptarán scripts que
realicen tareas por fuera de un SP.
• La estructura/esquema de las tablas a generar será decisión suya. Puede que deba
realizar procesos de transformación sobre los maestros recibidos para adaptarlos a la
estructura requerida.
• Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal
cargados, incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones
en el fuente SQL. (Sería una excepción si el archivo está malformado y no es posible
interpretarlo como JSON o CSV).
*/

-- EJEMPLO DE SP GENERICO

CREATE OR ALTER PROCEDURE Importar_Excel
    @RutaArchivo VARCHAR(100), -- Ruta completa del archivo Excel
    @NombreHoja CHAR(10),  -- Nombre de la hoja de Excel a importar
    @NombreTablaDestino VARCHAR(10)
AS
BEGIN
    -- Habilitar el acceso a consultas distribuidas, si no está habilitado
    IF (SELECT value_in_use FROM sys.configurations WHERE name = 'Ad Hoc Distributed Queries') = 0
    BEGIN
        EXEC sp_configure 'show advanced options', 1;
        RECONFIGURE;
        EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
        RECONFIGURE;
    END

    -- Importar los datos desde el archivo Excel
    DECLARE @importacion NVARCHAR(MAX);

    SET @importacion = '
        SELECT * 
        INTO ' + QUOTENAME(@NombreTablaDestino) + ' 
        FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
                        ''Excel 12.0;HDR=YES;IMEX=1;Database=' + @RutaArchivo + ''',
                        ''SELECT * FROM [' + @NombreHoja + '$]'')';

    -- Ejecutar el SQL dinámico
    EXEC sp_executesql @importacion;
END
GO

-- ============================ STORED PROCEDURES IMPORTACION ============================
USE Com5600G05
GO

-- Habilitar Ad Hoc Distributed Queries (si no está habilitado)
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

-- ============================ SP IMPORTACION PRODUCTOS ============================

CREATE OR ALTER PROCEDURE Importar_Productos
--    @rutaArchivo VARCHAR(100)
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

    INSERT INTO #TempProductos (idProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad)
	SELECT 
		idProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
	'Excel 12.0;HDR=YES;Database=C:\Users\usuario\Documents\6) BD aplicadas\TP Reporte de Ventas\TP_integrador_Archivos\Productos\Productos_importados.xlsx;HDR=YES',
	'SELECT idProducto, NombreProducto, Proveedor, Categoria, CantidadPorUnidad, PrecioUnidad FROM [Listado de Productos$]');
	
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

    -- Confirmar que todo se completó sin errores
    PRINT 'Importación y registro de Productos: Se completaron exitosamente.';
END;
GO


-- ============================ SP IMPORTACION EMPLEADOS ============================

CREATE OR ALTER PROCEDURE ImportarEmpleados
    @rutaArchivo VARCHAR(100)
AS
BEGIN
    -- Declaro la tabla temporal: Los campos deben coincidir con los de las columnas del Excel
    CREATE TABLE #TempEmpleados (
        [email personal]	VARCHAR(60),
		[email empresa]		VARCHAR(60),
        CUIL				CHAR(13),
		Cargo				VARCHAR(20),
		Sucursal			VARCHAR(20),
		Turno				VARCHAR(20)
    );

-- Uso OPENROWSET para importar datos del archivo Excel a la tabla temporal
    INSERT INTO #TempEmpleados ([email personal], [email empresa], CUIL, Cargo, Sucursal, Turno)
	SELECT [email personal], [email empresa], CUIL, Cargo, Sucursal, Turno
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
                'Excel 12.0;HDR=NO;Database=' + @rutaArchivo, -- Uso el nombre correcto de la hoja
                'SELECT [email personal], [email empresa], CUIL, Cargo, Sucursal, Turno FROM [Empleados$]');
				
	-- Variable para manejar el índice del registro
    DECLARE @ind INT = 1
    DECLARE @cantRegistros INT

    -- Obtengo la cantidad de registros de la tabla temporal
    SELECT @cantRegistros = COUNT(*) FROM #TempEmpleados;

	DECLARE @empleadoID INT
	DECLARE @emailPersonal VARCHAR(60)
	DECLARE @emailEmpresa VARCHAR(60)
	DECLARE @empleadoCuil CHAR(13)
	DECLARE @cargoID INT
	DECLARE @sucursalID INT
	DECLARE @turnoID INT
    
    WHILE @ind <= @cantRegistros -- Recorro cada registro
	BEGIN
			-- Asigno mis campos
		SELECT @empleadoCuil = te.CUIL, @emailPersonal = te.[email personal], @emailEmpresa = te.[email empresa] 
		FROM gestion_sucursal.Empleado e JOIN #TempEmpleados te ON te.[email empresa] = e.email_empresa

		SELECT @cargoID = c.id
		FROM gestion_sucursal.Cargo c JOIN #TempEmpleados te ON te.Cargo = c.nombre

		SELECT @sucursalID = s.id
		FROM gestion_sucursal.Sucursal s JOIN #TempEmpleados te ON te.Sucursal = s.nombre

		SELECT @turnoID = t.id
		FROM gestion_sucursal.Turno t JOIN #TempEmpleados te ON te.Turno = t.descripcion
		
		SELECT @empleadoID = e.id
		FROM gestion_sucursal.Empleado e JOIN #TempEmpleados te ON te.[email empresa] = e.email_empresa

		-- Si el empleado ya existe
		IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @empleadoID)
		BEGIN
			UPDATE gestion_sucursal.Empleado
			SET
				cuil = ISNULL(@empleadoCuil, cuil),
				email = ISNULL(@emailPersonal, email),
				email_empresa = ISNULL(@emailEmpresa, email_empresa),
				id_cargo = ISNULL(@cargoID, id_cargo),
				id_sucursal = ISNULL(@sucursalID, id_sucursal),
				id_turno = ISNULL(@turnoID, id_turno)
			WHERE id = @empleadoID
			--PRINT 'Empleado modificado'
		END
		ELSE
		BEGIN
			INSERT INTO gestion_sucursal.Empleado(cuil, email, email_empresa, id_cargo, id_sucursal, id_turno)
			VALUES (@empleadoCuil, @emailPersonal, @emailEmpresa, @cargoID, @sucursalID, @turnoID)
			--PRINT 'Nuevo empleado insertado'
		END
	END
	
    -- Limpiar la tabla temporal
    DROP TABLE #TempEmpleados;

    -- Confirmar que todo se completó sin errores
    PRINT 'Importación y registro de Empleados: Se completaron exitosamente.';
END;
GO

