# funciones para shiny app: "Conócete"
##########

# Función que crea data frame de palabras a partir del archivo de publicaciones con extensión .json
# descargado desde facebook (leer README para información de cómo descargar este archivo)
crear_df_nube <- function(aJsonPath) {
  # el archivo JSON se lee con R utilizando la función fromJSON().
  # Esto se guarda como una lista en R
  result <- fromJSON(file = aJsonPath)
  # Convertir archivo JSON a dataframe
  json_data_frame <- lapply(result, function(aPost)
    aPost$data)
  df <- bind_rows(json_data_frame, .id = "column_label")
  ###########################
  #### cleaning utf
  df$post <- utf2win(df$post)
  df <- mutate(df,
               post_clean = gsub(
                 x = post,
                 pattern = "[0-9]+|[[:punct:]]|\\(.*\\)",
                 replacement = ""
               )) # post_clean auxilia para recuperar post con palabra cliqueada.
  # lo hice por un problema con palabras que rodeadas con puntos y otros símbolos.
}

# Función que crea nube de palabras que se repiten al menos 9 veces
# dentro de tus publicaciones de facebook.
crear_nube <- function(aDataframe) { 
  ###########################
  ############ colectando palabras
  # agregar stopwords de español
  custom_stop_words <- bind_rows(stop_words,
                                 tibble(word = stopwords("spanish"),
                                            lexicon = "custom"))
  ############################
  ## Contar palabras
  word_counts <-
    aDataframe %>%
    unnest_tokens("word", post_clean) %>%
    anti_join(custom_stop_words, by = "word") %>%
    count(word) %>%
    filter(n > 1) %>% # que aparezcan repetidas
    na.omit()
  
  # reordenar
  word_counts <- arrange(word_counts, desc(n))
    
  print(word_counts)
  
  # Definir colores de nube
  my_palette <-
    c("steelblue",
      "firebrick",
      "olivedrab",
      "powderblue",
      "purple",
      "chocolate")
  # CONTROL - DIRECTIVA
  ### NUMERO DE PALABRAS A MOSTRAR
  n_word <- 20 # yes... you know the N-word nobody can say
  ##########################
  # Crear nube -- esto regresa la función
  wordcloud2(
    head(word_counts, n_word),
    color = rep_len(my_palette,
                    nrow(word_counts)),
    shape = "star",
    size = 0.7,
    backgroundColor = "White"
  )
}
######## función para limpiar carácteres extraños importados por mala codificación
######## de archivo .json por parte de facebook.
# Todavía falta resolver problema de mayúsculas acentuadas
# esta fué una solución machetera.
utf2win <- function(x){
  soll <- c( "ó", "ñ", "á", "é", "ú",
             "¡", "¿", "ü",
             "É", "Ó", "Ú",
             "í", "-", "")
  
  ist <- c("Ã³", "Ã±", "Ã¡", "Ã©", "Ãº",
           "Â¡", "Â¿", "Ã¼",
           "Ã‰", "Ã“", "Ãš",
           "Ã", "â", "ð")
  
  for(i in 1: length(ist)){
    x <- gsub(ist[i], soll[i], x)
  }
  return(x)
}