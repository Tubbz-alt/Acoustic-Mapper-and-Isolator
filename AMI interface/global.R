# Use 
suppressMessages(library("data.table"))
suppressMessages(library("gdata"))
suppressMessages(library("corrplot"))
suppressMessages(library("igraph"))
suppressMessages(library("shiny"))
suppressMessages(library("shinydashboard"))
suppressMessages(library(zoo))
suppressMessages(library(httr))
suppressMessages(library(scales))
suppressMessages(library(ggplot2))
suppressMessages(library(DT))
suppressMessages(library(reshape2))
suppressMessages(library(glmnet))


source("ResidualAnalysis.R")
source("Problem_Management_Workflow.R")
source('CheckInputs.R')
source('CheckModel.R')

htmlegend <- function(legend, col, title=NULL){
  # If the legend and cols are not the same length then return NULL
  if (length(legend) != length(col)){
    return(NULL)
  }
  
  string <- "<div class='my-legend'>"
  
  if(!is.null(title)){
    temp <- sprintf("<div class='legend-title'>%s</div>",title)
    string <- paste(string, temp)
  }
  
  string <- paste(string, "<div class='legend-scale'> <ul class='legend-labels'>")
  
  for(i in 1:length(legend)){
    temp <- sprintf("<li><span style='background:%s;'></span>%s</li>", substr(col[i],1,7), legend[i])
    string <- paste(string, temp)
  }
  
  string <- paste(string, "</ul>
               </div>
               </div>
                  
                  <style type='text/css'>
                  .my-legend .legend-title {
                  text-align: left;
                  margin-bottom: 5px;
                  font-weight: bold;
                  font-size: 90%;
                  }
                  .my-legend .legend-scale ul {
                  margin: 0;
                  margin-bottom: 5px;
                  padding: 0;
                  list-style: none;
                  }
                  .my-legend .legend-scale ul li {
                  font-size: 80%;
                  list-style: none;
                  margin-left: 0;
                  line-height: 18px;
                  margin-bottom: 2px;
                  }
                  .my-legend ul.legend-labels li span {
                  display: block;
                  float: left;
                  height: 16px;
                  width: 30px;
                  margin-right: 5px;
                  margin-left: 0;
                  border: 1px solid #999;
                  }
                  .my-legend .legend-source {
                  font-size: 70%;
                  color: #999;
                  clear: both;
                  }
                  .my-legend a {
                  color: #777;
                  }
                  </style>")
  
  this <- HTML(string)

  
  return(this)
}