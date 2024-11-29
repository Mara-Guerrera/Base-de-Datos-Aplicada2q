/*
		BASE DE DATOS APLICADA
		GRUPO: 05
		COMISION: 02-5600
		INTEGRANTES:
			María del Pilar Bourdieu 45289653
			Abigail Karina Peñafiel Huayta	41913506
			Federico Pucci 41106855
			Mara Verónica Guerrera 40538513

		FECHA DE ENTREGA: 29/11/2024

REPORTES:

El sistema debe ofrecer los siguientes reportes en xml.
Mensual: ingresando un mes y año determinado mostrar el total facturado por días de
la semana, incluyendo sábado y domingo.
Trimestral: mostrar el total facturado por turnos de trabajo por mes.
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a
menor.
Mostrar los 5 productos más vendidos en un mes, por semana
Mostrar los 5 productos menos vendidos en el mes.
Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha
y sucursal particulares
*/
-- ============================ GENERACION DE REPORTES ============================
USE Com5600G05
GO

/*Mensual: ingresando un mes y año determinado mostrar el total facturado por días de
la semana, incluyendo sábado y domingo.*/
CREATE OR ALTER PROCEDURE ReporteDiaSemana
    @anio INT,
    @mes INT
AS
BEGIN
    WITH Consulta AS
    ( 
        SELECT 
            DATENAME(weekday, f.fecha) AS DiaSemana, 
            dv.subtotal
        FROM 
            gestion_venta.DetalleVenta dv
        INNER JOIN 
            gestion_venta.Factura f ON dv.id_factura = f.id
        WHERE 
            YEAR(f.fecha) = @anio 
            AND MONTH(f.fecha) = @mes
    )
    SELECT 
        @anio AS Año,
        @mes AS Mes,
        [lunes] AS Lunes,
        [martes] AS Martes,
        [miércoles] AS Miércoles,
        [jueves] AS Jueves,
        [viernes] AS Viernes,
        [sábado] AS Sábado,
        [domingo] AS Domingo
    FROM 
        Consulta
    PIVOT (
        SUM(subtotal)
        FOR DiaSemana IN ([lunes], [martes], [miércoles], [jueves], [viernes], [sábado], [domingo])
    ) AS P
    FOR XML PATH('Días'), ROOT('Reporte');
END;
GO

--Trimestral: mostrar el total facturado por turnos de trabajo por mes.--

CREATE OR ALTER PROCEDURE ReporteTotalesMes
    @anio INT
AS
BEGIN
    WITH subquery AS (
        SELECT 
            dv.subtotal,
            e.id_turno,
            MONTH(f.fecha) AS mes_numero,
            DATENAME(MONTH, f.fecha) AS mes_nombre,
            (MONTH(f.fecha) - 1) / 3 + 1 AS trimestre
        FROM 
            gestion_venta.DetalleVenta dv
        INNER JOIN 
            gestion_venta.Factura f ON dv.id_factura = f.id
        INNER JOIN 
            gestion_sucursal.Empleado e ON f.id_empleado = e.id
    ),
    TotalesMes AS (
        SELECT 
            s.id_turno,
            s.mes_nombre,
            SUM(s.subtotal) AS total_mensual
        FROM 
            subquery s
        GROUP BY 
            s.id_turno, s.mes_nombre
    )
    SELECT 
        t.descripcion AS turno,
        ISNULL([Enero], 0) AS Enero,
        ISNULL([Febrero], 0) AS Febrero,
        ISNULL([Marzo], 0) AS Marzo
    FROM 
        TotalesMes
    PIVOT (
        SUM(total_mensual)
        FOR mes_nombre IN ([Enero], [Febrero], [Marzo])
    ) AS PivotMeses
    INNER JOIN 
        gestion_sucursal.Turno t ON PivotMeses.id_turno = t.id
    ORDER BY 
        t.descripcion
    FOR XML PATH('Turno'), ROOT('Reporte');
END;
GO

--Rango de fechas, mostrar cantidad de productos vendidos de menor a mayor--

CREATE OR ALTER PROCEDURE ReporteProductosPorFecha
    @fecha_1 DATE,
    @fecha_2 DATE
AS
BEGIN
    SELECT 
        dv.id_producto,
        p.descripcion,
        SUM(dv.cantidad) AS total_vendido
    FROM 
        gestion_venta.DetalleVenta dv
    INNER JOIN 
        gestion_venta.Factura f ON dv.id_factura = f.id
    INNER JOIN 
        gestion_producto.Producto p ON dv.id_producto = p.id
    WHERE 
        f.fecha BETWEEN @fecha_1 AND @fecha_2
    GROUP BY 
        dv.id_producto, 
        p.descripcion
    ORDER BY 
        total_vendido DESC
    FOR XML PATH('Productos'), ROOT('ReporteDeVentas');
END;
GO

--Rango de fechas: mostrar cantidad de productos vendidos de menor a mayor, por sucursal--

CREATE OR ALTER PROCEDURE ReporteProductosPorSucursal
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SELECT 
        DISTINCT dv.id_producto,
        p.descripcion AS descripcion_producto,
        s.nombre AS nombre_sucursal,
        SUM(dv.cantidad) OVER (PARTITION BY f.id_sucursal, dv.id_producto) AS cant_prod_sucursal
    FROM 
        gestion_venta.Factura f
    INNER JOIN 
        gestion_venta.DetalleVenta dv ON f.id = dv.id_factura
    INNER JOIN 
        gestion_producto.Producto p ON dv.id_producto = p.id
    INNER JOIN 
        gestion_sucursal.Sucursal s ON s.id = f.id_sucursal
    WHERE 
        f.fecha BETWEEN @fecha_inicio AND @fecha_fin
    ORDER BY 
        s.nombre, cant_prod_sucursal
    FOR XML PATH('ProductoPorSucursal'), ROOT('Resultado');
END;
GO

--Mostrar los 5 productos más vendidos en un mes, por semana--

CREATE OR ALTER PROCEDURE ReporteProductosMasVendidosPorSemana
    @mes INT
AS
BEGIN
    WITH VentasPorProductoSemana AS (
        SELECT 
            p.descripcion,
            DATEPART(week, f.fecha) AS semana,
            dv.id_producto,
            SUM(dv.cantidad) AS cant  -- Sumamos la cantidad de productos vendidos
        FROM 
            gestion_venta.DetalleVenta dv
        INNER JOIN 
            gestion_venta.Factura f ON dv.id_factura = f.id
        INNER JOIN 
            gestion_producto.Producto p ON dv.id_producto = p.id
        WHERE 
            MONTH(f.fecha) = @mes
        GROUP BY
            p.descripcion, DATEPART(week, f.fecha), dv.id_producto  -- Agrupamos por producto y semana
    ),
    ProductosRankeados AS (
        SELECT 
            descripcion,
            semana,
            cant,
            ROW_NUMBER() OVER (
                PARTITION BY semana 
                ORDER BY cant DESC  -- Ordenamos por la cantidad total de productos vendidos
            ) AS nro_fila
        FROM 
            VentasPorProductoSemana
    )
    SELECT 
        descripcion,
        semana,
        cant,
        nro_fila
    FROM 
        ProductosRankeados
    WHERE 
        nro_fila <= 5  -- Limita a los 5 productos más vendidos
    ORDER BY 
        semana, nro_fila
    FOR XML PATH('Producto'), ROOT('Ventas');
END;
GO

/*Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha
y sucursal particulares*/

CREATE OR ALTER PROCEDURE ReporteTotalporFechaSucursal
    @fecha DATE,
	@id_sucursal INT
AS
BEGIN
  IF NOT EXISTS (SELECT 1 FROM gestion_sucursal.Sucursal WHERE id = @id_sucursal)
  BEGIN
	RAISERROR('La sucursal no es valida',16,1)
	RETURN;
  END
  DECLARE @total_facturado DECIMAL(8,2) = 0.00
  SELECT @total_facturado = SUM(dv.subtotal)
  FROM gestion_venta.DetalleVenta dv INNER JOIN gestion_venta.Factura f ON dv.id_factura = f.id
  WHERE f.fecha = @fecha
  AND f.id_sucursal = @id_sucursal
  DECLARE @nombre_sucursal VARCHAR(100)

  -- Obtener el nombre de la sucursal
  SELECT @nombre_sucursal = nombre
  FROM gestion_sucursal.Sucursal
  WHERE id = @id_sucursal

	-- Crear el XML con los resultados
  SELECT 
	(SELECT 
		@total_facturado AS total_facturado,
		@nombre_sucursal AS nombre_sucursal,
		@fecha AS fecha
	FOR XML PATH('Factura'), ROOT('Facturas')
	) AS FacturaXML;
END;
GO

--Mostrar los 5 productos menos vendidos en el mes--

CREATE OR ALTER PROCEDURE ProductosMenosVendidosPorMes 
@mes INT
AS
BEGIN
  WITH ProductosVendidos AS (
      -- Obtención de productos con su cantidad total vendida en el mes
      SELECT 
          p.descripcion,
          MONTH(f.fecha) AS mes,
          SUM(dv.cantidad) AS cantidad_vendida
      FROM 
          gestion_venta.DetalleVenta dv
      INNER JOIN 
          gestion_venta.Factura f ON dv.id_factura = f.id
      INNER JOIN 
          gestion_producto.Producto p ON dv.id_producto = p.id
      WHERE 
          MONTH(f.fecha) = @mes
      GROUP BY 
          p.descripcion, MONTH(f.fecha)
  )
  SELECT TOP 5
      descripcion,
      mes,
      cantidad_vendida
  FROM 
      ProductosVendidos
  ORDER BY 
      cantidad_vendida ASC  -- Ordenado de menor a mayor
  FOR XML PATH('Producto'), ROOT('Productos');
END;
GO
DECLARE @anio_1 INT 
DECLARE @mes_1 INT
SET @anio_1 = 2019
SET @mes_1 = 2;
DECLARE @fecha_1 DATE
DECLARE @fecha_2 DATE
SET @fecha_1 = '2019-01-01'
SET @fecha_2 = '2019-02-04'

-- Llamada al procedimiento que muestra el total facturado dada una fecha y una sucursal particular--
EXEC ReporteTotalporFechaSucursal @fecha_1,@id_sucursal = 1
GO
-- Llamada al procedimiento ReporteDiaSemana
EXEC ReporteDiaSemana @anio = 2019, @mes = 2;
GO
-- Llamada al procedimiento ReporteTotalesMes
EXEC ReporteTotalesMes @anio = 2019;
GO
-- Llamada al procedimiento ReporteProductosPorFecha
EXEC ReporteProductosPorFecha @fecha_1 = '2019-01-01', @fecha_2 = '2019-02-04';
GO
-- Llamada al procedimiento ReporteProductosPorSucursal
EXEC ReporteProductosPorSucursal @fecha_inicio = '2019-01-01', @fecha_fin = '2019-02-04';
GO
-- Llamada al procedimiento ReporteProductosMasVendidosPorSemana
EXEC ReporteProductosMasVendidosPorSemana @mes = 2;
GO
-- Muestro productos menos vendidos en un mes determinado -- 
EXEC ProductosMenosVendidosPorMes @mes = 2;
GO
