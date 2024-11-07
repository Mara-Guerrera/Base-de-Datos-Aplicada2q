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

-- Habilitar Ad Hoc Distributed Queries (si no está habilitado)
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
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
-- LTRIM RTRIM borran los espacios al inicio y al final de la celda
-- NULLIF(NULLIF(columna, ''), ' ') asegura que los valores vacíos y los que contienen solo espacios se reemplacen por NULL
    INSERT INTO #TempEmpleados ([email personal], [email empresa], CUIL, Cargo, Sucursal, Turno)
	SELECT 
		NULLIF(NULLIF(LTRIM(RTRIM([email personal])), ''), ' ') AS [email personal],
		NULLIF(NULLIF(LTRIM(RTRIM([email empresa])), ''), ' ') AS [email empresa],
		NULLIF(NULLIF(LTRIM(RTRIM(CUIL)), ''), ' ') AS CUIL,
		NULLIF(NULLIF(LTRIM(RTRIM(Cargo)), ''), ' ') AS Cargo,
		NULLIF(NULLIF(LTRIM(RTRIM(Sucursal)), ''), ' ') AS Sucursal,
		NULLIF(NULLIF(LTRIM(RTRIM(Turno)), ''), ' ') AS Turno
	FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0', 
                'Excel 12.0;HDR=YES;Database=' + @rutaArchivo, -- Uso el nombre correcto de la hoja
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

		SELECT @turnoID = s.id
		FROM gestion_sucursal.Turno t JOIN #TempEmpleados te ON te.Turno = t.descripcion
		
		SELECT @empleadoID = c.id
		FROM gestion_sucursal.Empleado e JOIN #TempEmpleados te ON te.[email empresa] = e.email_empresa

		-- Si el empleado ya existe
		IF EXISTS (SELECT 1 FROM gestion_sucursal.Empleado WHERE id = @empleadoID)
		BEGIN
			EXEC gestion_sucursal.Modificar_Empleado
				@id				= @empleadoID,
				@cuil			= @empleadoCuil,
				@email			= @emailPersonal,
				@email_empresa	= @emailEmpresa,
				@id_cargo		= @cargoID,
				@id_sucursal	= @sucursalID,
				@id_turno		= @turnoID
		END
		ELSE
		BEGIN
			EXEC gestion_sucursal.Insertar_Empleado
				@cuil			= @empleadoCuil,
				@email			= @emailPersonal,
				@email_empresa	= @emailEmpresa,
				@id_cargo		= @cargoID,
				@id_sucursal	= @sucursalID,
				@id_turno		= @turnoID
		END
	END
	
    -- Limpiar la tabla temporal
    DROP TABLE #TempEmpleados;

    -- Confirmar que todo se completó sin errores
    PRINT 'Importación y registro completados exitosamente.';
END;


