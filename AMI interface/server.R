#-----------------------------------------------------------------------------------------#
# Analyser Decision Support Server
#
# Author: Kyle Saltmarsh
# Email: kyle.saltmarsh@woodside.com.au
#
# -----------------------------------------------------------------------------

shinyServer(function(input, output) {
  
#-----------------------------------------------------------------------------------------#
# Reactive Values
#-----------------------------------------------------------------------------------------#

# Values meant to be accessible amongst different functions and modules
vals <- reactiveValues()

#-----------------------------------------------------------------------------------------#

  vals$please <- as.data.frame(read.csv('Health Fan.csv'))

  callModule(ResidualAnalysis, "ResidualAnalysis", vals)
  
  callModule(Problem_Management_Workflow, "Problem_Management_Workflow", vals)

  callModule(CheckInputs, "CheckInputs", vals)
  
  callModule(CheckModel, "CheckModel", vals)
  
})