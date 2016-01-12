
library(shiny)
library(shinythemes)
library(data.table)
library(ggvis)
library(magrittr)

shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  
  withTags({
    div(class="header",style = "background-color: #45a15c; height:70px;",
        div(class="container brand", style = "font-size: 40px;",
            a(class="span12", style = "color:white;", "WiFi Dashboard")
        )
    )
  }),
  
  sidebarPanel(
    navbarPage(
      "Summary",
      navbarMenu(
        "Select View",
        tabPanel(
          "Current status",
          tableOutput("get_info")
        ),
        tabPanel(
          "Preferences",
          tableOutput("airport_perfs")
        )
      )
    )
  ),
  
  mainPanel(
    h2("Received Signal Strength Indicator (RSSI)"),
    fluidRow(
      column(12,
             wellPanel(
               HTML("<div style='height: 240px;'>"),
               ggvisOutput("rssi_plot"),
               plotOutput("RSSI"),
               HTML("</div><div style='height: 240px;'>"),
               ggvisOutput("hstgrm_plot"),
               plotOutput("hstgrm"),
               HTML("</div>")
             )
      )
    )
  )
))
