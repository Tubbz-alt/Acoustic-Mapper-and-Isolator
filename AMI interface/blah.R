library(shiny)

runApp(list(
  ui = pageWithSidebar(    
    
    headerPanel("Hello Shiny!"),
    
    sidebarPanel(
      sliderInput("obs", 
                  "Number of observations:", 
                  min = 1,
                  max = 1000, 
                  value = 500)
    ),
    
    mainPanel(
      plotOutput("distPlot")
    )
  ),
  server =function(input, output, session) {
    autoInvalidate <- reactiveTimer(5000, session)
    output$distPlot <- renderPlot({
      autoInvalidate()
      # generate an rnorm distribution and plot it
      dist <- rnorm(input$obs)
      hist(dist)
    })
    
  }
))