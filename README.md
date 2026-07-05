# Econometr-a-subempleo-ecuador.
Modelo Logit sobre los determinantes del subempleo en Ecuador con datos de la ENEMDU 2026.
# Proyecto Econometría: Subempleo en Ecuador (ENEMDU 2026)

Este pepositorio fue creado con el fin de acceder más fácil al Script de Rstudio del cuál se armó el desollo del trabajo práctico Experimental
El proyecto se enfoca en medir cómo la educación, la edad y la ubicación geográfica cambian la probabilidad de que un trabajador caiga en el subempleo.

## Archivos del repositorio
* TRABAJO PRACTICO EXPERIMENTAL 4 - ECONOMETRIA APLICADA.pdf`**: Es el documento final con todo el desarrollo teórico (basado en Mincer y Krugman) y las conclusiones.
* `script_subempleo.R`**: Todo el código de RStudio que se usó para limpiar la base de datos de la ENEMDU, hacer las tablas descriptivas y estimar el modelo Logit.
* **Gráficos y Tablas**: Las imágenes de la Curva ROC y los resultados que exportamos directamente desde la consola.

## Resumen del Modelo
Trabajamos con una muestra depurada de 12,355 observaciones del primer trimestre de 2026[cite: 68]. La idea fue evaluar la variable `subempleo` (0 si no aplica, 1 si sí) en función de los años de escolaridad, la edad, el sexo y el área residencial (urbana o rural)

## Librerías de R utilizadas
Si vas a correr el script por tu cuenta, vas a necesitar instalar estos paquetes en RStudio:
* `tidyverse` (esencial para manejar y filtrar los microdatos).
* `mfx` (lo usamos para calcular los efectos marginales MEMs).
* `lmtest` (necesario para hacer la prueba de razón de verosimilitud).
* `pscl` (para obtener el indicador de bondad de ajuste de McFadden).
