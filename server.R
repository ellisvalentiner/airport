
library(shiny)
library(data.table)
library(ggvis)
library(magrittr)

rm(list = ls(all.names = TRUE))

perform_scan <- function(){
  x <- system2("airport", "-I", stdout=TRUE) %>%
    gsub("^\\s+|$\\s+", "", .) %>%
    strsplit(., ":")
  keys = sapply(x, '[', 1) %>%
    make.names %>%
    c(., "Time")
  values = sapply(x, '[', -1) %>%
    lapply(., paste, collapse=":") %>% 
    gsub("^\\s+|$\\s+", "", .) %>%
    c(., Sys.time()) %>%
    as.list
  DT <- rapply(values, utils::type.convert, classes = "character", how = "replace", as.is = TRUE) %>%
    rbind.data.frame %>%
    data.table
  setnames(DT, names(DT), keys)
  return(DT)
}

get_preferences <- function(){
  prefs <- system2("airport", "prefs", stdout=TRUE) %>%
    .[3:10] %>%
    strsplit("=") %>%
    do.call(rbind, .)
  colnames(prefs) <- c("Key", "Value")
  return(prefs)
}

data <- perform_scan()
#data <- data[1:30]

shinyServer(function(input, output, session){

  # Update data
  update_data <- function(){
    data <<- rbind(perform_scan(), data)
  }
  
  output$airport_perfs <- renderTable({
    # `$ airport prefs`
    # Get the current wireless preferences
    # Assume the user isn't going to change these so don't update
    get_preferences()
  })
  
  output$get_info <- renderTable({
    # `$ airport --getinfo`
    # Display current status
    invalidateLater(1000, session)
    data[1,] %>% t
  })
  
  output$current_time <- renderText({
    invalidateLater(1000, session)
    format(Sys.time(), "%d %h %Y %H:%M:%S")
  })
  
  output$RSSI <- renderPlot({
    invalidateLater(1000, session)
    update_data()
    data[complete.cases(data)] %>%
      ggvis(~Time*60, ~agrCtlRSSI) %>%
      layer_lines(stroke = ~factor(BSSID)) %>%
      layer_points(fill = ~factor(BSSID)) %>%
      scale_datetime("x", nice = "second", label = "Time") %>%
      scale_numeric("y", expand = 0.25, nice = TRUE, label = "RSSI") %>% 
      add_legend("stroke", title = "Access points (BSSID)") %>%
      hide_legend("fill") %>%
      set_options(renderer = "svg") %>%
      bind_shiny("rssi_plot")
  })
  
  output$hstgrm <- renderPlot({
    invalidateLater(1000, session)
    data[complete.cases(data)] %>%
      data.frame %>% 
      ggvis(~agrCtlRSSI) %>%
      layer_histograms() %>%
      set_options(renderer = "svg") %>%
    bind_shiny("hstgrm_plot")
  })
  
#   output$Noise <- renderPlot({
#     invalidateLater(1000, session)
#     update_data()
#     data[1:30] %>%
#       ggvis(~1:30, ~agrCtlNoise) %>%
#       layer_lines() %>%
#       layer_points() %>%
#       scale_numeric("x", domain = c(1, 30)) %>% 
#       #scale_numeric("y", domain = c(-120, -40)) %>% 
#       set_options(width = 600, height = 240, 
#                  renderer = "canvas") %>%
#       bind_shiny("noise_plot")
#   })
#   
#   output$SNR <- renderPlot({
#     invalidateLater(1000, session)
#     update_data()
#     data[1:10] %>%
#       ggvis(~1:10, ~agrCtlRSSI/agrCtlNoise) %>%
#       layer_lines() %>%
#       layer_points() %>%
#       scale_numeric("x", domain = c(1, 10)) %>% 
#       #scale_numeric("y", domain = c(0, 1)) %>% 
#       set_options(width = 900, height = 240, 
#                   renderer = "canvas") %>%
#       bind_shiny("snr_plot")
#   })

})
