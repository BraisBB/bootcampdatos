### Práctica BOOTCAMP
Este repositorio contiene la práctica final del BOOTCAMP, realizada utilizando DBT (Data Build Tool) y Snowflake como base de datos. 
La práctica se basa en el DATASET de prueba de Snowflake TCPH_SF1. A continuación, se describe cada parte del proyecto y las tareas realizadas. 
El proyecto ha sido creado por Adrián López Espineira, Brais Becerra Bermúdez y Samuel Aguiar Cabaleiro. 

### PARTE A: Estudio del DATASET
Antes de comenzar con la implementación, se realizó un estudio del DATASET TCPH_SF1 para entender la información que proporciona cada tabla. 
Este estudio permitió identificar las tablas relevantes y su estructura, aunque no se documentó explícitamente en este repositorio.

### PARTE B: Capa de datos RAW
En esta parte, se creó una capa de datos "RAW" simulando la generación de datos "fake". 
Se programaron inserciones periódicas para simular el flujo de pedidos que llegan a la base de datos de una empresa de envíos. 
Esta capa también puede incorporar datos de otras fuentes según las necesidades.

### PARTE C: Capa de datos intermedia
Esta capa contiene las dimensiones y tablas de hechos con datos limpios y aplicando lógica de negocio. 
Se creó una tabla de ventas a nivel de fecha, con varias transformaciones y cálculos adicionales:
- Identificación del tipo de operación (venta o devolución).
- Creación de una dimensión de tienda con país relacionado.
- Generación de un campo ID_EVENTO para promociones/eventos.
- Conversión de importes a moneda local y UTC a hora local.
- Cálculo del campo PLAZO_ENTREGA para indicar el plazo de entrega de los pedidos.

### PARTE D: Capa de datos analítica
Se crearon tablas agregadas a partir de la capa intermedia, agrupando la información para realizar análisis desde distintos puntos de vista 
(tienda y cliente). Estas agregadas son las únicas que se disponibilizan al cliente.


### PARTE E: Reprocesado completo
Se implementó un reprocesado de datos para ajustar el criterio de plazos de entrega, incluyendo un nuevo criterio de "Entrega crítica". 
Se ofrece una manera de reprocesar datos según intervalos de fecha.


### PARTE F: Análisis mediante dashboards
Se realizaron análisis mediante dashboards para mostrar, por ejemplo, los pedidos tardíos, en plazo o fuera de plazo por región. 
Esto permite identificar áreas de mejora en el proceso de envío.