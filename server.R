# import in libraries
library(readr)
library(dplyr)
library(janitor)
library(rsq)
library(ggplot2)
library(scales)
library(plotly)

# read in data
NBA <- read_csv("NBAadv2020.csv")

# dataframe setup
NBAFF <- NBA %>%
    select(Rk, Player, Pos, G, 'USG%', 'TS%', FTr, 'TRB%', 'TOV%', WS) %>%
    filter(G > 40) %>%
    rename('ID' = Rk) %>%
    rename('Position' = Pos) %>%
    rename('TSp' = `TS%`) %>%
    rename('USGp' = `USG%`) %>%
    rename('TRBp' = `TRB%`) %>%
    rename('TOVp' =`TOV%`) %>%
    mutate('TSp' = `TSp` * 100) %>%
    mutate('FTr' = `FTr` * 100) %>%
    mutate('weightedScoreWS' = `TSp` * 0.7084 + `FTr` * 0.0875 + `TRBp` * 0.1494 - `TOVp` * 0.0537) %>%
    mutate('weightedScoreFF' = `TSp` * 0.40 + `FTr` * 0.15 + `TRBp` * 0.20 - `TOVp` * 0.25)

# change double position to single positions, choosing the smaller position
NBAFF$Position[NBAFF$Position == 'SF-SG'] <- 'SG'
NBAFF$Position[NBAFF$Position == 'SF-PF'] <- 'SF'
NBAFF$Position[NBAFF$Position == 'PF-C'] <- 'PF'
NBAFF$Position <- factor(NBAFF$Position, levels = c('C', 'PF', 'SF', 'SG', 'PG'))

# clear NAs
#View(is.na(NBAFF))
NBAFF <- na.omit(NBAFF)
#View(NBAFF)

# r-squared values for win shares attribute in terms of FF attributes
rsq_WS <- rsq(lm(WS ~ TSp, NBAFF), TRUE) +
    rsq(lm(WS ~ FTr, NBAFF), TRUE) +
    rsq(lm(WS ~TRBp, NBAFF), TRUE) +
    rsq(lm(WS ~ TOVp, NBAFF), TRUE)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$Scatter <- renderPlot({
        
        NBAFF <- NBAFF %>%
            filter(USGp >= input$USGp) %>%
            filter(G >= input$G)
        
        Scatter <- ggplot(NBAFF, aes_string(x = input$toggle,  y = "WS", color = "Position")) 
        Scatter +
            labs(title = 'Measuring Win Shares by Four Factors',
                 subtitle = 'Visualized by Position Fitted with Linear Regression') +
            geom_point() +
            geom_smooth(method = 'lm', se = FALSE) +
            scale_x_continuous(labels = percent_format(scale = 1)) +
            theme_minimal()
        
    })
    
    output$Density <- renderPlot({
        
        NBAFF <- NBAFF %>%
            filter(USGp >= input$USGp) %>%
            filter(G >= input$G)
        
        Density <- ggplot(NBAFF, aes_string(input$toggle2))
        Density +
            labs(title = 'Player Density by Cumulative Measures', 
                 subtitle = 'Weighing Win Shares Against Weighted Scores, by Position', 
                 y = 'Density') +
            geom_density(aes(fill = factor(Position)), alpha = 0.5) +
            scale_fill_discrete(name = 'Position') +
            theme_minimal()
        
    })
    
    output$Hist <- renderPlot({
        
        NBAFF <- NBAFF %>%
            filter(USGp >= input$USGp) %>%
            filter(G >= input$G) %>%
            filter(WS >= input$WS) %>%
            filter(weightedScoreWS >= input$wsWS) %>%
            filter(weightedScoreFF >= input$wsFF)
        
        Hist <- ggplot(NBAFF, aes(Position))
        Hist + 
            labs(title = 'Number of Players per Position',
                 subtitle = 'Based on Filtered Results',
                 y = 'Number of Players') +
            geom_bar(fill = 'black') +
            theme_minimal()
        
    })
    
    output$NBAFF <- renderDataTable({
        
        if (input$USGp != 'All') {
            NBAFF <- NBAFF[NBAFF$USGp >= input$USGp,]
        }
        if (input$G != 'All') {
            NBAFF <- NBAFF[NBAFF$G >= input$G,]
        }
        if (input$USGp != 'All') {
            NBAFF <- NBAFF[NBAFF$WS >= input$WS,]
        }
        if (input$G != 'All') {
            NBAFF <- NBAFF[NBAFF$weightedScoreWS >= input$wsWS,]
        }
        if (input$USGp != 'All') {
            NBAFF <- NBAFF[NBAFF$weightedScoreFF >= input$wsFF,]
        }
        NBAFF
        
    })

})
