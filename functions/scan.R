library(jsonlite)
library(magrittr)
x <- system("/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s -x | sed 's/data/string/g' | cat | plutil -convert json -r -o - -- -", intern=TRUE)
y <- paste(x, collapse = "\n")
z <- fromJSON(y)

perform_scan <- function(){
  x <- system("airport -s -x | sed 's/data/string/g' | cat | plutil -convert json -r -o - -- -", intern=TRUE) %>%
    paste(., collapse = "\n") %>%
    fromJSON
  x$time <- Sys.time()
  return(x)
}

x <- list()
for (i in 1:30){
  paste("scan:", i) %>% print
  x[[i]] <- perform_scan()
}

get_preferences <- function(){
  system("airport prefs", intern = TRUE) %>%
    .[3:10] %>%
    strsplit("=") %>%
    do.call(rbind, .)
}

