# Raku_scripts
 Algunos scripts que construí para automatizar la interacción con páginas web que contienen información geográfica.
 Usando la función de MAIN de Raku (perl6) una caracteristica del lenguaje que permite maquetar de manera rápida un utilidad para la terminal.
 
 
 ## ortofotos Inegi
 En el primer caso la utilidad tiene como función principal la consulta de un conjunto de ortofotos en la página del inegi,
 para ello tiene 3 comandos principales:
 
  - info #hace una busqueda de todas las cartas dadas y crea una tabla con la información de ellas
  - urls #genera un listado de los enlaces para su descarga, utíl si se piensa usar un gestor de descarga
  - Descarga #Descarga las ortofotos usando la librería WWW (es decir se guarda en la ram primero luego en disco, esto es un factor a mejorar)
  
 Para realizar las acciones simula que entras a la página, escribes tu busqueda, luego "capta" los resultados usando una segunda librería "Gumbo" para buscar dentro del html la tabla,
 convierte la tabla de html a un objeto de raku y filtra los resultados usando la configuración de los gatillos. Los gatillos son:

| Gatillo | Descripción |
|:------- | :---------- |
| bil=True|False |filtra solo documentos con formato .bil |
|  año=0000 |filtra los resultados a un año|
|  lista= True|False | interpreta el último comando como un documento con las ortofotos una en cada linea|
|  escala= | Filtra la escala, poner el todos los dígitos ej: 50000, 50_000|
|  rango=  |Filtra todos los resultados dentro un rango de años este se puede escribir en las siguientes maneras 1990-2010,1990:2010,2010-1990,2010:1990|
|  fuzz = True|False | Busqueda del producto cruzado entre el conjunto de la lista y los números del 1..9, no está terminado
  
Usando el producto cruzado fuzz puede obtener todas las subcartas, por ejemplo si se tiene un listado de cartas 1:50000 fuzz encontrará las cartas 1:20000 para todos ellos, actualmente estoy terminando está función por que quiero encontrar una manera de no saturar el servidor del inegi por el error de algún usuario, así que se encuentra deshabilitado.

##Uso

```
#descarga
git clone 

#busca un elemento y regresa la url
$ raku ortofotos_inegi.pm6 --bil --escala=10000 --fuzz --rango=2006-2020 urls E14B21D

#genera una tabla con las urls (no la guarda)
$ raku ortofotos_inegi.pm6 --bil --lista urls file.csv

#busca y descarga todas las imagenes de la lista
$ raku ortofotos_inegi --lista --año=2010 descarga lista

#guarda los enlaces en el documento 'resultados.csv'
$ raku ortofotos_inegi --lista --bil urls file2.csv > resultados.csv

```

Las acciones a implementar en el futuro son:
- Mejorar el rendimiento
- Crear clases de imágenes para evualuar los errores de entrada antes de ejecutar
- Implementar otros formatos (este es más fácil de hacer, pero ¿cuáles?)
- Busqueda difusa (gatillo -fuzz)
- Poner ejemplos de uso
- Poner una guía sobre la librerías usadas
- Cambiar la librería WWW por libcurl

## Planet
Creo que mejor hago un segundo repositorio para esto...

