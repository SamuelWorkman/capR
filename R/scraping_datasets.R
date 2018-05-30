##%######################################################%##
#                                                          #
####  script to download latest dataset links and info  ####
#                                                          #
##%######################################################%##

library(tidyverse)
library(rvest)

url <- "http://www.comparativeagendas.net/datasets_codebooks"

#Reading the HTML code from the website
webpage <- read_html(url) 

agenda_name <- webpage %>% 
  html_nodes("h5") %>% 
  html_text()

agenda_content <- webpage %>% 
  html_nodes(".category") %>%
  purrr::set_names(agenda_name)

agenda_children <- agenda_content %>% 
  purrr::map(.f=function(x) xml_contents(x))

agenda_children %>% 
  map(html_nodes(".dataset-display"))

media_be <- agenda_children[["Media"]][[2]]

try <- media_be %>% 
  html_node(".dataset > .clickable .left") %>% 
  html_text(trim = TRUE)

title <- webpage %>%
  html_nodes(".category")

budget <- title[[6]]

agenda_children[[2]] %>% 
  html_nodes(".dataset > .clickable .left") 

budget_uk <- xml_child(budget, 2)

budget

budget_uk %>% 
  html_nodes(".dataset_description .dataset-display") %>% 
  html_text(trim = TRUE)

budget_uk %>% 
  html_nodes("p") %>% 
  html_text()

budget_uk %>% 
  html_nodes("br+ .clickable") %>% 
  html_attr('href')

budget_uk %>% 
  html_nodes(".clickable") %>% 
  html_attr('href')

