
library(shiny)
library(shinydashboard)
library(ggvis)

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
                box(title = h3("Current status"),
                    width = 4,
                    tableOutput("get_info")),
                
                box(title = h3("Plot"),
                    width = 8,
                    selectInput("plot_select",
                                label = "Select variable:",
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

