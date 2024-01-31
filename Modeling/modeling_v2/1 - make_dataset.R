library(dplyr)
library(pROC)

getwd()
setwd("C:/Users/Julia/Desktop/Football_Analytics/data_more/5/")
dir()

df_leagues <- read.csv('leagues.csv', stringsAsFactors = F)
df_teams <- read.csv('teams.csv', stringsAsFactors = F)
df_games <- read.csv('games.csv', stringsAsFactors = F)

df_teamstats <- read.csv('teamstats.csv', stringsAsFactors = F)
df_players <- read.csv('players.csv', stringsAsFactors = F)  #not necessary, it's just names 
df_appearances <- read.csv('appearances.csv', stringsAsFactors = F)  #cannot be used because doesn't contain TeamID 
df_shots <- read.csv('shots.csv', stringsAsFactors = F) #not necessary, contains coordinates

View(df_games %>% filter(leagueID == 4 & (awayTeamID == 148 | homeTeamID == 148  )))
View(df_teamstats)
View(df_players)     
View(df_appearances)
View(df_shots)

min(df_games[df_games$leagueID == 4 & (df_games$awayTeamID == 148 | df_games$homeTeamID == 148  ),'season']); 
max(df_games[df_games$leagueID == 4 & (df_games$awayTeamID == 148 | df_games$homeTeamID == 148  ),'season'])

#make dataset of games season = 2019 + 2020 of any league
df_leagues

df_games %>% group_by(leagueID) %>% summarise(mind = min(season), maxd = max(season))

df <- df_games[ #df_games$leagueID == 4 & 
                 df_games$season %in% c(2019, 2020), 
               c('gameID', 'season', 'date', 'homeTeamID', 'awayTeamID', 'homeGoals', 'awayGoals')]
df$date2 <- as.Date(df$date)

#make target 
df$targ <- ifelse(df$homeGoals > df$awayGoals, 1, 
              ifelse(df$homeGoals < df$awayGoals , 0, -1))
df$targ_rev <- ifelse(df$targ == -1, -1, 1-df$targ)


View(df)

#############################################################################################
############################### MAKE ADDITIONAL TABLES ######################################
#############################################################################################

#1. make table with all teams participations 
teams_particip <- df[, c('gameID', 'season', 'date', 'homeTeamID', 'targ')]
names(teams_particip) <- c('gameID', 'season', 'date', 'TeamID', 'wins')

tmp <- df[, c('gameID', 'season', 'date', 'awayTeamID', 'targ_rev')]
names(tmp) <- names(teams_particip)

teams_particip <- rbind(x = teams_particip, y = tmp)
rm(tmp)

teams_particip <- teams_particip %>% group_by(season, TeamID) %>% arrange(date) %>% 
  mutate(cnt_games = row_number()-1)


tmp <- teams_particip[, c('season', 'TeamID', 'cnt_games', 'wins')]
tmp$cnt_prv_wins <- 0
for(t in unique(tmp$TeamID)){
  s1 <- as.numeric(unlist(unique(tmp[tmp$TeamID == t,'season'])))
  for(s in s1){
    for(g in 1:max(tmp[tmp$TeamID == t & tmp$season == s, 'cnt_games'])){
      t2 <- tmp %>% filter(TeamID == t & season == s & cnt_games < g)
      i <- nrow(t2[ t2$wins == 1,])
      tmp[tmp$TeamID == t & tmp$season == s & tmp$cnt_games == g, 'cnt_prv_wins'] <- i
    }
  }
}

#View(tmp %>% filter(TeamID == 138))


teams_particip <- merge(x = teams_particip, 
                        y = tmp[, c('TeamID', 'season', 'cnt_games', 'cnt_prv_wins')], 
                        by = c('TeamID', 'season', 'cnt_games'))
#View(teams_particip)

#2. make table with all teams participations in previous seasons
teams_particip_prv_2020 <- df_games[ #df_games$leagueID == 4 & 
                                      df_games$season < 2020, 
                               c('gameID', 'season', 'date', 'homeTeamID', 'homeGoals', 'awayGoals')]
names(teams_particip_prv_2020) <- c('gameID', 'season', 'date', 'TeamID', 'ourGoals', 'otherGoals')

tmp <- df_games[ #df_games$leagueID == 4 & 
                  df_games$season < 2020, 
                c('gameID', 'season', 'date', 'awayTeamID', 'awayGoals', 'homeGoals')]
names(tmp) <- names(teams_particip_prv_2020)

teams_particip_prv_2020 <- rbind(x = teams_particip_prv_2020, y = tmp)
rm(tmp)

teams_particip_prv_2020 <- teams_particip_prv_2020 %>% group_by(TeamID) %>% arrange(date) %>% 
  mutate(cnt_games = row_number()-1)

teams_particip_prv_2020 <- teams_particip_prv_2020 %>% group_by(TeamID, season) %>% arrange(date) %>% 
  mutate(cnt_games_seasonal = row_number()-1)

teams_particip_prv_2020$targ <- ifelse(teams_particip_prv_2020$ourGoals > teams_particip_prv_2020$otherGoals, 1, 
                              ifelse(teams_particip_prv_2020$ourGoals < teams_particip_prv_2020$otherGoals , 0, -1))
teams_particip_prv_2020$ourGoals <- NULL 
teams_particip_prv_2020$otherGoals <- NULL 
names(teams_particip_prv_2020) <- c('gameID', 'season', 'date', 'TeamID', 'cnt_games', 'cnt_games_seasonal', 'targ')

teams_particip_prv_2020$wins <- ifelse(teams_particip_prv_2020$targ == 1,1,0)

#View(teams_particip_prv_2020 %>% filter(TeamID == 138))

#4. make table with all teams participations in all leagues 
date_from <- min(df[,'date']) ; date_to <- max(df[,'date'])
teams_particip_any_league <- df_games[df_games$date >= date_from & df_games$date <= date_to, 
  c('gameID', 'season', 'date', 'homeTeamID')]
names(teams_particip_any_league) <- c('gameID', 'season', 'date', 'TeamID')

tmp <- df[, c('gameID', 'season', 'date', 'awayTeamID')]
names(tmp) <- names(teams_particip_any_league)

teams_particip_any_league <- rbind(x = teams_particip_any_league, y = tmp)
teams_particip_any_league$date2 <- as.Date(teams_particip_any_league$date)
rm(tmp)
teams_particip_any_league$date <- NULL 

teams_particip_any_league <- teams_particip_any_league %>% group_by(TeamID) %>% arrange(date2) %>% 
  mutate(cnt_games = row_number()-1)

teams_particip_any_league <- teams_particip_any_league %>% group_by(TeamID) %>% arrange(date2) %>% 
  mutate("prv_game_date" = lag(date2))

#View(teams_particip_any_league %>% filter(TeamID == 138))

#5. stats by player : yellow + red cards 
#cannot be done on this dataset 

 
#############################################################################################
######################### MAKE BASIC FEATURES ###############################################
#############################################################################################

#1) count of games played in the season
df <- merge(x = df, y = teams_particip[, c('gameID', 'TeamID', 'cnt_games')], 
            by.x = c('gameID', 'homeTeamID'), by.y = c('gameID', 'TeamID'))
names(df)[which(names(df) == 'cnt_games')] <- 'cnt_games_home'
df <- merge(x = df, y = teams_particip[, c('gameID', 'TeamID', 'cnt_games')], 
            by.x = c('gameID', 'awayTeamID'), by.y = c('gameID', 'TeamID'))
names(df)[which(names(df) == 'cnt_games')] <- 'cnt_games_away'

#2) number of days since the previous game in any league
df <- merge(x = df, 
            y = teams_particip_any_league[, c('TeamID', 'gameID', 'prv_game_date')], 
            by.x = c('gameID', 'homeTeamID'), by.y = c('gameID', 'TeamID'))
df$days_since_prv_game_home <- as.numeric(difftime(df$date2,df$prv_game_date, units = "days")) 
df$prv_game_date <- NULL 

df <- merge(x = df, y = teams_particip_any_league[, c('gameID', 'TeamID', 'prv_game_date')], 
            by.x = c('gameID', 'awayTeamID'), by.y = c('gameID', 'TeamID'))
df$days_since_prv_game_away <- as.numeric(difftime(df$date2,df$prv_game_date, units = "days") )
df$prv_game_date <- NULL 

#View(df %>% filter(awayTeamID == 138 | homeTeamID == 138))

#3) number of players with overdose of red/yellow cards 
#cannot be done on this dataset 

#4) % of wins in the season
df <- merge(x = df, 
            y = teams_particip[, c('TeamID', 'gameID', 'cnt_prv_wins')], 
            by.x = c('gameID', 'homeTeamID'), by.y = c('gameID', 'TeamID'))
df$cnt_prv_wins_home <- df$cnt_prv_wins/df$cnt_games_home
df$cnt_prv_wins <- NULL 

df <- merge(x = df, 
            y = teams_particip[, c('TeamID', 'gameID', 'cnt_prv_wins')], 
            by.x = c('gameID', 'awayTeamID'), by.y = c('gameID', 'TeamID'))
df$cnt_prv_wins_away <- df$cnt_prv_wins/df$cnt_games_away
df$cnt_prv_wins <- NULL 

#5) % of wins in the previous season
t <- teams_particip_prv_2020 %>% filter(season %in% c(2018,2019)) %>% group_by(season, TeamID) %>% 
  summarise(pc_wins_2019_2018 = sum(wins)/n())
t$season_next <- ifelse(t$season == 2018, 2019, 
                        ifelse(t$season == 2019, 2020, NA))
t$season <- NULL 

df <- merge(x = df, y = t, by.x = c('homeTeamID', 'season'), by.y = c('TeamID', 'season_next'), all.x = T)
names(df)[which(names(df) == 'pc_wins_2019_2018')] <- 'pc_wins_2019_2018_home'
df <- merge(x = df, y = t, by.x = c('awayTeamID', 'season'), by.y = c('TeamID', 'season_next'), all.x = T)
names(df)[which(names(df) == 'pc_wins_2019_2018')] <- 'pc_wins_2019_2018_away'


#6) % of wins ever (2014-2018/2019)
t2 <- teams_particip_prv_2020 %>% group_by(TeamID) %>% summarise(pc_wins_prv = sum(wins)/n())
t2$season <- 2020 

t3 <- teams_particip_prv_2020 %>% filter(season < 2019) %>% group_by(TeamID) %>% summarise(pc_wins_prv = sum(wins)/n())
t3$season <- 2019 

t4 <- rbind(t2, t3)

df <- merge(x = df, y = t4, by.x = c('homeTeamID', 'season'), by.y = c('TeamID', 'season'), all.x = T)
names(df)[which(names(df) == 'pc_wins_prv')] <- 'pc_wins_prv_home'
df <- merge(x = df, y = t4, by.x = c('awayTeamID', 'season'), by.y = c('TeamID', 'season'), all.x = T)
names(df)[which(names(df) == 'pc_wins_prv')] <- 'pc_wins_prv_away'

View(df %>% filter(homeTeamID == 138 ) %>% arrange(date2)  )

str(df)


#############################################################################################
######################### TABLES WITH FEATURES DF_TEAMSTATS #################################
#############################################################################################
unique(df$season)

feat_from_df_teamstats <- setdiff(names(df_teamstats), 
                              c('gameID', 'teamID', 'season', 'date', 'location', 'xGoals', 
                                'result'))
feat_from_df_teamstats
df_teamstats$season_next <- df_teamstats$season + 1

#stats for the previous season
teams_playing <- df[, c('homeTeamID', 'season')] %>% distinct()
names(teams_playing) <- c('TeamID', 'season')

tmp <- merge(x = teams_playing, 
             y = df_teamstats[, c('season_next', 'teamID', feat_from_df_teamstats)], 
             by.x = c('TeamID', 'season'), 
             by.y = c('teamID', 'season_next'))


df_stats_prv_season <- tmp %>% group_by(TeamID, season) %>% 
                          summarise(mean_goals = mean(goals), 
                                    mean_shots = mean(shots), 
                                    mean_shotsOnTarget = mean(shotsOnTarget), 
                                    mean_deep = mean(deep), 
                                    mean_ppda = mean(ppda), 
                                    mean_fouls = mean(fouls), 
                                    mean_corners = mean(corners), 
                                    mean_yellowCards = mean(yellowCards), 
                                    mean_redCards = mean(redCards))

#stats for all the previous seasons together
tmp <- merge(x = teams_playing[teams_playing$season == 2020,], 
             y = df_teamstats[df_teamstats$season < 2020, c('teamID', feat_from_df_teamstats)], 
             by.x = c('TeamID'), 
             by.y = c('teamID'))

tmp2 <- merge(x = teams_playing[teams_playing$season == 2019,], 
             y = df_teamstats[df_teamstats$season < 2019, c('teamID', feat_from_df_teamstats)], 
             by.x = c('TeamID'), 
             by.y = c('teamID'))
tmp <- rbind(tmp, tmp2)
rm(tmp2)

df_stats_past_seasons_all <- tmp %>% group_by(TeamID, season) %>% 
                                summarise(mean_goals_past = mean(goals), 
                                          mean_shots_past = mean(shots), 
                                          mean_shotsOnTarget_past = mean(shotsOnTarget), 
                                          mean_deep_past = mean(deep), 
                                          mean_ppda_past = mean(ppda), 
                                          mean_fouls_past = mean(fouls), 
                                          mean_corners_past = mean(corners), 
                                          mean_yellowCards_past = mean(yellowCards), 
                                          mean_redCards_past = mean(redCards))

#stats for the current season 
tmp <- merge(x = df[, c('homeTeamID', 'gameID', 'season', 'date2')], 
             y = df_teamstats[, c('teamID', 'season', feat_from_df_teamstats, 'date')], 
             by.x = c('homeTeamID', 'season'), 
             by.y = c('teamID', 'season'))
tmp$date_hist_conv <- as.Date(tmp$date)
tmp <- tmp %>% filter(date_hist_conv < date2)
tmp$date <- NULL 
names(tmp)[which(names(tmp) == 'homeTeamID')] <- 'TeamID'

tmp2 <- merge(x = df[, c('awayTeamID', 'gameID', 'season', 'date2')], 
             y = df_teamstats[, c('teamID', 'season', feat_from_df_teamstats, 'date')], 
             by.x = c('awayTeamID', 'season'), 
             by.y = c('teamID', 'season'))
tmp2$date_hist_conv <- as.Date(tmp2$date)
tmp2 <- tmp2 %>% filter(date_hist_conv < date2)
tmp2$date <- NULL 
names(tmp2)[which(names(tmp2) == 'awayTeamID')] <- 'TeamID'
tmp <- rbind(tmp, tmp2)
rm(tmp2)

df_stats_curr_season <- tmp %>% group_by(TeamID, season, gameID) %>% 
                          summarise(mean_goals_curr = mean(goals), 
                                    mean_shots_curr = mean(shots), 
                                    mean_shotsOnTarget_curr = mean(shotsOnTarget), 
                                    mean_deep_curr = mean(deep), 
                                    mean_ppda_curr = mean(ppda), 
                                    mean_fouls_curr = mean(fouls), 
                                    mean_corners_curr = mean(corners), 
                                    mean_yellowCards_curr = mean(yellowCards), 
                                    mean_redCards_curr = mean(redCards))

#merge all tables with features 
#3 datasets for home teams 
feat_curr <- c('mean_goals_curr', 'mean_shots_curr', 'mean_shotsOnTarget_curr', 'mean_deep_curr', 
               'mean_ppda_curr', 'mean_fouls_curr', 'mean_corners_curr', 
               'mean_yellowCards_curr', 'mean_redCards_curr')
df_feat <- merge(x = df, 
                 y = df_stats_curr_season[, c('TeamID', 'gameID', feat_curr)], 
                 by.x = c('homeTeamID', 'gameID'), 
                 by.y = c('TeamID', 'gameID'), 
                 all.x = T)

feat_prv <- c('mean_goals', 'mean_shots', 'mean_shotsOnTarget', 'mean_deep', 'mean_ppda', 
              'mean_fouls', 'mean_corners', 'mean_yellowCards', 'mean_redCards')
df_feat <- merge(x = df_feat, 
                 y = df_stats_prv_season[, c('TeamID', 'season', feat_prv)], 
                 by.x = c('homeTeamID', 'season'), 
                 by.y = c('TeamID', 'season'), 
                 all.x = T)

feat_past <- c('mean_goals_past', 'mean_shots_past', 'mean_shotsOnTarget_past', 'mean_deep_past', 
               'mean_ppda_past', 'mean_fouls_past', 'mean_corners_past', 'mean_yellowCards_past', 
               'mean_redCards_past')
df_feat <- merge(x = df_feat, 
                 y = df_stats_past_seasons_all[, c('TeamID', 'season', feat_past)], 
                 by.x = c('homeTeamID', 'season'), 
                 by.y = c('TeamID', 'season'), 
                 all.x = T)

names(df_feat)[names(df_feat) %in% c(feat_curr, feat_prv, feat_past)] <- 
  paste0(names(df_feat)[names(df_feat) %in% c(feat_curr, feat_prv, feat_past)], '_home')

#3 datasets for away teams 
df_feat <- merge(x = df_feat, 
                 y = df_stats_curr_season[, c('TeamID', 'gameID', feat_curr)], 
                 by.x = c('awayTeamID', 'gameID'), 
                 by.y = c('TeamID', 'gameID'), 
                 all.x = T)

df_feat <- merge(x = df_feat, 
                 y = df_stats_prv_season[, c('TeamID', 'season', feat_prv)], 
                 by.x = c('awayTeamID', 'season'), 
                 by.y = c('TeamID', 'season'), 
                 all.x = T)

df_feat <- merge(x = df_feat, 
                 y = df_stats_past_seasons_all[, c('TeamID', 'season', feat_past)], 
                 by.x = c('awayTeamID', 'season'), 
                 by.y = c('TeamID', 'season'), 
                 all.x = T)

names(df_feat)[names(df_feat) %in% c(feat_curr, feat_prv, feat_past)] <- 
  paste0(names(df_feat)[names(df_feat) %in% c(feat_curr, feat_prv, feat_past)], '_away')

features <- setdiff(names(df_feat), 
                    c('awayTeamID', 'season', 'gameID', 'homeTeamID', 'date', 'date2', 
                      'homeGoals', 'awayGoals', 'targ', 'targ_rev'))

save(df, file = 'modeling_v2/data_R/df.Rda')
save(df_feat, file = 'modeling_v2/data_R/df_feat.Rda')
save(features, file = 'modeling_v2/data_R/features.Rda')



