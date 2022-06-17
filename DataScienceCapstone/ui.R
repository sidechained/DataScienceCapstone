library(shiny)

shinyUI(
    fluidPage(
      tags$head(includeCSS("www/style.css")),
      h1("Capstone: A Predictive Text App"),
      h5(em("--- powered by SwiftKey data ---")),
      br(),
      textAreaInput("userText", "Enter text here:", height = 100, width = '100%'),
      splitLayout(height = 100,
        actionButton("button1", "", width = '100%',  onclick = "Shiny.setInputValue('btnLabel1', this.innerText);"),
        actionButton("button2", "", width = '100%',  onclick = "Shiny.setInputValue('btnLabel2', this.innerText);"),
        actionButton("button3", "", width = '100%',  onclick = "Shiny.setInputValue('btnLabel3', this.innerText);")
      ),
      br(),
      h4("Usage Instructions:"),
      tags$li("Begin by typing in the box above"),
      tags$li("Each time you press space to type a new word, Capstone will attempt to predict (up to) the next three words"),
      tags$li("Words are predicted in order of likelihood"),
      tags$li("To add the word to your sentence, simply click on it"),
      tags$li("You can then click on further suggestions or choose to continue typing"),
      tags$li("To keep things speedy, prediction only takes place based on the previous word or two words"),
      tags$li("Note: Prediction is automatic, but can in some cases take half a second or so to update")
    )
)
