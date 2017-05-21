#-----------------------------------------------------------------------------------------#
# Kyle Saltmarsh
#
# Module UI Company MeetingAnalysis
#
# Email for help:
# kyle.saltmarsh@woodside.com.au
#-----------------------------------------------------------------------------------------#



#-----------------------------------------------------------------------------------------#
# Module UI
#-----------------------------------------------------------------------------------------#


CheckModelUI <- function(id){
  
  ns <- NS(id)
  
  fluidPage(
    headerPanel('Respond to Alert'),
    htmlOutput(ns("text1")),
    uiOutput(ns('alert')),
    br(),
    htmlOutput(ns("text2")),
    uiOutput(ns('fault')),
    br(),
    br(),
    actionButton("load1", "Upload", width ='50%')
  )
  
  
}

#-----------------------------------------------------------------------------------------#
# Module function
#-----------------------------------------------------------------------------------------#


CheckModel <- function(input, output, session, vals = NULL) {
  
  values <- reactiveValues()
  
  ns <- session$ns
  
  output$alert = renderUI({
    selectInput(ns('alert'), 'Was the alert correct?', c("","Yes","Yes - Incorrect Diagnosis","No - False Alert"), selected = "")
  })

  output$text1 <- renderUI({
    h3(HTML(paste("<b>","","<b>")))
  })

  
  
  observeEvent(input$alert, {
    
    if(input$alert == "Yes - Incorrect Diagnosis"){
      output$fault = renderUI({
        selectInput(ns('fault'), 'Fault Type', c("","Obstruction","Unbalanced"), selected = "")
      })
      
      
      output$text2 <- renderUI({
        h3(HTML(paste("<b>","Please provide the correct cause of the alert.","<b>")))
      })
    }
    
  })
  
  
  
}



#-----------------------------------------------------------------------------------------#



#-----------------------------------------------------------------------------------------#
# End of code
#
# Email for help:
# kyle.saltmarsh@woodside.com.au
#-----------------------------------------------------------------------------------------#