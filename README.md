Archivos 
https://docs.google.com/document/d/1Ocj6CDh_mJquYg7BWyarYnQ26f5hCJQUOTf-dN3YSRo/edit?tab=t.0
catalogo.csv 
id,category,name,price,reference_price,reference_unit,date
id,categoría,nombre,precio,precio_de_referencia,unidad_de_referencia,fecha

Electronic accesories.xlsx
Product | Precio unitario en dolares

Productos_importados.xlsx
id|NombreProducto|Proveedor|Categoría|Cantidad por unidad|PrecioUnidad

Nuestra tabla Productos
id (PK) | descripcion | precio | id_tipoProducto (FK) | activo 

Podríamos agregar el campo precio de referencia y unidad de referencia, además de cantidad por unidad (opcionales).

Archivo de información complementaria

Línea producto corresponde a nuestra tabla TipoProducto
y el Producto, en este caso, corresponde a una especie de categoría que solo aparece en el archivo catalogo.csv

Hice la primera importación (como archivo excel, no csv) a las tablas Tipo de producto y catálogo, desde el archivo informacion_complementaria, hoja clasificación productos.

7/11
-Debemos eliminar el id_ciudad de la tabla Sucursal. Agregar campos dirección, teléfono (con un formato) y horario. Cambiar los insert y update de Sucursal.
-Importar medios de pago y archivos de catálogos. 
