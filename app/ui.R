
library(shiny)
library(shinydashboard)
library(ggvis)

shinyUI(dashboardPage(
  skin = "green",
  dashboardHeader(title = "WiFi dashboard"),
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem(text = "Dashboard",
               tabName = "dashboard",
               icon = icon("dashboard")),
      menuItem(text = "Help",
               tabName = "help",
               icon = icon("question"))
    ),
    actionButton(inputId = "shutdown",
                 label = "Shutdown",
                 icon = icon("close"),
                 width = "100%",
                 class="btn-warning"),
    tags$style(type='text/css', "button#shutdown { position: absolute; bottom: 0; }")
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
#                 tabBox(title = "Info Panel",
#                     width = 4,
#                     tabPanel("Current status",
#                              tableOutput("get_info")),
#                     tabPanel("Preferences",
#                              tableOutput("airport_prefs"))
#                     ),
                box(title = "Plot Panel",
                    width = 8,
                    selectInput("plot_select",
                                label = "Select variable:",
                                choices = c("Signal" = "RSSI",
                                            "Noise" = "NOISE",
                                            "Quality (SNR)" = "snr",
                                            "Distance (meters)" = "distm"),
                                width = "25%"),
                    uiOutput('networks'),
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

