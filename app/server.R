
library(shiny)
library(data.table)
library(ggvis)
library(magrittr)

rm(list = ls(all.names = TRUE))

source(file = "../functions/foo.R")
source(file = "../functions/scan.R")

data <- perform_scan()

shinyServer(function(input, output, session){

  # Update data
  update_data <- function(){
    try({
      data <<- rbindlist(list(perform_scan(), data), fill=TRUE)
    })
  }
  
  output$airport_prefs <- renderTable({
    # `$ airport prefs`
    # Get the current wireless preferences
    # Assume the user isn't going to change these so don't update frequently
    invalidateLater(5000, session)
    get_preferences()
  })
  
  output$get_info <- renderTable({
    # `$ airport --getinfo`
    # Display current status
    invalidateLater(5000, session)
    data[1,] %>% t
  }, include.colnames = FALSE)
  
  output$current_time <- renderText({
    invalidateLater(5000, session)
    format(Sys.time(), "%d %h %Y %H:%M:%S")
  })
  
  output$networks <- renderUI({
    selectInput("network_select",
                label = "Choose network:",
                choices =data[,sort(unique(SSID_STR))],
                width = "45%")
  })
  
  output$dbm <- renderPlot({
    invalidateLater(5000, session)
    update_data()
    data[(Time >= (max(Time) - 120000.0)) & (SSID_STR == input$network_select)] %>%
      .[, yvar := get(input$plot_select)] %>%
      ggvis(~Time, ~yvar, fill = ~BSSID, stroke = ~BSSID) %>%
      layer_points(size = 0.5) %>%
      scale_datetime("x", nice = "second", label = "Time (second)") %>%
      scale_numeric("y", expand = 0.25, nice = TRUE, label = plot_labeller(input$plot_select)[[1]]) %>% 
      #add_legend("stroke", title = "Access points (BSSID)") %>%
      #hide_legend("fill") %>%
      set_options(height = 400, renderer = "svg") %>%
      bind_shiny("dbm_plot")
  })
  
#   output$reproject <- renderPlot({
#     invalidateLater(5000, session)
#     update_data()
#     x <- dcast(data, BSSID + SSID_STR ~ Time, value.var = "distm")
#     nams <- x$SSID_STR
#     d <- x[complete.cases(x), !c("BSSID", "SSID_STR"), with=FALSE] %>%
#       dist(., method = "euclidean", upper = TRUE)
#     k <- cmdscale(d, k = 2)
#     plot(k, asp=1, las=1)
#     text(k, nams)
#   })
  output$reproject <- renderTable({
    invalidateLater(5000, session)
    update_data()
    x <- dcast(data, BSSID + SSID_STR ~ Time, value.var = "distm")
    nams <- x$SSID_STR
    d <- x[complete.cases(x), !c("BSSID", "SSID_STR"), with=FALSE] %>%
      dist(., method = "euclidean", upper = TRUE) %>%
      as.matrix
    #rownames(d) = x$BSSID
    #colnames(d) = x$BSSID
    print(d)
  })
  
  observe({
    if(input$shutdown){
      stopApp(0)
    }
  })

})
