
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
    data[Time >= (max(Time) - 120000.0)] %>%
      .[, yvar := get(input$plot_select)] %>%
      ggvis(~Time, ~yvar) %>%
      layer_points(fill = ~factor(BSSID), size = 0.5) %>%
      layer_lines(stroke = ~factor(BSSID)) %>%
      scale_datetime("x", nice = "second", label = "Time (second)") %>%
      scale_numeric("y", expand = 0.25, nice = TRUE, label = plot_labeller(input$plot_select)[[1]]) %>% 
      add_legend("stroke", title = "Access points (BSSID)") %>%
      hide_legend("fill") %>%
      set_options(height = 400, renderer = "svg") %>%
      bind_shiny("dbm_plot")
  })

})
