# Know yourself.
# shiny app created by
# atilaorlov@gmail.com
# Conocete a ti mismo
# análisis de palabras más usadas en tus posts de facebook
##########
#########
# cargando la librería requeridas
require(stringr)
require(shiny)
require(htmlwidgets)
require(webshot)
require(rjson)
require(magrittr)
require(tidytext)
require(dplyr)
require(tm)
require(wordcloud2) # installed from git remotes::install_github("lchiffon/wordcloud2") to solve not downloading png/pdf
require(readr)
require(data.table)
require(shinyWidgets)
require(r2social)
# cargando script de funciones
source("functions.R")
webshot::install_phantomjs() # necesario para shiny io
webshot:::find_phantom()
## USER INTERFACE
################
ui <- fluidPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "minty"),
  r2social.scripts(),
  shareButton(link = "https://atilaorlov.shinyapps.io/conoCT/", position = "right"),
  setBackgroundImage(
    src = "https://images.unsplash.com/photo-1511933801659-156d99ebea3e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80"
  ),
  #### directiva javascript para manejar clic. Hallé rutas CSS requeridas Inpeccionando página.
  tags$script(
    HTML(
      "$(document).on('click', '#wordcloud', function() {
      word = $('#wordcloudwcLabel').text();
      Shiny.onInputChange('clicked_word', word);
    });"
    )
  ),
  ####
  titlePanel(title = 
             tags$a(href='https://atilaorlov.shinyapps.io/conoCT/',
                    icon("ice-cream"),
                    'conoCT'),
             windowTitle = "conoCT"),
  sidebarLayout(
    # Panel de herramientas (input e instructivo)
    sidebarPanel(
      p(
        "Explora las palabras que más utilizas dentro de tus publicaciones de facebook."
      ),
      fileInput(
        "Json",
        "Elige el archivo Json de tus publicaciones",
        multiple = FALSE,
        accept = c(".json")
      ),
      h1("Instrucciones:"),
      h2("1. Carga tu archivo .json"),
      p("Lo puedes descargar desde el siguiente enlace:"),
      a(
        "https://www.facebook.com/dyi/",
        href = "https://www.facebook.com/dyi/",
        target = "_blank"
      ),
      p(
        "Basta que elijas la casilla de tus posts. Elige el rango de tiempo que desees."
      ),
      p(
        "Si tienes dudas mira este video instructivo de 1 minuto en mi canal de Youtube"
      ),
      tags$a(href="https://www.youtube.com/@atltl", icon("youtube"), "Video Instructivo - 1 minuto", target="_blank"),
      
      h2("2. Interactúa con tu nube"),
      p(
        "Puedes dar clic en cualquier palabra para conocer los posts en donde las usaste."
      ),
      h2("3. Descarga tu nube"),
      p(
        "Puedes descargarla como una imagen utilizando el botón descargar."
      ),
      h2("4. Comparte"),
      p(
        "¡Publica tu nube e invita a tus amigos a conocerse compartiendo el enlace de esta página!"
      ),
      hr(),
      p("Esta aplicación es de código abierto. No recauda absolutamente ninguno de tus datos."),
      p("Puedes consultar el código fuente aquí"),
      tags$a(href="https://github.com/Atilaorlov/conoCT", icon("github"), "Código Fuente", target="_blank")
      
    ),
    # panel de outputs
    mainPanel(
      div(
      wordcloud2Output("wordcloud", height = "700px"),
      downloadButton(outputId = "savecloud"),
      tableOutput("filtered_tbl"),
      style = "background-color:#ADD8E6;"
      )
    )
  )
  
)

server <- function(input, output, session) {
  tu_nube <- 0 # la intención era descargar la misma nube
  # pero por alguna razón no funciona. 
  df <- reactive({
    req(input$Json)
    tryCatch(
    expr = crear_df_nube(input$Json$datapath), # ruta de archivo temporal
    error = function(e){
      message('Atrapé un error!')
      print(e)
    },
    warning = function(w){
      message('Atrapé una advertencia!')
      print(w)
    },
    finally = {
      message('Todo listo, me voy.')
    }
    )
  })
  output$wordcloud <- renderWordcloud2({
    tu_nube <<- crear_nube(df())
  })
  output$savecloud <- downloadHandler(
    filename = paste0("wordcloud", '.png'),
    content = function(file) {
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      saveWidget(tu_nube, "tmp.html", selfcontained = FALSE)
      webshot("tmp.html", file, delay = 3)
    }
  )
  
  filtered_comment <- reactive({
    req(input$clicked_word)
    clicked_word <-
      str_remove(input$clicked_word, ":[0-9]+$") # quitar símbolos y números a elemento cliqueado.
    
    df() %>%
      filter(str_detect(tolower(post_clean), paste0("\\b", clicked_word, "\\b"))) %>% # filtrar palabras no sub-strings. El artículo de ayuda tiene error aquí
      select(post) # versión de muestra solo selecciona la columna post. Implementar muestra fechas.
  })
  
  output$filtered_tbl = renderTable(filtered_comment())
  
}
shinyApp(ui, server)