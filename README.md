# OSM.Codes Colombia

<img align="right" width="350" src="assets/ilustra-grade01.jpeg">

Sumario:

* [Presentación](#)

  * [Proyección adoptada y origen](#)

  * [Códigos jerárquicos (geohashing)](#)

  * [Códigos abreviados (mnemotécnicos)](#)

### Presentación

**Un geocódigo es un identificador único de una entidad geográfica** (ubicación u objeto) que permite distinguirla de otras en un conjunto finito de entidades geográficas. Entre los códigos geográficos más populares se encuentran los [códigos de país y sus subdivisiones](https://es.wikipedia.org/wiki/ISO_3166-1_alfa-2) y los [códigos postales](https://es.wikipedia.org/wiki/Anexo:C%C3%B3digos_postales_de_Colombia).

Los geocódigos también se pueden asociar con un **sistema de cuadrícula discreto, que utiliza un mosaico jerárquico de celdas de áreas iguales para representar la superficie de la tierra**. Como cada celda representa una unidad espacial con un identificador de referencia único, este sistema puede reducir las consultas espaciales multidimensionales complejas en procesos de matriz unidimensionales, lo que **permite una integración de datos y cálculos rápidos y precisos**.

![](assets/ilustra-geohash01.PNG)

Esta aplicación de geocódigos es, por lo tanto, un **método computacionalmente eficiente para codificar coordenadas geográficas en un identificador corto**. Cuando se asocia con el contexto local, este código podría referirse a una propiedad rural (~ 15 m) con menos dígitos que el código postal. Con una resolución más baja (~ 3 m), también se puede hacer referencia a cualquier dirección urbana.

![](assets/ilustra-escalas01.jpg)

El proyecto OSM.Codes propone un sistema de cuadrícula discreto adaptado al contexto local de cada país. La propuesta de OSM.Codes Colombia se basa en los avances del mismo [proyecto en aplicación en Brasil](https://github.com/osm-codes/BR_IBGE_new).

### Proyección adoptada y origen

Esto proyecto adopta el [Sistema de Proyección Único para Colombia](https://origen.igac.gov.co/index.html), según la resolución 471 de 2020 del IGAC. En Colombia la proyección cartográfica oficial, se basa en una proyección Transversa de Mercator TM, usando un cilindro transverso como superficie de referencia y secante a la esfera. Este sistema prioriza ángulos (conforme), garantizando así que un ángulo formado entre dos líneas sobre la superficie terrestre se conserve luego de aplicarse la proyección. Los demás parámetros fueron seleccionados cuidadosamente de modo que, se cubriese todo el territorio continental, se evite el uso de coordenadas negativas y con un factor de escala k=0,9992 se optimizó que las distorsiones en la representación de área fuesen mínimas ([ABC Nueva projección cartográfica para Colombia](https://origen.igac.gov.co/docs/ABC_Nueva_Proyeccion_Cartografica_Colombia.pdf)).

![](assets/parametro-proyeccion.png)

Esta proyección cumple con los objetivos del proyecto, ya que permite generar una superficie de cuadrícula de igual superficie. La siguiente figura compara las cuadrículas regulares generadas con el Sistema de proyección única para Colombia (negro) y WGS84 (rojo).

![](assets/ilustra-grade01.jpeg)

Los parámetros del origen de la proyección se pueden utilizar como punto de centrado de la cuadrícula: LATITUD_O = 4.0 ° N y LONGITUD_O = 73.0 ° W.

### Códigos jerárquicos (geohashing)

Las celdas de un [sistema de cuadrícula discreta](https://en.wikipedia.org/wiki/Discrete_global_grid) (global o de un solo país) se pueden identificar de manera única por sus coordenadas de matriz ij, o por un solo número, llamado identificador. 

Para proporcionar un sistema de geocodificación jerárquico y compacto, adoptamos el [algoritmo Geohash generalizado](https://ppkrauss.github.io/Sfc4q/), que se basa en la partición uniforme y recurrente de celdas cuadriláteras en 4 sub- células, indexándolas por la curva de Morton.

![](assets/BR_new-ZCurve.png)

### Códigos abreviados (mnemotécnicos)

Una de las funciones de codificación / decodificación implementadas de la propuesta es la que da "abreviatura de contexto" al gecode propuesto.
