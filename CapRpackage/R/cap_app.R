## Only run examples in interactive R sessions

library(shiny)
library(shinyWidgets)
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
    gadgetTitleBar("Select CAP data",
                   right = miniTitleBarButton("done", "Download", primary = TRUE)),
    miniTabstripPanel(
      miniTabPanel("Parameters", icon = icon("sliders"),
                   miniContentPanel(
                     fillRow(pickerInput(
                       inputId = "category",
                       label = "Select type of activity",
                       choices = unique(data$category),
                       multiple = TRUE,
                       options = list(`actions-box` = TRUE)
                     ),
                     pickerInput(
                       inputId = "country",
                       label = "Select country",
                       choices = "", selected = "",
                       multiple = TRUE,
                       options = list(`actions-box` = TRUE)
                     ))
      )),
      miniTabPanel("Data", icon = icon("table"),
                   miniContentPanel(DT::dataTableOutput("table"))
      )
    )
  )

  server <- function(input, output, session) {

    observeEvent(
      input$category,
      updateSelectInput(session, "country", "Select country",
                        choices = unique(data$Country[data$category==input$category])))

      select_country <- reactive({
      df <- data %>%
        filter(category %in% input$category & Country %in% input$country) %>%
        select(Country, Type, Units, from, to) %>%
        arrange(Country, Type, from)
      df
      })


    output$table <- DT::renderDataTable(DT::datatable(select_country(),
                                                      options = list(paging = FALSE)))

    observeEvent(input$done, {

      # Emit a subset call if a dataset has been specified.
      dfselect <- data %>%
        filter(category %in% input$category & Country %in% input$country) %>%
        select(country_type, url) %>%
        arrange(country_type)

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
