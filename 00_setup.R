install.packages("pkgdepends")
install.packages("pak")

required_packages <- c("purrr", "rvest", "dplyr", "tidyr", "tidyselect", "stringr", "readr", "lubridate")

github_packages <- c("dickoa/robotoolbox", "elliottmess/koboAPI")
github_libraries <- c("robotoolbox", "koboAPI")


lapply(c(required_packages, github_packages), pak::pkg_install)

lapply(c(required_packages, github_libraries), library, character.only = TRUE)

source("utils.R")
