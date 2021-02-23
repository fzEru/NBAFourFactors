library(readr)
library(dplyr)

NBA <- read_csv("data/NBAadv2020.csv")

NBAFF <- NBA %>%
  select(Rk, Player, Pos, 'TS%', FTr, 'ORB%', 'DRB%', 'TRB%', 'TOV%', WS, VORP)
View(NBAFF)
