library(jsonlite)
library(magrittr)
library(data.table)

perform_scan <- function(){
  x <- system("airport -s -x | sed 's/data/string/g' | cat | plutil -convert json -r -o - -- -", intern=TRUE) %>%
    paste(., collapse = "\n", sep = "") %>%
    fromJSON(., flatten = TRUE) %>%
    data.table
  x[, Time := Sys.time()]
  #x[, snr := RSSI / NOISE]
  #x[, distm := rssi_to_meters(RSSI, CHANNEL)]
  return(x)
}

get_preferences <- function(){
  system("airport prefs", intern = TRUE) %>%
    .[3:10] %>%
    strsplit("=") %>%
    do.call(rbind, .)
}

get_info <- function(){
  x <- system2("airport", "-I", stdout=TRUE) %>%
    gsub("^\\s+|$\\s+", "", .) %>%
    strsplit(., ":")
  keys = sapply(x, '[', 1) %>%
    make.names %>%
    c(., "Time")
  values = sapply(x, '[', -1) %>%
    lapply(., paste, collapse=":") %>% 
    gsub("^\\s+|$\\s+", "", .) %>%
    c(., as.ITime(Sys.time())*1000) %>%
    as.list
  DT <- rapply(values,
               utils::type.convert,
               classes = "character",
               how = "replace",
               as.is = TRUE) %>%
    rbind.data.frame %>%
    data.table
  setnames(DT, names(DT), keys)
  DT[, snr := agrCtlRSSI / agrCtlNoise]
  DT[, distm := rssi_to_meters(agrCtlRSSI, channel)]
  return(DT)
}
