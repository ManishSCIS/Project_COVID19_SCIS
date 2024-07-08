function(input, output)
{
  ######################## Information Boxes###################################
  shinydashboard::valueBoxOutput('val_conf')
  output$val_conf<-shinydashboard::renderValueBox({
    conf<-dataset2[1,5]
    shinydashboard::valueBox(conf,"Total Confirmed Cases", color = I('teal')) 
  })
  
  shinydashboard::valueBoxOutput('val_dec')
  output$val_dec<-shinydashboard::renderValueBox({
    dec<-dataset2[1,7]
    shinydashboard::valueBox(dec,"Total Deceased Cases", color = I('red')) 
  })
  
  shinydashboard::valueBoxOutput('val_act')
  output$val_act<-shinydashboard::renderValueBox({
    act<-dataset2[1,8]
    shinydashboard::valueBox(act,"Total Active Cases", color=I('orange')) 
  })
  
  shinydashboard::valueBoxOutput('val_rec')
  output$val_rec<-shinydashboard::renderValueBox({
    rec<-dataset2[1,6]
    shinydashboard::valueBox(rec,"Total Recovered Cases", color=I('green')) 
  })
  
  ############################## Google Map Server Code#########################
  
  output$gmap<-renderLeaflet({
    
    leaflet() %>%
      addTiles() %>% 
      fitBounds(64,5,97,36) %>%
      addAwesomeMarkers(lng = dataset2[-1,]$Longitude, lat = dataset2[-1,]$Latitude, 
                        popup = paste0("<h2>",dataset2[-1,]$State, "<h2>",
                                       "<table style='width:50%'>",
                                       "<tr>",
                                       "<h3>Confirmed</h3>",
                                       "<h4>",dataset2[-1,]$Confirmed,"</h4>",
                                       "<tr>",
                                       
                                       "<tr>",
                                       "<tr>",
                                       "<h3>Recovered</h3>",
                                       "<h4>",dataset2[-1,]$Recovered,"</h4>",
                                       "<tr>",
                                       
                                       "<tr>",
                                       "<tr>",
                                       "<h3>Deaths</h3>",
                                       "<h4>",dataset2[-1,]$Deaths,"</h4>",
                                       "<tr>",
                                       
                                       "<tr>",
                                       "<tr>",
                                       "<h3>Active</h3>",
                                       "<h4>",dataset2[-1,]$Active,"</h4>",
                                       "<tr>"
                                       
                        ))
  })
  ##############################Top-5 State Bar Chart######################
  
  output$top5plot<- renderPlotly({
    bplot5
    
  }) 
  ##############################All State Bar Chart########################
  output$plot1<-renderPlotly({
    bplot.all 
  })
  
  ############################## Dataset2 Table############################
  output$df2<-renderDataTable({
    dataset2 %>% 
      arrange(desc(Confirmed)) %>% 
      dplyr::select(1,4:9)
  })
  
  
  
  
  ###################### Forecast Tab Plots ###############################
  
  output$fig1<-renderPlotly({
    p1  #Plot for India Only
  })
  
  ############COVID-19 Trend ---- State-wise#################
  
  #state_row<- reactive({input$sts}) # Select state drop down output store here
  filtered_df2<-reactive({
    dataset1[dataset1$State==dataset1[input$sts,"State"],] %>% 
      dplyr::select(1,2,4,5,6)
  })
  
  output$fig2<-renderPlotly({ 
    df2<-filtered_df2()
    
    #Download csv file
    output$downloadData <- downloadHandler(
      filename = function() {
        paste0("data_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(df2, file, row.names = FALSE)
      }
    )
    
    
    
    
    
    plot_ly(x = as.Date(df2$Date), y = df2$Confirmed,width = 1000, type = 'scatter', mode = 'lines'
            , name = 'Confirmed')%>%
      add_trace(x=as.Date(df2$Date), y = df2$Recovered,type = 'scatter', mode = 'lines',name='Recovered') %>%
      add_trace(x = as.Date(df2$Date), y = df2$Deceased, type = 'scatter', mode = 'lines', name = 'Deceased')%>%
      layout(title = 'Time Line (Mar-2020 to Oct-2021) State Vs India',
             plot_bgcolor='#ffff',  
             xaxis = list(  
               #title = 'Time Line (Mar-2020 to Oct-2021)',
               #zerolinecolor = 'white',  
               zerolinewidth = 2,  
               gridcolor = 'ffff'),  
             yaxis = list(  
               title = 'Case Counts',
               #zerolinecolor = 'white',  
               zerolinewidth = 2,  
               gridcolor = 'ffff'),
             showlegend = TRUE 
      )%>% 
      layout(legend=list(x=0.1,y=1, orientation='h')) 
  })
  
  ############################### GRNN Forecast Code ###########################
  output$Plotfst1 <- renderPlotly({
    pred <- grnn_forecasting(ts.data, h = input$obs)
    autoplot(pred)
  })
  
  output$Plotfst2 <- renderPlotly({
    pred <- grnn_forecasting(ts.data, h = input$obs)
    autoplot(pred$prediction, col='red', lwd=1.5, xlab='Day (Time)', ylab='No. of Cases')
  })
  
  ###################### State-wise *Scrolling* Data Table ###################
  output$raw1<-renderDataTable(rawdata1, options = list(scrollX=TRUE))
  
  
  ############################## Moran Index and Spatial Tabs ######################
  
  output$moran.conf.map<- renderLeaflet({
    
    tmap_leaflet(conf.map, mode = "view", in.shiny = FALSE)
    
  })
  
  output$moran.rec.map<- renderLeaflet({
  
        tmap_leaflet(rec.map, mode = "view", in.shiny = FALSE)
  })
  
  output$moran.dec.map<- renderLeaflet({
    
    tmap_leaflet(dec.map, mode = "view", in.shiny = FALSE)
  })
  output$moran.act.map<- renderLeaflet({
    
    tmap_leaflet(act.map, mode = "view", in.shiny = FALSE)
  })
  
  
  
  ################# OLS Regression Model########################################
  
  output$conf.plot<-renderPlot({
    par(mar=c(5,5,5,5))
    plot(conf.lag ~ s1$Confirmed,pch=16,asp=0,col=4,xlab="Confirmed Cases", mgp=c(3,1,0),
         ylab="Lags",cex.lab=1.2, cex.axis=1.2)
    M1<-lm(conf.lag ~ s1$Confirmed)
    abline(coef(M1), col="blue", lwd=2)
    ranks<-order(s1$Confirmed)
    lines(s1$Confirmed[ranks],conf.lag[ranks],lwd=2, col='skyblue')
    
    
  })
  output$rec.plot<-renderPlot({
    par(mar=c(5,5,5,5))
    plot(rec.lag ~ s1$Recovered,pch=18,asp=0,col=3, xlab="Recovered Cases",
         mgp=c(3,1,0),ylab="Lags", xpd=TRUE,cex.lab=1.2, cex.axis=1.2)
    M2<-lm(rec.lag ~ s1$Recovered)
    abline(M2, col="blue", lwd=2)
    ranks<-order(s1$Recovered)
    lines(s1$Recovered[ranks],rec.lag[ranks], col='green',lwd=2)
    
  })
  
  output$dec.plot<-renderPlot({
    
    plot(dec.lag ~ s1$Deaths,pch=17,asp=0, col=2,xlab="Death Cases", mgp=c(3,1,0),
         ylab="Lags",xpd=TRUE,cex.lab=1.2, cex.axis=1.2)
    M3<-lm(dec.lag ~ s1$Deaths)
    abline(M3, col="blue", lwd=2)
    ranks<-order(s1$Deaths)
    lines(s1$Deaths[ranks],dec.lag[ranks],col=2, lwd=2)
    
  })
  
  ###################### MC Test Plots#####################################
  output$conf.mc<-renderPlot(
    {
      par(mar=c(5,5,5,5))
      plot(MonteC,
           ylab="Density",
           xlab="Confirmed Case",col="skyblue",lwd=2,cex.lab=1.2, cex.axis=1.2)
    }
  )
  
  output$rec.mc<-renderPlot(
    { #par(mar=c(5,5,5,5))
      plot(MonteC2,
           ylab="Density",
           xlab="Recovered Case",col="green",lwd=2,cex.lab=1.2, cex.axis=1.2)
      
    })
  
  output$dec.mc<-renderPlot(
    { par(mar=c(5,5,5,5))
      plot(MonteC3,
           ylab="Density",
           xlab="Deceased Case",col=2,lwd=2,cex.lab=1.2, cex.axis=1.2)
    })
  
  ##############Summary of MC Test of Moran I#############
  output$print.montec<-renderPrint(
    { print(MonteC)
    })
  
  output$print.montec2<-renderPrint(
    { print(MonteC2)
    })   
  
  output$print.montec3<-renderPrint(
    { print(MonteC3)
    })
  
}

