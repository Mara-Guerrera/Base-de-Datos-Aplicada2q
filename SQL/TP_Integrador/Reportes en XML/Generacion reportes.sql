/*El sistema debe ofrecer los siguientes reportes en xml.
Mensual: ingresando un mes y a�o determinado mostrar el total facturado por d�as de
la semana, incluyendo s�bado y domingo.
Trimestral: mostrar el total facturado por turnos de trabajo por mes.
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar
la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a
menor.
Mostrar los 5 productos m�s vendidos en un mes, por semana
Mostrar los 5 productos menos vendidos en el mes.
Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha
y sucursal particulares*/DECLARE @anio INT DECLARE @mes INTSET @anio = 2019SET @mes = 2;WITH Consulta AS( SELECT 
        DATENAME(weekday, f.fecha) AS DiaSemana, 
        dv.subtotal
  FROM 
       gestion_venta.DetalleVenta dv
  INNER JOIN 
       gestion_venta.Factura f ON dv.id_factura = f.id
  WHERE 
       YEAR(f.fecha) = @anio 
       AND MONTH(f.fecha) = @mes)SELECT 
    @anio AS A�o,
    @mes AS Mes,
    [lunes] AS Lunes,
    [martes] AS Martes,
    [mi�rcoles] AS Mi�rcoles,
    [jueves] AS Jueves,
    [viernes] AS Viernes,
    [s�bado] AS S�bado,
    [domingo] AS Domingo
FROM 
    Consulta
PIVOT (
    SUM(subtotal)
    FOR DiaSemana IN ([lunes], [martes], [mi�rcoles], [jueves], [viernes], [s�bado], [domingo])
) AS PFOR XML PATH('D�as'), ROOT('Reporte');WITH subquery AS (
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
