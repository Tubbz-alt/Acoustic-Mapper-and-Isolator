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


CheckInputsUI <- function(id){
  
  ns <- NS(id)
  
  fluidPage(
    headerPanel('Check Input Tags'),
    fluidRow(column(3, actionButton(ns('reset'), "Execute")),
             column(3, uiOutput(ns('Control_Level'))),
             column(3, uiOutput(ns('Tags')))
    ),
    br(),
    plotOutput(ns('plot1')),
    br(),
    dataTableOutput(ns('table1'))
  )
  
  
}

#-----------------------------------------------------------------------------------------#
# Module function
#-----------------------------------------------------------------------------------------#


CheckInputs <- function(input, output, session, vals = NULL) {
  
  values <- reactiveValues()
  
  ns <- session$ns
  
  output$Control_Level = renderUI({
    selectInput(ns('Control_Level'), 'Control_Level', c(1,1.25,1.5,1.75,2), selected = 1.5)
  })
  
  observeEvent(input$reset,{
    
    withProgress(message = 'Loading Data', value = 0, {
      
      New_Data <- vals$Full_Data[TAGDATE >= vals$Start_Date & TAGDATE <= vals$End_Date]
      
      setProgress(value = 1/3)
      
      values$CheckInputs <- ADS_Check_Inputs(New_Data,
                                                     vals$analyser,
                                                     input$Control_Level)
      
      setProgress(value = 2/3)
    
      output$table1 = renderDataTable(values$CheckInputs$Table,options = list(pageLength = 25))
      
      output$Tags = renderUI({
        selectInput(ns('Tags'), 'Tags', values$CheckInputs$Tags_To_Investigate, selected =values$CheckInputs$Tags_To_Investigate[1])
      })
      
      setProgress(value = 3/3)
      
    })
    
  })
  
  observeEvent(input$Tags,{
    
    withProgress(message = 'Plotting Data', value = 0, {
      
      setProgress(value = 1/3)
      
      Old_Data <- vals$Full_Data[TAGDATE < vals$Start_Date]               
      New_Data <- vals$Full_Data[TAGDATE >= vals$Start_Date & TAGDATE <= vals$End_Date]
      
      setProgress(value = 2/3)

      df <- data.frame("Date" = Old_Data[[1]],"Output" = Old_Data[[input$Tags]])
      df <- df[seq(1,dim(df)[1],10),]
      df2 <- data.frame("Date" = New_Data[[1]],"Output" = New_Data[[input$Tags]])
      
      print(df[1:10,1])
      print(class(df[1:10,1]))
      
      TagPlot <-ggplot() + 
        geom_point(aes(Date, Output), df, colour="gray20") +
        geom_point(aes(Date, Output), df2, colour="red") +
        theme_bw() +
        labs(x = "Date", y = "Output") + 
        theme(text = element_text(size=20),
              axis.text.x = element_text(angle=90, hjust=1)) +
        theme(text = element_text(size=20),
              axis.text.y = element_text(angle=0, hjust=1)) +
        ggtitle("Tag Time History") + 
        theme(plot.title = element_text(hjust = 0.5, size = 24, face = "bold")) +
        ylim(mean(df$Output) - 1*sd(df$Output),mean(df$Output) + 1*sd(df$Output))

      output$plot1 = renderPlot({TagPlot})
      
      
      setProgress(value = 3/3)
      
      
      
    })
    
  })

  
}

#-----------------------------------------------------------------------------------------#
# Module helper functions
#-----------------------------------------------------------------------------------------#

ADS_Check_Inputs <- function(New_Data,
                             analyser,
                             Control_Level = 1.5) {
  
  #-----------------------------------------------------------------------------------------#
  # Load functions
  
  
  source("QCC_Payload_Generator.R")
  
  #-----------------------------------------------------------------------------------------#
  # Get inputs
  
  Prediction_Column <- paste0(analyser, "_Prediction_0")
  Residual_Column <- paste0(analyser, "_Residual")
  
  New_Input_Data <- New_Data[,!c(analyser,Prediction_Column,Residual_Column),with=FALSE]
  
  # Remove lags
  New_Input_Data <- New_Input_Data[,-grep("LAG",colnames(New_Input_Data)),with=FALSE]
  
  #-----------------------------------------------------------------------------------------#
  # Full data percentage of rule violations
  
  
  Violation_Averages <- as.data.table(readRDS("PGP.111QI001.DACA.PV~AVG_1Min_data_fixed_Violation_Averages.rds"))
  # Violation_Averages <- as.data.table(apply(Violation_Averages,2,as.numeric))
  
  #-----------------------------------------------------------------------------------------#
  # New data percentage of rule violations
  
  
  New_Input_Data_Violations <- data.table(Rule = c(1:9))
  
  for (i in 2:dim(New_Input_Data)[2]) {

    Temp <- Apply_selected_QCC_Rules(New_Input_Data[,c(1,i),with=FALSE])
    New_Input_Data_Violations[,colnames(New_Input_Data)[i] := apply(Temp[,c(2:dim(Temp)[2]),with=FALSE],2,function(y) sum(y)/length(y))]
    
  }
  
  #-----------------------------------------------------------------------------------------#
  # Analyse by comparison with control limits
  # Hard coded if x% greater than average violations
  
  
  Violations_Outside_Average <- New_Input_Data_Violations
  
  for (i in 2:dim(Violation_Averages)[2]) {
    
    Violations_Outside_Average[,colnames(Violation_Averages)[i] := as.numeric(sapply(1:dim(Violation_Averages)[1],function(y) New_Input_Data_Violations[[i]][y] > as.numeric(Control_Level)*Violation_Averages[[i]][y]))]
    
  }
  
  Violations_Outside_Average <- sapply(2:dim(Violations_Outside_Average)[2], function(y) sum(Violations_Outside_Average[[y]]) >= 5)
  Tags_To_Investigate <- colnames(New_Input_Data)[Violations_Outside_Average]
   
  
  Violation_Averages <- Violation_Averages[,-c("Rule"),with=FALSE]
  Violation_Averages <- 100*round(Violation_Averages, digits = 3)
  tags <- colnames(Violation_Averages)
  Violation_Averages <- t(Violation_Averages)
  Violation_Averages <- as.data.table(cbind(tags,Violation_Averages))
  colnames(Violation_Averages) <- c("Tag ID","Rule 1 Average (%)","Rule 2 Average (%)","Rule 3 Average (%)","Rule 4 Average (%)","Rule 5 Average (%)","Rule 6 Average (%)","Rule 7 Average (%)","Rule 8 Average (%)","Rule 9 Average (%)")
  
  New_Input_Data_Violations <- New_Input_Data_Violations[,-c("Rule"),with=FALSE]
  New_Input_Data_Violations <- 100*round(New_Input_Data_Violations, digits = 3)
  New_Input_Data_Violations <- t(New_Input_Data_Violations)
  colnames(New_Input_Data_Violations) <- c("Rule 1 Region (%)","Rule 2 Region (%)","Rule 3 Region (%)","Rule 4 Region (%)","Rule 5 Region (%)","Rule 6 Region (%)","Rule 7 Region (%)","Rule 8 Region (%)","Rule 9 Region (%)")
  
  Total <- as.data.table(cbind(Violation_Averages, New_Input_Data_Violations))
  Total <- Total[,c(1,2,11,3,12,4,13,5,14,6,15,7,16,8,17,9,18,10,19),with=FALSE]
  
  
  Total <- datatable(Total, rownames = FALSE) %>%
    formatStyle(columns = "Tag ID", 
                background = styleEqual(Tags_To_Investigate, rep('red',length(Tags_To_Investigate))))
  
  CIvalues <- list()
  CIvalues$Table <- Total
  CIvalues$Tags_To_Investigate <- Tags_To_Investigate
  
  return(CIvalues)
  
}


#   
#   Final_Data_Table <- data.table("Tag_ID" = Tags_To_Investigate)
#   for (i in 1:9){
#     Final_Data_Table[,paste0("Rule_",i,"_Region") := rep(0,length(Tags_To_Investigate))]
#     Final_Data_Table[,paste0("Rule_",i,"_Average") := rep(0,length(Tags_To_Investigate))]
#   }

#-----------------------------------------------------------------------------------------#



#-----------------------------------------------------------------------------------------#
# End of code
#
# Email for help:
# kyle.saltmarsh@woodside.com.au
#-----------------------------------------------------------------------------------------#