setwd("/Users/kylesaltmarsh/Documents/UWA/Unearthed Hackathon/App")
getwd()
# Read in the file and break into parts
library("data.table")
library(ggplot2)
Healthy_Data <- as.data.table(read.csv('Health Fan.csv'))
Healthy_Data <- cbind(as.data.table(seq(1:dim(Healthy_Data)[1])),Healthy_Data)
colnames(Healthy_Data) <- c("Time","Values")


i = 10
Healthy_Data_Sample <- Healthy_Data[((i-1)*10000):(i*10000),]


    plot3 <-ggplot() + 
      geom_line(aes(Time,Values), Healthy_Data_Sample, colour="gray20") +
      labs(x = "Time", y = "Acoustic Output") + 
      theme(text = element_text(size=32),
            axis.text.x = element_text(angle=90, hjust=1)) +
      theme(text = element_text(size=32),
            axis.text.y = element_text(angle=0, hjust=1)) +
      ggtitle("Tag Time History") + 
      theme(plot.title = element_text(hjust = 0.5, size = 32, face = "bold")) +
      ylim(-6000,6000) +
             theme(axis.title.x=element_blank(),
                   axis.text.x=element_blank(),
                   axis.ticks.x=element_blank())
    

png(filename=paste0("pic",i,".png"),width = 1000, height = 600)
plot3
dev.off()



xfft <- Healthy_Data
xfft[['Values']] <- fft(Healthy_Data[["Values"]])
xfft[['Values']] = sqrt(Re(xfft[['Values']] )^2 + (Im(xfft[['Values']] )^2))

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








observeEvent(input$reset,{
  
  withProgress(message = 'Plotting Data', value = 0, {
    
    setProgress(value = 1/3)
    
    if (input$equipment=="Fin Fan 1") {
      Healthy_Data <- as.data.table(read.csv('Health Fan.csv'))
      Healthy_Data <- cbind(as.data.table(seq(1:dim(Healthy_Data)[1])),Healthy_Data)
    }
    
    if (input$equipment=="Fin Fan 2") {
      Healthy_Data <- as.data.table(read.csv('Unhealth Fan.csv'))
      Healthy_Data <- cbind(as.data.table(seq(1:dim(Healthy_Data)[1])),Healthy_Data)
    }
    
    colnames(Healthy_Data) <- c("Time","Values")
    
    Healthy_Data_Sample <- Healthy_Data[0:10000,]
    
    setProgress(value = 2/3)
    
    i = 1
    
    Healthy_Data_Sample <- Healthy_Data[((i-1)*10000):(i*10000),]
    
    plot2 <-ggplot() + 
      geom_line(aes(Time,Values), Healthy_Data_Sample, colour="gray20") +
      labs(x = "Time", y = "Acoustic Output") + 
      theme(text = element_text(size=32),
            axis.text.x = element_text(angle=90, hjust=1)) +
      theme(text = element_text(size=32),
            axis.text.y = element_text(angle=0, hjust=1)) +
      ggtitle("Tag Time History") + 
      theme(plot.title = element_text(hjust = 0.5, size = 32, face = "bold")) +
      ylim(-6000,6000) +
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank())
    
    
    output$plot1 = renderPlot({plot2})
    
    i = 1 + 1
    
    
    setProgress(value = 3/3)
    
    
    
  })
  
})



observeEvent(input$reset,{
  
  if (input$equipment=="Fin Fan 1") {
    values$data <- as.data.table(read.csv('Health Fan.csv'))
    values$data <- cbind(as.data.table(seq(1:dim(values$data)[1])),values$data)
  }
  
  if (input$equipment=="Fin Fan 2") {
    values$data <- as.data.table(read.csv('Unhealth Fan.csv'))
    values$data <- cbind(as.data.table(seq(1:dim(values$data)[1])),values$data)
  }
  
  for (i in i:10) {
    
    values$dataSample <- as.data.table(values$data[((i-1)*10000):(i*10000),])
    Sys.sleep(3)
    
  }
  
  
})

click2 = reactive({
  
  colnames(values$dataSample) <- c("Time","Values")
  plot2 <-ggplot() + 
    geom_line(aes(Time,Values), values$dataSample, colour="gray20") +
    labs(x = "Time", y = "Acoustic Output") + 
    theme(text = element_text(size=32),
          axis.text.x = element_text(angle=90, hjust=1)) +
    theme(text = element_text(size=32),
          axis.text.y = element_text(angle=0, hjust=1)) +
    ggtitle("Tag Time History") + 
    theme(plot.title = element_text(hjust = 0.5, size = 32, face = "bold")) +
    ylim(-6000,6000) +
    theme(axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank())
  
  return(plot2)
  
})

output$plot1 = renderPlot({click2()})


