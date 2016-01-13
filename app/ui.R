
library(shiny)
library(shinydashboard)
library(data.table)
library(ggvis)
library(magrittr)

shinyUI(dashboardPage(
  skin = "green",
  dashboardHeader(title = "WiFi dashboard"),
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Help", tabName = "help", icon = icon("question"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
                box(title = h4("Current status"),
                    width = 4,
                    tableOutput("get_info")),
                
                box(title = h4("Plot"),
                    width = 8,
                    selectInput("plot_select",
                                label = "",
                                choices = c("Signal" = "agrCtlRSSI",
                                            "Noise" = "agrCtlNoise",
                                            "Quality (SNR)" = "snr",
                                            "Distance (meters)" = "distm")),
                    HTML("<div style='height: 400px;'>"),
                    ggvisOutput("dbm_plot"),
                    plotOutput("dbm"),
                    HTML("</div>"))
                )
              ),
      tabItem(tabName = "help",
              fluidRow(
                includeMarkdown("assets/help.md")
              ))
    )
  )
))

# shinyUI(fluidPage(
#   theme = shinytheme("flatly"),
#   
#   withTags({
#     div(class="header",style = "background-color: #45a15c; height:70px;",
#         div(class="container brand", style = "font-size: 40px;",
#             a(class="span12", style = "color:white;", "WiFi Dashboard")
#         )
#     )
#   }),
#   
#   sidebarPanel(
#     navbarPage(
#       "Menu",
#       tabPanel("Info",
#                "Insert help informatio here."),
#       navbarMenu(
#         "Select View",
#         tabPanel(
#           "Current status",
#           tableOutput("get_info")
#         ),
#         tabPanel(
#           "Preferences",
#           tableOutput("airport_perfs")
#         )
#       )
#     )
#   ),
#   
#   mainPanel(
#     h2("Received Signal Strength Indicator (RSSI)"),
#     fluidRow(
#       column(12,
#              wellPanel(
#                HTML("<div style='height: 240px;'>"),
#                ggvisOutput("rssi_plot"),
#                plotOutput("RSSI"),
#                HTML("</div><div style='height: 240px;'>"),
#                ggvisOutput("hstgrm_plot"),
#                plotOutput("hstgrm"),
#                HTML("</div>")
#              )
#       )
#     )
#   )
#))
