
library(shiny)
library(data.table)
library(ggvis)
library(magrittr)

rm(list = ls(all.names = TRUE))

source(file = "../functions/foo.R")

data <- perform_scan()

shinyServer(function(input, output, session){

  # Update data
  update_data <- function(){
    data <<- rbind(perform_scan(), data, fill=TRUE)
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
  }, include.colnames = FALSE)
  
  output$current_time <- renderText({
    invalidateLater(1000, session)
    format(Sys.time(), "%d %h %Y %H:%M:%S")
  })
  
  output$dbm <- renderPlot({
    invalidateLater(1000, session)
    update_data()
    data[, yvar := get(input$plot_select)] %>%
      ggvis(~Time*60, ~yvar) %>%
      layer_lines(stroke = ~factor(BSSID)) %>%
      layer_points(fill = ~factor(BSSID)) %>%
      scale_datetime("x", nice = "second", label = "Time") %>%
      scale_numeric("y", expand = 0.25, nice = TRUE, label = "dBm") %>% 
      add_legend("stroke", title = "Access points (BSSID)") %>%
      hide_legend("fill") %>%
      set_options(renderer = "svg") %>%
      bind_shiny("dbm_plot")
  })
  
  output$hstgrm <- renderPlot({
    invalidateLater(1000, session)
    data[complete.cases(data)] %>%
      data.frame %>% 
      ggvis(~agrCtlRSSI) %>%
      layer_histograms() %>%
      set_options(height = 340, renderer = "svg") %>%
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
