
install.packages("pak")
install.packages("purrr")

required_packages <- c("rvest", "dplyr", "tidyr", "tidyselect", "stringr", "readr", "lubridate")

github_packages <- c("dickoa/robotoolbox", "elliottmess/koboAPI")
github_libraries <- c("robotoolbox", "koboAPI")


purrr::walk(c(required_packages, github_packages), pak::pkg_install)

purrr::walk(c(required_packages, github_libraries), library, character.only = TRUE)

source("utils.R")
