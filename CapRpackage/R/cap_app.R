## Only run examples in interactive R sessions

library(shiny)
library(miniUI)
library(leaflet)
library(ggplot2)

cap_app <- function() {

  data <- jsonlite::fromJSON("https://www.comparativeagendas.net/api/datasets/metadata")

  ui <- miniPage(
    gadgetTitleBar("Select CAP data"),
    miniTabstripPanel(
      miniTabPanel("Parameters", icon = icon("sliders"),
                   miniContentPanel(
                     selectInput(inputId = "category", label = "Select type of activity",
                                                choices = unique(data$category), multiple = TRUE),
                     selectInput(inputId = "country", label = "Select country",
                                 choices = unique(data$country))
      )),

     # miniTabPanel("Map", icon = icon("map-o"),
     #               miniContentPanel(padding = 0, leafletOutput("map", height = "100%")),
     #               miniButtonBlock(actionButton("resetMap", "Reset"))
     #  ),
     miniTabPanel("Data", icon = icon("table"),
                   miniContentPanel(DT::dataTableOutput("table"))
      )
    )
  )

  server <- function(input, output) {
    re <- reactive({
      subset(data, category==input$category & country==input$country, select =
               c("country", "name", "stats_observations", "stats_year_from", "stats_year_to"))
    })

    output$table <- DT::renderDataTable(re())

    observeEvent(input$done, {
      stopApp(TRUE)
    })
  }

  runGadget(ui, server)
}

cap_app()

