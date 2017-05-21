#-----------------------------------------------------------------------------------------#
# Kyle Saltmarsh
#
# Anaylse decision support Main
#
# Email for help:
# kyle.saltmarsh@woodside.com.au
#-----------------------------------------------------------------------------------------#
# Aim
#
# Main function
#
#-----------------------------------------------------------------------------------------#



#-----------------------------------------------------------------------------------------#
# ADS function
# Takes data table of [inputs,response, prediction, residual]

# Need to edit code to import full data residual or take in whisker limits
# Need to take code to import new data set
# Is the residual a single column or double with time stamp
# Decision control -> use average violations?

ADS_EWMA <- function(New_Data,   # New data for analyser
                     analyser,
                     Outlier_Confidence = 3,
                     Window_Length = 60, # 1 Hour 
                     EWMA0 = 0) { # 0 by default
  
  

source("UbeRVersion/EWMAFull.R")
  
#-----------------------------------------------------------------------------------------#
# Check if there is maintenance on this day


# If there is a maintenance on this day, fill in with NAs
# problem -> not recorded well, so might get rid of good data and keep bad data
# Use filter limits as paramaters, trained from full data set

Prediction_Column <- paste0(analyser, "_Prediction_0")
Residual_Column <- paste0(analyser, "_Residual")

# data_stream <- New_Data[[Residual_Column]][324083:424082]
residual_data_stream <- New_Data[,c("TAGDATE",Residual_Column), with=FALSE]

# real output
output_data_stream <- New_Data[,c("TAGDATE",analyser), with=FALSE]

# Boxplot analysis (using quartile ranges)
Full_Residual_Data_Boxplot <- boxplot(output_data_stream[[analyser]], range = Outlier_Confidence) 

# Outlier limits
Outlier_Limits <- Full_Residual_Data_Boxplot$stats[c(1,5),]

# Should these be hard coded values?
output_data_stream[[analyser]][output_data_stream[[analyser]]<Outlier_Limits[1]] <- NA
output_data_stream[[analyser]][output_data_stream[[analyser]]>Outlier_Limits[2]] <- NA

indexes <- which(is.na(output_data_stream[[analyser]]))

# Remove residual
residual_data_stream[[Residual_Column]][indexes] <- NA
residual_data_stream[[Residual_Column]][indexes] <- NA

EWMARuleOutput <- Apply_ADS_EWMA_Rules(residual_data_stream, 
                                       EWMA_Window_Size = Window_Length,
                                       EWMA_Lambda = 0.3, 
                                       Control_Limit_N_Sigma = 1,
                                       EWMA_Target = EWMA0)


return(EWMARuleOutput)

}

#-----------------------------------------------------------------------------------------#
# End of code
#
# Email for help:
# kyle.saltmarsh@woodside.com.au
#-----------------------------------------------------------------------------------------#