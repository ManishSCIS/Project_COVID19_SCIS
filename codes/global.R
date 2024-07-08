library(data.table)
library(sf)
library(spdep)
library(tmap)
library(tidyverse)
library(dplyr)
library(dbplyr)
library(ggplot2)
library(tidyr)
library(plotly)
library(readr)
library(leaflet)
library(lubridate)
library(tsfgrnn)
library(forecast)
library(vars)
library(fpp2)
library(rsconnect)


#devtools::install_github("tidyverse/dbplyr")

#devtools::install_version("dbplyr", "2.3.1")

#######################################Data Sets################################
# data set1:State-wise Daily data
#url<- "https://raw.githubusercontent.com/ManishSCIS/Project_COVID19_SCIS/main/dataset1.csv"

dataset1<-fread("https://raw.githubusercontent.com/ManishSCIS/Project_COVID19_SCIS/main/dataset1.csv")
dataset1<-data.frame(dataset1)
#class(dataset1)

# data set2: Aggregated Data for each state/UT
dataset2 <- fread("https://raw.githubusercontent.com/ManishSCIS/Project_COVID19_SCIS/main/dataset2.csv")
dataset2<-data.frame(dataset2)


# daily state-wise raw data set
rawdata1 <- read.csv("https://raw.githubusercontent.com/ManishSCIS/Project_COVID19_SCIS/main/state_wise_daily.csv")
rawdata1<-data.frame(rawdata1)

# Only state names
rw<-dataset2[,c(1)]

##########################-----Add Data file For GRNNN-----####################
# Date column correction
dataset1$Date<-ymd(dataset1$Date)

# Making date order ascending
mydata<- dataset1 %>% 
  dplyr::select(1,4,5,6) %>% 
  arrange(dataset1$Date) %>% 
  filter(dataset1$State=="Total")

# Time Series Format
ts.data<-ts(mydata$Confirmed)

###############################################################################
# State Boundary Data set upload
# Renaming columns for truncated column names
#s1<-st_read("C:/Users/Scisjnu/Documents/R_Project/data/data_moran.shp")
s1<-st_read("data/data_moran.shp")

#s2<-st_read("data/custom_data.shp")

#s2<-st_read("C:/Users/Scisjnu/Documents/CoSymple_R/data/custom_data.shp")
#s1<-st_read("C:/Users/Scisjnu/Documents/CoSymple_R/data_moran.shp")

colnames(s1)[3] <- "Latitude"
colnames(s1)[4] <- "Longitude"
colnames(s1)[5] <- "State_code"
colnames(s1)[6] <- "Confirmed"
colnames(s1)[7] <- "Recovered"
colnames(s1)[10] <- "Migrated_Other"

########################For Dashboard Tab#######################################
###################Value Box Data#####################
# conf<-dataset2[1,5]
# dec<-dataset2[1,7]
# act<-dataset2[1,8]
# rec<-dataset2[1,6]

###################### Map############################
leaflet() %>%
  addTiles() %>% 
  fitBounds(64,5,97,36) %>%
  addAwesomeMarkers(lng = dataset2[-1,]$Longitude, lat = dataset2[-1,]$Latitude, 
                    popup = paste0("<h3>",dataset2[-1,]$State, "<h3>",
                                   "<table style='width:50%'>",
                                   "<tr>",
                                   "<th>Total Cases</th>",
                                   "<th>",dataset2[-1,]$Confirmed,"</th>",
                                   "<tr>",
                                   
                                   "<tr>",
                                   "<tr>",
                                   "<th>Recovered</th>",
                                   "<th>",dataset2[-1,]$Recovered,"</th>",
                                   "<tr>",
                                   
                                   "<tr>",
                                   "<tr>",
                                   "<th>Deaths</th>",
                                   "<th>",dataset2[-1,]$Deaths,"</th>",
                                   "<tr>",
                                   
                                   "<tr>",
                                   "<tr>",
                                   "<th>Active</th>",
                                   "<th>",dataset2[-1,]$Active,"</th>",
                                   "<tr>"
                    ))
#################Top 5 States#######################
topdf2<-dataset2 %>% 
  arrange(desc(Confirmed)) %>% 
  dplyr::select(1,4:8)
topdf2 <- topdf2[2:6,]

bplot5<-plot_ly(topdf2, x=~State, y=~Active,width=500, type = 'bar',name = 'Active',color=I('orange'))%>%
  add_trace(y=~Deaths, name='Deceased',color=I('red'))%>%
  add_trace(y=~Recovered, name='Recovered',color=I('green'))%>%
  add_trace(y=~Confirmed, name='Confirmed',color=I('blue'))%>%
  layout( #title="Top 5 State Statistics",
    xaxis = list(title = "States", color ="black", tickangle = 20),
    yaxis = list(title = 'Case Count'), barmode = 'group',
    legend=list(x=0,y=1.2, orientation='h'))

################Bar Plot For All States\UTs
#data = dataset2
bplot.all<-plot_ly(dataset2, x=~State_code, y=~Active, type = 'bar',name = 'Active',color=I('orange'))%>%
  add_trace(y=~Deaths, name='Deceased',color=I('red'))%>%
  add_trace(y=~Recovered, name='Recovered',color=I('green'))%>%
  add_trace(y=~Confirmed, name='Confirmed',color=I('blue'))%>%
  layout(#title="State-wise Bar Chart", 
    xaxis = list(title = "State-codes", color ="black", tickangle = 0),
    yaxis = list(title = 'Case Count'), barmode = 'group',
    legend=list(x=0,y=1.2, orientation='h'))

###########################  India Trend Plot #######################
df<- dataset1 %>% 
  filter(dataset1$State=='Total')

p1<-plot_ly(x = as.Date(df$Date), y = df$Confirmed,width = 1000, type = 'scatter', mode = 'lines', name = 'Confirmed')%>%
  add_trace(x=as.Date(df$Date), y = df$Recovered,type = 'scatter', mode = 'lines',name='Recovered') %>%
  add_trace(x = as.Date(df$Date), y = df$Deceased, type = 'scatter', mode = 'lines', name = 'Deceased')%>%
  layout(#title = 'COVID-19 Cases India', 
    plot_bgcolor='#ffff',  
    xaxis = list( zerolinewidth = 2,gridcolor = 'ffff'),  
    yaxis = list(title = 'Case Counts',zerolinewidth = 2,gridcolor = 'ffff'),
    showlegend = TRUE )%>%
  layout(legend=list(x=0.1,y=1, orientation='h'))

############################## Moran Spatial Plots###################
################## Change in data from S1 to S2 #####################
# conf.map<-tm_shape(s1)+
#   tm_fill(col="Confirmed", style="jenks", n=10, palette = "Blues")+
#   tm_legend(outside=TRUE)+
#   tm_borders(lty ="solid")+
#   tmap_options(check.and.fix = TRUE)
# 
# 
# rec.map<-tm_shape(s1)+
#   tm_fill(col="Recovered", style="jenks", n=10, palette = "Greens")+
#   tm_legend(outside=TRUE)+
#   tm_borders(lty ="solid")+
#   tmap_options(check.and.fix = TRUE)
# 
# dec.map<-tm_shape(s1)+
#   tm_fill(col="Deaths", style="jenks", n=10, palette = "Reds")+
#   tm_legend(outside=TRUE)+
#   tm_borders(lty ="solid")+
#   tmap_options(check.and.fix = TRUE)
# 
# act.map<-tm_shape(s1)+
#   tm_fill(col="Active", style="jenks", n=10, palette = "Oranges")+
#   tm_legend(outside=TRUE)+
#   tm_borders(lty ="solid")+
#   tmap_options(check.and.fix = TRUE)

#############################################################################
#                               Monte Carlo - Moran Index

# Defining neighboring polygons

nb<- poly2nb(s1, queen = TRUE)

# Assign weights to the neighbors
lw<-nb2listw(nb, style="W", zero.policy = TRUE)
#print(lw, zero.policy = TRUE)


#Compute the neighbor mean confirmed values
conf.lag<- lag.listw(lw, s1$Confirmed, NAOK = TRUE, zero.policy = TRUE,
                     na.action=na.rm)
#Compute the neighbor mean recovered values
rec.lag<- lag.listw(lw, s1$Recovered, NAOK = TRUE, zero.policy = TRUE,
                    na.action=na.rm)
#Compute the neighbor mean death values
dec.lag<- lag.listw(lw, s1$Deaths, NAOK = TRUE, zero.policy = TRUE,
                    na.action=na.rm)


################################ Monte - Carlo Simulation ####################
####### Calculation of the moran's I Statistics
I<-moran(s1$Confirmed, lw, length(nb), Szero(lw)[1], zero.policy = TRUE)[1]
MonteC<- moran.mc(s1$Confirmed, lw, nsim = 999, alternative = "greater", 
                  na.action=na.fail, spChk = NULL, adjust.n = TRUE, zero.policy = TRUE)

I2<-moran(s1$Recovered, lw, length(nb), Szero(lw)[1], zero.policy = TRUE)[1]
MonteC2<- moran.mc(s1$Recovered, lw, nsim = 999, alternative = "greater", 
                   na.action=na.fail, spChk = NULL, adjust.n = TRUE, zero.policy = TRUE)

I3<-moran(s1$Deaths, lw, length(nb), Szero(lw)[1], zero.policy = TRUE)[1]
MonteC3<- moran.mc(s1$Deaths, lw, nsim = 999, alternative = "greater", 
                   na.action=na.fail, spChk = NULL, adjust.n = TRUE, zero.policy = TRUE)


