library(dplyr)
#library(readxl)


getwd()
setwd("C:/Users/Julia/Desktop/Football_Analytics/data_more/5/")
dir()

df_appearances <- read.csv('appearances.csv', stringsAsFactors = F)
df_games <- read.csv('games.csv', stringsAsFactors = F)
df_leagues <- read.csv('leagues.csv', stringsAsFactors = F)
df_players <- read.csv('players.csv', stringsAsFactors = F)
df_shots <- read.csv('shots.csv', stringsAsFactors = F)
df_teams <- read.csv('teams.csv', stringsAsFactors = F)
df_teamstats <- read.csv('teamstats.csv', stringsAsFactors = F)



View(df_leagues)
View(df_teams)
View(df_games)

View(df_games %>% filter(leagueID == 4 & (awayTeamID == 148 | homeTeamID == 148  )))
df_games2_barc <- df_games %>% filter(leagueID == 4 & (awayTeamID == 148 | homeTeamID == 148  ))

View(df_teamstats)
View(df_players)     
View(df_appearances)
View(df_shots)

#Check Forecast correctness . 
# Accuracy : the outcome with the maximum estimated probability of occurrence actually occurs
df_games2_barc$accuracy <- 0 
df_games2_barc$accuracy <- ifelse(df_games2_barc$homeGoals > df_games2_barc$awayGoals, 
                                 ifelse(df_games2_barc$homeProbability > df_games2_barc$awayProbability & 
                                          df_games2_barc$homeProbability > df_games2_barc$drawProbability, 1, 0), 
                                 df_games2_barc$accuracy) 

df_games2_barc$accuracy <- ifelse(df_games2_barc$awayGoals > df_games2_barc$homeGoals, 
                                   ifelse(df_games2_barc$awayProbability > df_games2_barc$homeProbability & 
                                            df_games2_barc$awayProbability > df_games2_barc$drawProbability, 1, 0), 
                                 df_games2_barc$accuracy) 

df_games2_barc$accuracy <- ifelse(df_games2_barc$homeGoals == df_games2_barc$awayGoals, 
                                   ifelse(df_games2_barc$drawProbability > df_games2_barc$homeProbability & 
                                            df_games2_barc$drawProbability > df_games2_barc$awayProbability, 1, 0), 
                                 df_games2_barc$accuracy) 

df_games2_barc %>% filter(leagueID == 4 & (awayTeamID == 148 | homeTeamID == 148  )) %>% 
  group_by(season) %>% 
  summarise(cnt = n(), 
            cnt_predicted_correct = sum(accuracy), 
            cnt_predicted_wrong = sum(1-accuracy), 
            mean_accuracy = sum(accuracy)/n())
View(df_games2_barc %>% filter(accuracy == 0))



#Check Forecast correctness based on the paper approach (Ranked Probability Score)
View(df_games2_barc)

df_games2_barc$prob1 <- df_games2_barc$homeProbability
df_games2_barc$prob2 <- df_games2_barc$drawProbability
df_games2_barc$prob3 <- df_games2_barc$awayProbability

df_games2_barc$out1 <- ifelse(df_games2_barc$homeGoals > df_games2_barc$awayGoals, 1, 0)
df_games2_barc$out2 <- ifelse(df_games2_barc$homeGoals == df_games2_barc$awayGoals, 1, 0)
df_games2_barc$out3 <- ifelse(df_games2_barc$homeGoals < df_games2_barc$awayGoals, 1, 0)

df_games2_barc$diff1 <- df_games2_barc$prob1 - df_games2_barc$out1
df_games2_barc$diff2 <- df_games2_barc$prob2 - df_games2_barc$out2
df_games2_barc$diff3 <- df_games2_barc$prob3 - df_games2_barc$out3


df_games2_barc$RPS <- 0.5 * (df_games2_barc$diff1 * df_games2_barc$diff1 + 
                               (df_games2_barc$diff1 + df_games2_barc$diff2) * (df_games2_barc$diff1 + df_games2_barc$diff2))

min(df_games2_barc$RPS) ; max(df_games2_barc$RPS)

# RPS = 1 : a completely wrong prediction (maximum error)
# RPS = 0 : a perfect prediction (minimum error)

df_games2_barc %>% filter(leagueID == 4 & (awayTeamID == 148 | homeTeamID == 148  )) %>% 
  group_by(season) %>% 
  summarise(cnt = n(), 
            cnt_predicted_correct = sum(accuracy), 
            cnt_predicted_wrong = sum(1-accuracy), 
            mean_accuracy = sum(accuracy)/n(), 
            mean_RPS = sum(RPS)/n())



