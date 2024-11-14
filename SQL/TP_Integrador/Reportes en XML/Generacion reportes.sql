/*El sistema debe ofrecer los siguientes reportes en xml.
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
y sucursal particulares*/

DECLARE @anio INT 
DECLARE @mes INT
SET @anio = 2019
SET @mes = 2;

WITH Consulta AS
( SELECT 
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


--Rango de fechas, mostrar cantidad de productos vendidos de menor a mayor--
DECLARE @fecha_1 DATE
DECLARE @fecha_2 DATE
SET @fecha_1 = '2019-01-01'
SET @fecha_2 = '2019-02-04'

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
--Rango de fechas: mostrar cantidad de productos vendidos de menor a mayor, por sucursal--
DECLARE @fecha_inicio DATE
DECLARE @fecha_fin DATE
SET @fecha_inicio = '2019-01-01'
SET @fecha_fin = '2019-06-04'

SELECT 
    DISTINCT dv.id_producto,
    p.descripcion AS descripcion_producto,
    s.nombre AS nombre_sucursal,
	SUM(dv.cantidad) OVER (PARTITION BY f.id_sucursal,dv.id_producto) AS cant_prod_sucursal
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
FOR XML PATH('ProductoPorSucursal'), ROOT('Resultado')
