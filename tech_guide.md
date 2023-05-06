# Archivos JSON

La información de facebook la puedes decargar dentro de la conf de priv o en el siguiente enlace https://www.facebook.com/dyi/

Puede descargarse en HTML o JSON. Se utilizó JSON. Para usar JSON en R se usó la paquetería rjson. Este enlace fue de utilidad https://www.tutorialspoint.com/r/r_json_files.htm

## Codificación utf-8 "doble"

Parece haber unos problemas conocidos respecto a la codificación de los archivos .JSON proporcionados por facebook. Esto se puede consultar aquí:

https://stackoverflow.com/questions/50008296/facebook-json-badly-encoded

Al leer los posts. Los carácteres acentuados y la ñ -entre otros carácteres especiales- aparecen cómo en la columna UTF-8 de la siguiente tabla:

https://www.indalcasa.com/programacion/html/tabla-de-codificaciones-de-caracteres-entre-ansi-utf-8-javascript-html/

utilicé la función utf2win para convertir estos carácteres extraños a los normales en la tabla anterior ANSI

Aún hay problemas con la Á y la Í. Pero eran aceptables para la versión BETA pero hay que atenderlos.

# wordcloud2

Para la nube se utilizó wordcloud2, siguiendo este artículo de blog
https://www.r-bloggers.com/2023/04/how-to-create-a-clickable-world-cloud-with-wordcloud2-and-shiny/?utm_source=phpList&utm_medium=email&utm_campaign=R-bloggers-daily&utm_content=HTML

para los stopwords en español se utilizó la librería tm, este link fue de ayuda http://jvera.rbind.io/post/2017/10/16/spanish-stopwords-for-tidytext-package/

## Donwload wordcloud2 as pdf/png

Hubo problemas con esto. Se resolvieron instalando la versión más reciente de wordcloud2 desde github.

En el siguiente enlace.

https://stackoverflow.com/questions/60062341/r-shiny-wordcloud2-breaking-downloadbutton

## En Shiny.io

para que funcione en shiny .io hay que agregar

```
webshot::install_phantomjs() # necesario para shiny io
webshot:::find_phantom()
```


