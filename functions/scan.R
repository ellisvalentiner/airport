library(jsonlite)
library(magrittr)

perform_scan <- function(){
  x <- system("airport -s -x | sed 's/data/string/g' | cat | plutil -convert json -r -o - -- -", intern=TRUE) %>%
    paste(., collapse = "\n") %>%
    fromJSON
  x$time <- Sys.time()
  return(x)
}

get_preferences <- function(){
  system("airport prefs", intern = TRUE) %>%
    .[3:10] %>%
    strsplit("=") %>%
    do.call(rbind, .)
}

