#
# This is a Shiny web application.

library(shiny)
library(tidyverse)

datadf <-read_delim("cap_qt_final_website.csv", ",", escape_double = FALSE, trim_ws = TRUE)
desc <- c("This column records the unique identifier for each observation",
"The year column records the year on which the event occurred",
"This column records the Comparative Agendas Project’s major topic code",
"This column records the Comparative Agendas Project’s subtopic code")

master <- read_csv("MasterCodebookTopics.csv",
col_types = cols(Last_Updated = col_skip(),
Version = col_skip())) %>%
  select(subtopic = Master_Subtopic, title = Title_140731)

# try <- read_delim("./R/clean_cap_df/cap_qt_final_website.csv", ",", trim_ws=TRUE, escape_double = FALSE) %>%
  # select(id:subtopic)


# Define UI for data upload app ----
ui <- navbarPage(title = "Prepare files for CAP",
######################################################
tabPanel("Uploading Files",
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Select a file ----
      fileInput("file1", "Choose CSV File",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),

      # Horizontal line ----
      tags$hr(),
      # Input: Checkbox if file has header ----
      checkboxInput("header", "Header", TRUE),
      # Input: Select separator ----
      radioButtons("sep", "Separator",
                   choices = c(Comma = ",",
                               Semicolon = ";",
                               Tab = "\t"),
                   selected = ","),
      # Input: Select quotes ----
      radioButtons("quote", "Quote",
                   choices = c(None = "",
                               "Double Quote" = '"',
                               "Single Quote" = "'"),
                   selected = '"'),
      # Horizontal line ----
      tags$hr(),
      # Input: Select number of rows to display ----
      actionButton("choice", "Show")
    ),
    # Main panel for displaying outputs ----
    mainPanel(
      # Output: Data file ----
      DT::dataTableOutput("contents")
    ))),
######################################################
tabPanel("Select columns",

             # Sidebar layout with input and output definitions ----
    sidebarLayout(

               # Sidebar panel for inputs ----
        sidebarPanel(
                 selectInput("column1", desc[1], choices = NULL),
                 selectInput("column2", desc[2], choices = NULL, selected = ""),
                 selectInput("column3", desc[3], choices = NULL, selected = ""),
                 selectInput("column4", desc[4], choices = NULL, selected = "")
               ),
               # Main panel for displaying outputs ----
               mainPanel(
                 # Output: Data file ----
                 DT::dataTableOutput("contents2")
               )
  )
),
######################################################
tabPanel("Check codes",
        sidebarLayout(
          sidebarPanel(
            actionButton("check", "Check codes"),
            br(),
            br(),
            downloadButton("downloadwrong", "Download list of wrong codes")
          ),
          mainPanel(
            tableOutput("contents3")
          )
        )
),
######################################################
tabPanel(
  title = 'Generate codebook',
  sidebarLayout(
    sidebarPanel(
      helpText(),
      radioButtons('format', 'Document format', c('PDF', 'HTML', 'Word'),
                   inline = TRUE),
      downloadButton('downloadReport')
    ),
    mainPanel(
      textInput("title", "title", "[TO CHANGE] Type of activity"),
      br(),
      textInput("id_text", "id", desc[1]),
      br(),
      textInput("year_text", "year", desc[2]),
      br(),
      textInput("major_text", "majortopic", desc[3]),
      br(),
      textInput("subtopic_text", "subtopic", desc[4])
    )
  )
),

######################################################
tabPanel("Downloading Data",
         sidebarLayout(
           # Sidebar panel for inputs ----
           sidebarPanel(
             # Button
             downloadButton("downloadData", "Download")
           ),
           # Main panel for displaying outputs ----
           mainPanel(
             tableOutput("contents4")
           )
)
)
)

# Define server logic to read selected file ----
server <- function(input, output, session) {

  reactive_df <-  eventReactive(input$choice, {
    req(input$file1)
    tryCatch(
      {df <- read.csv(input$file1$datapath,
                       header = input$header,
                       sep = input$sep,
                       quote = input$quote)
      },
      error = function(e) {
        stop(safeError(e))
      }
    )

    vars = names(df)

    updateSelectInput(session, "column1", desc[1], choices = vars)
    updateSelectInput(session, "column2", desc[2], choices = vars)
    updateSelectInput(session, "column3", desc[3], choices = vars)
    updateSelectInput(session, "column4", desc[4], choices = vars)

    df
  })

  output$contents <- DT::renderDataTable({
    reactive_df()
  })
######
  reactive_df2 <- reactive({
    df2 <- reactive_df() %>%
      select(id = input$column1,
             year = input$column2,
             majortopic = input$column3,
             subtopic = input$column4)
  })

  output$contents2 <- DT::renderDataTable({
    reactive_df2()
     })
######
  wrong <- eventReactive(input$check,{
               wrong <- anti_join(reactive_df2(), master) %>%
                 count(subtopic)
  })

  output$contents3 <- renderTable({
    wrong()
  })

  # Downloadable csv of wrong codes ----
  output$downloadwrong <- downloadHandler(
    filename = function() {
      paste("wrong", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(wrong(), file, row.names = FALSE)
    }
  )
######
output$downloadReport <- downloadHandler(
      filename = function() {
        paste('my-report', sep = '.', switch(
          input$format, PDF = 'pdf', HTML = 'html', Word = 'docx'
        ))
      },

      content = function(file) {
        src <- normalizePath('codebook.Rmd')

        # temporarily switch to the temp dir, in case you do not have write
        # permission to the current working directory
        owd <- setwd(tempdir())
        on.exit(setwd(owd))
        file.copy(src, 'codebook.Rmd', overwrite = TRUE)

        library(rmarkdown)
        out <- render('codebook.Rmd', switch(
          input$format,
          PDF = pdf_document(), HTML = html_document(), Word = word_document()
        ))
        file.rename(out, file)
      }
    )

######
  output$contents4 <- renderTable({
    reactive_df2()
  })

  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(reactive_df2(), file, row.names = FALSE)
    }
  )
}

# Create Shiny app ----
shinyApp(ui, server)
