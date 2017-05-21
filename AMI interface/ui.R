# Unearthed UI -------------------------------------------------------
#
# Author: Kyle Saltmarsh
# Email: kyle.saltmarsh@woodside.com.au
#
# -----------------------------------------------------------------------------

shinyUI(dashboardPage(skin="red",

          # Dashboard Header            
          dashboardHeader(title = "Equipment Acoustics Tool"),

          dashboardSidebar(
            sidebarMenu(
              menuItem("Plant Overview", tabName = "ResidualAnalysis", icon = icon("line-chart")),
              br(),
              menuItem("Monitor Equipment", tabName = "Problem_Management_Workflow", icon = icon("audio-description")),
              br(),
              menuItem("Maintenance Records", tabName = "CheckMaintenance", icon = icon("calendar")),
              menuItem("Alerts", tabName = "CheckModel", icon = icon("bell")),
              menuItem("Record a Fault", tabName = "CheckInputs", icon = icon("cloud-upload"))
            )
          ),
          
          # Dashboard body
          dashboardBody(
            tags$head(
              tags$link(rel = "stylesheet", type = "text/css", href = "default.css")
            ),
            tabItems(
              # First tab content
              tabItem(tabName = "ResidualAnalysis",
                      ResidualAnalysisUI("ResidualAnalysis")),            
              # Second tab content
              tabItem(tabName = "Problem_Management_Workflow",
                      Problem_Management_WorkflowUI("Problem_Management_Workflow")),
              tabItem(tabName = "CheckInputs",
                      CheckInputsUI("CheckInputs")),
              tabItem(tabName = "CheckModel",
                      CheckModelUI("CheckModel"))

          )
              

    )
)
)
