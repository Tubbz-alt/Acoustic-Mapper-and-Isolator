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
    fluidRow(column(3, actionButton(ns('reset'), "Execute")),
             column(3, uiOutput(ns('equipment'))),
             column(3, h3(htmlOutput(ns('health')))),
             column(3, img(src='Healthy.png', align = "centre",height = '50px', width = '50px'))
    ),fluidRow(
      column(6,plotOutput(ns('plot1'))),
      column(6,plotOutput(ns('plot2')))
    ),
    plotOutput(ns('distPlot'))
  )
  
}

#-----------------------------------------------------------------------------------------#
# Module function
#-----------------------------------------------------------------------------------------#


Problem_Management_Workflow <- function(input, output, session, vals = NULL) {
  
  values <- reactiveValues()
  
  values$i = 1
  
  ns <- session$ns
  
  output$equipment = renderUI({
    selectInput(ns('equipment'), 'equipment', c("Fin Fan 1","Fin Fan 2"), selected = "Fin Fan 1")
  })
  
  autoInvalidate <- reactiveTimer(2000, session)
  output$distPlot <- renderPlot({
    autoInvalidate()
    i <- sample(1:10,1)
    plot(vals$please[((i-1)*10000):(i*10000),1],vals$please[((i-1)*10000):(i*10000),2])
  })
  
  observeEvent(input$reset,{
    
    withProgress(message = 'Plotting Data', value = 0, {
      
      setProgress(value = 1/3)
      
      if (input$equipment=="Fin Fan 1") {
        Healthy_Data <- as.data.table(read.csv('Health Fan.csv'))
        Healthy_Data <- cbind(as.data.table(seq(1:dim(Healthy_Data)[1])),Healthy_Data)
        
        output$myImage <- renderImage({
          img(src='Healthy.png', align = "centre",height = '50px', width = '50px')
        })
        
        output$health <- renderUI({
          HTML(paste("<b>","Status: Normal","<b>"))
        })
      }
      
      if (input$equipment=="Fin Fan 2") {
        Healthy_Data <- as.data.table(read.csv('Unhealth Fan.csv'))
        Healthy_Data <- cbind(as.data.table(seq(1:dim(Healthy_Data)[1])),Healthy_Data)
        
        output$myImage <- renderImage({
          img(src='Unhealthy.png', align = "centre",height = '50px', width = '50px')
        })
        
        output$health <- renderUI({
          HTML(paste("<b>","Status: Abnormal","<b>"))
        })
      }
      
      colnames(Healthy_Data) <- c("Time","Values")
      
      Healthy_Data_Sample <- Healthy_Data[0:10000,]
      
      setProgress(value = 2/3)
      
      
      Healthy_Data_Sample <- Healthy_Data[((i-1)*10000):(i*10000),]
      
      plot2 <-ggplot() + 
        geom_line(aes(Time,Values), Healthy_Data_Sample, colour="gray20") +
        labs(x = "Time", y = "Acoustic Output") + 
        theme(text = element_text(size=32),
              axis.text.x = element_text(angle=90, hjust=1)) +
        theme(text = element_text(size=32),
              axis.text.y = element_text(angle=0, hjust=1)) +
        ggtitle("Time History") + 
        theme(plot.title = element_text(hjust = 0.5, size = 32, face = "bold")) +
        ylim(-6000,6000) +
        theme(axis.title.x=element_blank(),
              axis.text.x=element_blank(),
              axis.ticks.x=element_blank())+
        theme(axis.text.y=element_blank(),
              axis.ticks.y=element_blank())
      
      
      output$plot1 = renderPlot({plot2})
      
      
      
      xfft <- Healthy_Data
      xfft[['Values']] <- fft(Healthy_Data[["Values"]])
      xfft[['Values']] <- sqrt(Re(xfft[['Values']] )^2 + (Im(xfft[['Values']] )^2))
      xfft[['Values']] <- 10*log(xfft[['Values']],10)
      
      xfft_sample = as.data.table(xfft[0:10000])
      
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
      
      
      plot3
      
      
      output$plot2 = renderPlot({plot3})
      
    })
    
  })
  
  
  
}

#-----------------------------------------------------------------------------------------#
# Module helper functions
#-----------------------------------------------------------------------------------------#



#-----------------------------------------------------------------------------------------#



#-----------------------------------------------------------------------------------------#
# End of code
#
# Email for help:
# kyle.saltmarsh@woodside.com.au
#-----------------------------------------------------------------------------------------#