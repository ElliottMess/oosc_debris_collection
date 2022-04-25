library(rvest)
library(tidyverse)
library(glue)
library(whdh)

padi_dab_survey_list_raw <- read_html("https://www.diveagainstdebris.org/diver/pharaoh-dive-club") %>%
  html_elements('a') %>%
  html_attr("href")

padi_dab_survey_list <- paste0(
  "https://www.diveagainstdebris.org",
  padi_dab_survey_list_raw[grep("^/debris-", padi_dab_survey_list_raw)])

sanitize_string <- function(string){
  string %>%
    str_remove_all(pattern = "\\n") %>%
    stringr::str_trim()
}

css_class_to_df <- function(html_obj, css_class, label, text ){

  col <- html_obj %>%
    html_elements(paste0(css_class, label)) %>%
    html_text() %>%
    sanitize_string()

  data <- html_obj %>%
    html_elements(paste0(css_class, text)) %>%
    html_text() %>%
    sanitize_string()

  tibble(cols = col, data = data) %>%
    pivot_wider(names_from = cols, values_from = data)
}

scrape_dab_single_url <- function(url){
  message(url)
  success <- FALSE
  while(!success){
    if(exists("survey_html")){
      rm(list = "survey_html")
    }
    tryCatch({
      survey_html <- read_html(url)
      if(exists("survey_html")){
        success <- TRUE
      }},
      error = function(e){
        message(sprintf("Execution stopped due to the following error:\n\n%s", e))
      },
      finally = {
      }
    )
  }

  survey_header_df <- css_class_to_df(survey_html, ".DebrisStats__stat", "Label", "Text")

  survey_info_df <- css_class_to_df(survey_html, ".DebrisData__", "label", "text")

  survey_collected_materials <- survey_html %>%
    html_elements("table") %>%
    html_table() %>%
    map_dfc(function(x){

      material_type <- unique(str_remove(names(x), " materials collected$"))

      tibble(cols = x[[1]], data = x[[2]]) %>%
        pivot_wider(names_from = cols, values_from = data) %>%
        rename_with(~paste0(material_type, "_", .x))
    })

  bind_cols(survey_header_df, survey_info_df, survey_collected_materials)
}

all_surveys <- map_dfr(padi_dab_survey_list, scrape_dab_single_url)

write_csv(all_surveys, glue("padi_dab_pdc_survey_data_{get_formatted_timestamp()}.csv"))

