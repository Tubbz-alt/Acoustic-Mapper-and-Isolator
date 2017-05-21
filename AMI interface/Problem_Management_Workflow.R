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


Problem_Management_WorkflowUI <- function(id){
  
  ns <- NS(id)
  
  fluidPage(
    headerPanel('Equipment Time History'),
    br(),
    fluidRow(column(3, uiOutput(ns('equipment'))),
             # column(3,htmlOutput(ns("text2"))),
             column(3, uiOutput(ns('predictedfault'))),
             column(3, htmlOutput(ns("text1"))),
             column(3, img(src='Unhealthy.png', align = "centre",height = '50px', width = '50px'))
             #column(3, img(src='Healthy.png', align = "centre",height = '50px', width = '50px'))
    ),fluidRow(
      column(6,plotOutput(ns('plot1'))),
      column(6,plotOutput(ns('plot2')))
    )
  )
  
}

#-----------------------------------------------------------------------------------------#
# Module function
#-----------------------------------------------------------------------------------------#


Problem_Management_Workflow <- function(input, output, session, vals = NULL) {
  
  values <- reactiveValues()
  
  ns <- session$ns
  
  output$text1 <- renderUI({
    h3(HTML("Status: Abnormal"))
    #h3(HTML("Status: Normal"))
  })
  
  # output$text2 <- renderUI({
  #   h3(HTML(""))
  # })
  
  output$predictedfault = renderUI({
    selectInput(ns('predictedfault'), 'Predicted Fault', c("Obstruction"), selected = "Obstruction")
  })
  
  
  
  output$equipment = renderUI({
    selectInput(ns('equipment'), 'Equipment ID', c("Fan 1","Fan 2"), selected = "Fan 1")
  })
  
  autoInvalidate <- reactiveTimer(2000, session)
  
  output$plot1 <- renderPlot({
    autoInvalidate()
    i <- sample(1:10,1)
 
    #plot(vals$please[((i-1)*10000):(i*10000),1],vals$please[((i-1)*10000):(i*10000),2])
    Healthy_Data_Sample <- as.data.frame(vals$please[((i-1)*40000):(i*40000),])
    Healthy_Data_Sample <- cbind(as.data.table(seq(1:dim(Healthy_Data_Sample)[1])),Healthy_Data_Sample)
    colnames(Healthy_Data_Sample) <- c("Time","Values")
    plot2 <-ggplot() + 
      geom_line(aes(Time,Values), Healthy_Data_Sample, colour="gray20") +
      labs(x = "Time", y = "Acoustic Output") + 
      theme(text = element_text(size=32),
            axis.text.x = element_text(angle=90, hjust=1)) +
      theme(text = element_text(size=32),
            axis.text.y = element_text(angle=0, hjust=1)) +
      ggtitle("Time History") + 
      theme(plot.title = element_text(hjust = 0.5, size = 32, face = "bold")) +
      ylim(-10000,10000) +
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank())+
      theme(axis.text.y=element_blank(),
            axis.ticks.y=element_blank())
    
    plot2 = plot2 + theme(
      panel.background = element_rect(fill = "transparent") # bg of the panel
      , plot.background = element_rect(fill = "transparent") # bg of the plot
      , panel.grid.major = element_blank() # get rid of major grid
      , panel.grid.minor = element_blank() # get rid of minor grid
      , legend.background = element_rect(fill = "transparent") # get rid of legend bg
      , legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
    )
    
    plot2

  })
  
  output$plot2 <- renderPlot({
    autoInvalidate()
    i <- sample(1:10,1)

    xfft <- as.data.frame(vals$please[((i-1)*40000):(i*40000),])
    xfft <- cbind(as.data.table(seq(1:dim(xfft)[1])),xfft)
    colnames(xfft) <- c("Time","Values")
    xfft[['Values']] <- fft(xfft[["Values"]])
    xfft[['Values']] <- sqrt(Re(xfft[['Values']] )^2 + (Im(xfft[['Values']] )^2))
    xfft[['Values']] <- 10*log(xfft[['Values']],10)
    
    xfft_sample = as.data.table(xfft[0:5000])
    
    plot3 <-ggplot() + 
      geom_line(aes(Time,Values), xfft_sample, colour="gray20") +
      labs(x = "Time", y = "Acoustic Output") + 
      theme(text = element_text(size=32),
            axis.text.x = element_text(angle=90, hjust=1)) +
      theme(text = element_text(size=32),
            axis.text.y = element_text(angle=0, hjust=1)) +
      ggtitle("Frequency Spectrum") + 
      theme(plot.title = element_text(hjust = 0.5, size = 32, face = "bold")) +
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank()) +
      theme(axis.text.y=element_blank(),
            axis.ticks.y=element_blank())
    
    
    plot3 = plot3 + theme(
      panel.background = element_rect(fill = "transparent") # bg of the panel
      , plot.background = element_rect(fill = "transparent") # bg of the plot
      , panel.grid.major = element_blank() # get rid of major grid
      , panel.grid.minor = element_blank() # get rid of minor grid
      , legend.background = element_rect(fill = "transparent") # get rid of legend bg
      , legend.box.background = element_rect(fill = "transparent",colour = NA) # get rid of legend panel bg
    )
    
    plot3
    
  })
  
      
    
  
}

# #-----------------------------------------------------------------------------------------#
# # End of code
# #
# # Email for help:
# # kyle.saltmarsh@woodside.com.au
# #-----------------------------------------------------------------------------------------#