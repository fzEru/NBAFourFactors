# install libraries
library(readr)
library(dplyr)

# read in original dataset
NBA <- read_csv("data/NBAadv2020.csv")

# filter only columns from the original dataset that are needed for analysis
NBAFF <- NBA %>%
  select(Rk, Player, Pos, 'TS%', FTr, 'ORB%', 'DRB%', 'TRB%', 'TOV%', WS, VORP)

# view new dataframe
View(NBAFF)
