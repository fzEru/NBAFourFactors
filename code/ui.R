library(shiny)
library(readr)
library(janitor)
library(tidyverse)
library(ggplot2)
library(scales)

NBA <- read_csv("NBAadv2020.csv")

shinyUI(fluidPage(
    
    # Application title
    titlePanel('NBA Four Factors'),
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput('USGp', 
                        'Usage Percentage', 
                        min = 8.0,
                        max = 37.5, 
                        value = 20.0),
            
            sliderInput('G',
                        'Games Played',
                        min = 41,
                        max = 74, 
                        value = 41)
        ),
        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(type = 'tabs',
                        tabPanel('Measuring Win Shares by Four Factors',
                                 plotOutput('Scatter'), 
                                 selectInput('toggle', 'Four Factors:', 
                                             c('TSp', 'FTr', 'TRBp', 'TOVp'))
                                 ),
                        tabPanel('Player Density by Cumulative Measures',
                                 plotOutput('Density'),
                                 selectInput('toggle2', 'Cumulative Scores:',
                                             c('WS', 'weightedScoreWS', 'weightedScoreFF'))
                                 ),
                        tabPanel('Number of Players per Position', 
                                 plotOutput('Hist'),
                                 sliderInput('WS', 
                                             'Win Shares', 
                                             min = -1.3, 
                                             max = 13.1,
                                             value = -1.3),
                                 sliderInput('wsWS', 
                                             'Weighted Win Shares', 
                                             min = 31, 
                                             max = 59,
                                             value = 31),
                                 sliderInput('wsFF', 
                                             'Weighted Four Factors', 
                                             min = 16, 
                                             max = 40,
                                             value = 16)
                                ),
                        tabPanel('NBA Four Factors Data', 
                                 dataTableOutput('NBAFF'))
                    )
                )
    )))
