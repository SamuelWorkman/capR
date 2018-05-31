## Only run examples in interactive R sessions

library(shiny)
library(miniUI)
library(leaflet)
library(ggplot2)
library(tidyverse)

cap_app <- function() {

  data <- jsonlite::fromJSON("https://www.comparativeagendas.net/api/datasets/metadata") %>%
    rename(Country = country, Type = name, Units = stats_observations,
           from = stats_year_from, to = stats_year_to) %>%
    mutate(url = paste0("https://comparativeagendas.s3.amazonaws.com/datasetfiles/
", datasetfilename))

  ui <- miniPage(
    gadgetTitleBar("Select CAP data"),
    miniTabstripPanel(
      miniTabPanel("Parameters", icon = icon("sliders"),
                   miniContentPanel(
                     selectInput(inputId = "category", label = "Select type of activity",
                                                choices = unique(data$category)),
                     selectInput(inputId = "country", label = "Select country",
                                 choices = unique(data$Country),
                                 multiple = TRUE, selectize = TRUE)
      )),

     # miniTabPanel("Map", icon = icon("map-o"),
     #               miniContentPanel(padding = 0, leafletOutput("map", height = "100%")),
     #               miniButtonBlock(actionButton("resetMap", "Reset"))
     #  ),
     miniTabPanel("Data", icon = icon("table"),
                   miniContentPanel(tableOutput("table"))
      )
    )
  )

  server <- function(input, output) {
    re <- reactive({
      subset(data, category==input$category & Country==input$country, select =
               c("Country", "Type", "Units", "from", "to"))
    })

    output$table <- renderTable(re())

    observeEvent(input$done, {
      stopApp(TRUE)
    })
  }

  runGadget(ui, server)
}

cap_app()

