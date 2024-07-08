###################################
########################################### UI Code for COVID19 Dashboard ##############################
###################################
# C:/Users/Scisjnu/Documents/CoSymple_R/ui.R
### Project In charge: Dr. Pallavi Somvanshi, Associate Professor,SCIS,JNU New Delhi
### Project Financing Body: ICMR, New Delhi, India
### Project Assistant: Mr. Manish (Ph.D Scholar), JNU New Delhi
############## Libraries #######################################
#install.packages("shiny","shinydashboard","dashboardthemes", "flexdashboard")

library(shiny)
library(shinydashboard)
library(dashboardthemes)
library(flexdashboard)
###############################################################################

###############################################################################
######### Dashboard Interface 
header<-dashboardHeader(
  title = shinyDashboardLogo(
    theme = "blue_gradient",
    badgeText = "CoSymple",
    boldText = "COVID-19",
    mainText = "Dashboard"
    
  ),titleWidth=290,
  tags$li(class="dropdown",
          tags$a(href="https://github.com/ManishSCIS/Project_COVID19_SCIS", 
                 icon("github"), "Source Code", target="_blank")),
  dropdownMenu(type = "message", 
               messageItem(from = "Repository Update",
                           message="Updated on 08/05/2023"))
  
)

###############################################################################
sidebar<-dashboardSidebar(
  #sidebar menu and tabs
  sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("fas fa-virus-covid")),
    menuItem("Forecast", tabName = "forecast", icon = icon("fas fa-chart-line")),
    menuItem("Spatial Statistics", tabName = "spatial", icon = icon("fas fa-earth-asia")),
    menuItem("Github Repository", tabName = "repository", icon = icon("fas fa-database"))
  )
)


body<- dashboardBody(
  tabItems(
    ###############Tab1#################
    tabItem(tabName = "dashboard",
            #tab box
            tabBox(id="t1",width=12,
                   tabPanel(title="Location",icon = icon("map-location-dot"),
                            #h4(""),
                            ###############Row1#################
                            fluidRow(
                              #column(width = 12, plotlyOutput("plot1"),offset = 0)
                              column(width=12,
                                     shinydashboard::valueBoxOutput("val_conf",width =3),
                                     shinydashboard::valueBoxOutput("val_rec",width = 3),
                                     shinydashboard::valueBoxOutput("val_act",width = 3),
                                     shinydashboard::valueBoxOutput("val_dec",width = 3),
                                     offset = 0)
                            ), 
                            
                            ###############Row2#################
                            fluidRow(
                              column( width=12,
                                      box(title = "Covid Case Map",
                                          status = "primary",
                                          solidHeader = TRUE,
                                          leafletOutput("gmap"), width = 6),
                                      
                                      box( title = "Data for Top-5 State",
                                           status = "primary",
                                           solidHeader = TRUE,
                                           plotlyOutput("top5plot"),width =6),offset = 0))
                            
                   ),
                   
                   
                   tabPanel(title="Bar-Charts",icon = icon("chart-bar"),
                            #h1("Bar Chart For India"),
                            ##############Row 1: State-wise Bar Chart All#########################
                            fluidRow(
                              column(width = 12, 
                                     box(title= "State Wise Bar Chart",
                                         status = "primary",
                                         solidHeader = TRUE,
                                         plotlyOutput("plot1"),width = 12),offset = 0))
                   ),
                   
                   
                   
                   tabPanel(title="Data Table",icon = icon("table"),
                            h3("Cumulative Data Table For Indian States/UTs "),
                            dataTableOutput("df2")
                   )
            )
    ),
    
    ############################# Tab No. 2: Forecast #########################
    tabItem(tabName = "forecast",
            tabsetPanel(
              tabPanel(title="Trend Charts",icon = icon("arrow-trend-up"),
                       #h1("Trend Plots"),
                       #################Row1#####Select & Download Button##########
                       fluidRow( column( width=10, 
                                         selectInput("sts", 
                                                     "Select the State",
                                                     choices=c("Total"=1, "Andaman and Nicobar Islands"=2, "Andhra Pradesh"=3, "Arunachal Pradesh"=4,
                                                               "Assam"=5, "Bihar"=6,"Chandigarh"=7,"Chhattisgarh"=8,"Dadra and Nagar Haveli and Daman and Diu"=9,
                                                               "Delhi"=10,"Goa"=11,"Gujarat"=12,"Haryana"=13,"Himachal Pradesh"=14,"Jammu and Kashmir"=15,
                                                               "Jharkhand"=16,"Karnataka"=17,"Kerala"=18,"Ladakh"=19,"Lakshadweep"=20,"Madhya Pradesh"=21,
                                                               "Maharashtra"=22,"Manipur"=23,"Meghalaya"=24,"Mizoram"=25,"Nagaland"=26,"Odisha"=27,
                                                               "Puducherry"=28,"Punjab"=29,"Rajasthan"=30,"Sikkim"=31,"Tamil Nadu"=32,"Telangana"=33,
                                                               "Tripura"=34,"Uttar Pradesh"=35,"Uttarakhand"=36,"West Bengal"=37), 
                                                     selected="Total", multiple = FALSE, selectize = TRUE), offset = 0),
                                 column( width = 2,downloadButton("downloadData","Download Data"),offset = 0)
                       ),
                       #################Row2 & 3#####Trend Plots##########
                       fluidRow(
                         column(width=12,
                                box(title="Trend Plot",
                                    status = "primary",
                                    solidHeader = TRUE,
                                    collapsible = TRUE,
                                    collapsed = FALSE,
                                    width = 12,
                                    plotlyOutput("fig2")
                                ),offset = 0.5)
                         
                       ),
                       
                       fluidRow(
                         column(width=12,
                                box(
                                  title="COVID-19 Cases INDIA",
                                  status = "primary",
                                  solidHeader = TRUE,
                                  collapsible = TRUE,
                                  collapsed = TRUE,
                                  width = 12, 
                                  #height = 320,
                                  plotlyOutput("fig1")
                                ), offset = 0.5))
                       
                       
              ),
              
              tabPanel(title="GRNN Forecast",icon = icon("chart-line"),
                       # h1("GRNN Plots"),
                       fluidRow(column(width=8,
                                       sliderInput("obs", "Days to Forecast:",
                                                   min = 1, max = 100, value = 10
                                       ))),
                       
                       fluidRow(column(width = 6,               
                                       plotlyOutput("Plotfst1")),
                                
                                column(width=6,
                                       plotlyOutput("Plotfst2"))
                       )
              ),
              
              tabPanel(title="Data Table", icon = icon("table"),
                       dataTableOutput('raw1')
              ) 
              
            ) #end of tabsetItems
    ),
    
    ##### 3. Spatial Analysis Tab ####################
    tabItem(tabName = "spatial",
            tabBox(id="t3", width=12,
                   ###### Spatial Maps for Cases
                   tabPanel(title="Spatial-Plots", icon = icon("earth-asia"),
                            
                            ##########################################################                
                            fluidRow(
                              box(title = "Confirmed and Recovered Cases for COVID-19",
                                  status = "primary",
                                  solidHeader = FALSE,
                                  collapsible = TRUE,
                                  
                              column( width=6, img(src="conf.png",width=500, height= 400)),
                              column( width=6, img(src="rec.png",width=500, height= 400)), width = 12
                              )),
                            
                            fluidRow(box(title = "Deceased and Active Cases for COVID-19 ",
                                         status = "primary",
                                         solidHeader = FALSE,
                                         collapsible = TRUE,
                                         collapsed = TRUE,
                                         column( width=6, img(src="dec.png",width=500, height= 400)),
                                         column( width=6, img(src="act.png",width=500, height= 400)), width = 12
                            )
                                 
                               ),
                            fluidRow(
                              box(title = "Link to Interactive-Maps",
                                  status = "primary",
                                  solidHeader = TRUE,
                                  collapsed = TRUE,
                                  shiny::actionButton(inputId='ab1', label="Interactive-Map Page", 
                                                      icon = icon("earth-asia"), 
                                                      onclick ="window.open('https://v3srmu-manishscis.shinyapps.io/MoranIndex/','_blank')")
                        
                              )
                            )
                            ##########################################################         
                            
                   ),
                   ###### OLS Plots for Moran's I : Analytical Way
                   tabPanel(title="OLS-Plots", icon = icon("magnifying-glass-chart"),
                            fluidRow(
                              
                              box(title = "OLS Plot for (Confirmed Cases)",
                                  status = "primary",
                                  solidHeader = TRUE,
                                  collapsed = TRUE,
                                  collapsible = TRUE,
                                  plotOutput("conf.plot"),width=4),
                              box(title = "OLS Plot (Recovered Cases)",
                                  status = "primary",
                                  solidHeader = TRUE,
                                  collapsed = TRUE,
                                  collapsible = TRUE,
                                  plotOutput("rec.plot"),width=4),
                              box(title = "OLS Plot (Deceased Cases)",
                                  status = "primary",
                                  solidHeader = TRUE,
                                  collapsible = TRUE,
                                  collapsed = TRUE,
                                  plotOutput("dec.plot"),width=4)
                              
                            )
                            ##########################################
                   ),
                   ###### MC-Test Plots and Summary
                   tabPanel(title="Monte-Carlo Test", icon = icon("vial-circle-check"),
                            fluidRow(
                              box(title = "Monte Carlo Plot:Confirmed Cases",
                                  status = "primary",
                                  solidHeader = TRUE,
                                  collapsible = TRUE,
                                  #collapsed = TRUE,
                                  plotOutput("conf.mc"),width=4),
                              box(title = "Monte Carlo Plot:Recovered Cases",
                                  status = "primary",
                                  collapsible = TRUE,
                                  solidHeader = TRUE,
                                  #collapsed = TRUE,
                                  plotOutput("rec.mc"),width=4),
                              box(title = "Monte Carlo Plot:Deceased Cases",
                                  status = "primary",
                                  solidHeader = TRUE,
                                  collapsible = TRUE,
                                  #collapsed = TRUE,
                                  plotOutput("dec.mc"),width=4)
                            ), ##### MC-test Plot
                            fluidRow( box(title = "Monte Carlo Test Summary for Confirmed Cases",
                                          status = "primary",
                                          solidHeader = TRUE,
                                          collapsible = TRUE,
                                          collapsed = TRUE,
                                          verbatimTextOutput("print.montec"),width=4),
                                      box(title = "Monte Carlo Test Summary for Recovered Cases",
                                          status = "primary",
                                          collapsible = TRUE,
                                          solidHeader = TRUE,
                                          collapsed = TRUE,
                                          verbatimTextOutput("print.montec2"),width=4),
                                      box(title = "Monte Carlo Test Summary for Deceased Cases",
                                          status = "primary",
                                          solidHeader = TRUE,
                                          collapsible = TRUE,
                                          collapsed = TRUE,
                                          verbatimTextOutput("print.montec3"),width=4)
                            ) #fluidRow 2 Moran Plots
                            
                   )  ##############tabPanel
                   
            )  ###tabBox
    ),  ####tabItem 3
    
    ####### 4. Repository Data Item
    tabItem( tabName = "repository",
             fluidPage(
               titlePanel(strong("Repository Links")),
               p("The link is open source repository to the data sets and 
                  code for the Dashboard."),
               a("https://github.com/ManishSCIS/Project_COVID19_SCIS"),
               p("The link for different downloadable data sets used for the Dashboard."),
               a("https://github.com/ManishSCIS/Project_COVID19_SCIS/tree/main/Raw_Data")
             )
    )    # 4th tab ends
  ) #tabItems containing all tab items
) # dashboardbody



dashboardPage( skin = "green",
               header,sidebar,body
)


