# Train 2019, OOT 2020
# 1. Remove features with >90% nulls 
# 2. Feature selection by auc-stab, IV, and correlation
# 3. Numeric binning 

require(plyr)
library(sqldf)
library (pROC)
library(dplyr)
library(Hmisc)
library("BradleyTerry2")


getwd()
setwd("C:/Users/Julia/Desktop/Football_Analytics/data_more/5/modeling_v2")
dir()

load(file = "data_R/features11.Rda")
load(file = "data_R/features_num5.Rda")
load(file = "data_R/train5.Rda")
load(file = "data_R/oot5.Rda")

target <- 'targ'

ids <-c( 'gameID', 'homeTeamID', 'awayTeamID')
tech <- c(ids, target, 'sample_type', 'season')

train5$homeTeamID_ft <- as.factor(train5$homeTeamID)
train5$awayTeamID_ft <- as.factor(train5$awayTeamID)
train5$homeTeamID <- NULL 
train5$awayTeamID <- NULL 

oot5$homeTeamID_ft <- as.factor(oot5$homeTeamID)
oot5$awayTeamID_ft <- as.factor(oot5$awayTeamID)
oot5$homeTeamID <- NULL 
oot5$awayTeamID <- NULL 


gc()



####################################################################################################################
############################ BradleyTerry2 ###############################################################################
####################################################################################################################
feat <- features11
fla <- paste(" ~", paste(feat, collapse="[..]+"))
fla

#Model 
#re-organize data 
train5_res <- list( results = data.frame(res = train5$targ), 
                    players = data.frame(home = train5$homeTeamID_ft, away = train5$awayTeamID_ft), 
                    predictors = train5[,feat])
levels(train5_res$players$away) <- c(levels(train5_res$players$away) ,"262")
oot5_res <- list( results = data.frame(res = oot5$targ), 
                    players = data.frame(home = oot5$homeTeamID_ft, away = oot5$awayTeamID_ft), 
                    predictors = oot5[,feat])


bt_model2 <- BTm(outcome = res, 
                 player1 = home, player2 = away, 
                 ~ pc_wins_2019_2018_away[..]+pc_wins_prv_home[..]+mean_corners_away[..]+
                   mean_ppda_past_away[..]+mean_goals_curr_away[..]+mean_shotsOnTarget_home[..]+
                   mean_corners_curr_away[..]+mean_ppda_curr_home,
                 data = train5_res)

summary(bt_model2)


# Estimate results 
train5_res$pred <- predict(bt_model2, level = 1, newdata = train5_res)
oot5_res$pred <- predict(bt_model2, level = 1, newdata = oot5_res)

train5_res$pred_bin <- cut2(train5_res$pred, g = 3)
oot5_res$pred_bin <- cut2(oot5_res$pred, g = 3)

# Estimate results quality 
#look at values of performance 
min(train5_res$pred) ; max(train5_res$pred) ; mean(train5_res$pred) ; mean(train5_res$targ)
min(oot5_res$pred) ; max(oot5_res$pred); mean(oot5_res$pred) ; mean(oot5_res$targ)


train5_res_df <- as.data.frame(train5_res)
oot5_res_df <- as.data.frame(oot5_res)

train5_res_df %>% group_by(pred_bin) %>% dplyr::summarise(cnt = n(), bads = sum(res), 
                                                     x_br = mean(pred), br = sum(res)/n())

a <- oot5_res_df %>% group_by(pred_bin) %>% dplyr::summarise(cnt = n(), bads = sum(res), 
                                                       x_br = mean(pred), br = sum(res)/n())

write.csv(a, 'a.csv')

#oot5_res$xAccuracy <- ifelse(oot5_res$pred < 0.56, 0, 
#                               ifelse(oot5_res$pred < 0.56, -1, 1))
#oot5_res %>% summarise(cnt = n(), bads = sum(targ), x_br = mean(pred), br = sum(targ)/n(), 
#                         pc_correct_F = sum(targ == xAccuracy)/n())


#Score entire sample 

