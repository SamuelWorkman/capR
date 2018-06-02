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
    mutate(url = paste0("https://comparativeagendas.s3.amazonaws.com/datasetfiles/", datasetfilename),
           country_type = paste(Country, Type, sep = "_"))

  allchoices_country <- c("Select all", unique(data$Country))
  allchoices_category <- c("Select all", unique(data$category))

  ui <- miniPage(
    gadgetTitleBar("Select CAP data"),
    miniTabstripPanel(
      miniTabPanel("Parameters", icon = icon("sliders"),
                   miniContentPanel(
                     selectInput(inputId = "category",
                                 label = "Select type of activity",
                                 choices = allchoices_category,
                                 multiple = TRUE, selectize = TRUE),
                     selectInput(inputId = "country",
                                 label = "Select country",
                                 choices = allchoices_country,
                                 multiple = TRUE, selectize = TRUE)
      )),
      miniTabPanel("Data", icon = icon("table"),
                   miniContentPanel(tableOutput("table"))
      )
    )
  )

  server <- function(input, output, session) {

    observe({
      if("Select all" %in% input$country)
        selected_country=allchoices_country[-1] # choose all the choices _except_ "Select All"
      else
        selected_country=input$myselect # update the select input with choice selected by user
      updateSelectInput(session, "country", selected = selected_country)
    })

    observe({
      if("Select all" %in% input$category)
        selected_category=allchoices_category[-1] # choose all the choices _except_ "Select All"
      else
        selected_category=input$myselect # update the select input with choice selected by user
      updateSelectInput(session, "category", selected = selected_category)
    })

      select_country <- reactive({
      subset(data, category %in% input$category & Country %in% input$country, select =
               c("Country", "Type", "Units", "from", "to"))
      })


    output$table <- renderTable(select_country())

    observeEvent(input$done, {

      # Emit a subset call if a dataset has been specified.
      dfselect <- subset(data, category==input$category & Country==input$country, select =
                      c("country_type", "url"))

      downloaded <- purrr::map(.x = dfselect$url, .f = ~read_csv(.x)) %>%
       set_names(dfselect$country_type)


      stopApp(
        downloaded
        )
    })
  }

  runGadget(ui, server)
}

trynew <- cap_app()
