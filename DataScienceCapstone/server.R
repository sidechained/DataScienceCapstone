library(shiny)
library(tidyverse)
library(tidytext)
library(stringr)

# TODO: deal with double spaces - detect whitespace

corpus <- read.csv("corpus.csv.gz", header = TRUE)

predict <- function(data, myPredictor) {
  data %>% filter(predictor == myPredictor) %>% select(-predictor) %>% unlist(use.names = FALSE)
}

shinyServer(function(input, output, session) {
  observeEvent(input$userText, {
    last_char <- str_sub(input$userText, -1)
    if (last_char == " ") {
      predictor <- str_sub(input$userText, 0, -2)
      predictor <- tolower(predictor)
      predictor <- unlist(str_split(predictor, " "))
      if (length(predictor) == 1) {
        predicted <- predict(corpus, predictor)
      } else if (length(predictor) > 1) {
        # truncate to two words max:
        predictor <- tail(predictor, 2)
        predictor <- paste(predictor, collapse = ' ') # two words char vec to single string
        # implement simple backoff model:
        # 1. first predict using two word predictor
        predicted <- predict(corpus, predictor)
        # 2. if two-word predictor gives no result, break off the last work and try again
        if (length(predicted) == 0) {
          predictor <- word(predictor, -1, -1)
          predicted <- predict(corpus, predictor)
        }
      }
      if (length(predicted) == 0) { predicted = c(NA, NA, NA) } # if no prediction found, return result as if all predictions blank
      predicted[is.na(predicted)] <- "" # convert NA's to empty strings (i.e. display nothing)
      updateActionButton(session, "button1", label = predicted[1])
      updateActionButton(session, "button2", label = predicted[2])
      updateActionButton(session, "button3", label = predicted[3])
    }
  })
  
  observeEvent(input$button1, {
    existingText <- input$userText
    buttonText <- input$btnLabel1
    buttonText <- paste0(buttonText, " ")
    updateTextInput(session, "userText", value = paste0(existingText, buttonText))
  })
  
  observeEvent(input$button2, {
    existingText <- input$userText
    buttonText <- input$btnLabel2
    buttonText <- paste0(buttonText, " ")
    updateTextInput(session, "userText", value = paste0(existingText, buttonText))
  })
  
  observeEvent(input$button3, {
    existingText <- input$userText
    buttonText <- input$btnLabel3
    buttonText <- paste0(buttonText, " ")
    updateTextInput(session, "userText", value = paste0(existingText, buttonText))
  })
})
