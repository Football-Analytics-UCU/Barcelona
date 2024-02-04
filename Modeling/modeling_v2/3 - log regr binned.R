
require(plyr)
library(caret)
library(xgboost)
library(sqldf)
library (pROC)
library (ROCR)
library(dplyr)
library(Hmisc)
library(rpart)
library(Rlab)
library("RODBC")

source("C:/Users/Julia/Desktop/Scripts/R scripts/GLM/AddWoeFromBinningRes.R")
source("C:/Users/Julia/Desktop/Scripts/R scripts/GLM/CopyBinning.R")

getwd()
setwd("C:/Users/Julia/Desktop/Football_Analytics/data_more/5/modeling_v2")
dir()

load(file = "data_R/features9.Rda")
load(file = "data_R/features_num5.Rda")
#load(file = "data_R/features_char5.Rda")
load(file = "data_R/binning_res.Rda")
load(file = "data_R/train5.Rda")
load(file = "data_R/oot5.Rda")
load(file = "data_R/allIV_man.rda") 
load(file = "data_R/aucs_stab.rda") 
load(file = "data_R/psi.rda") 
#load(file = "data_R/tech.rda") 


target <- 'targ'



source("C:/Users/Julia/Desktop/Scripts/R scripts/GLM/VarAn.R")


ids <-c( 'gameID', 'homeTeamID', 'awayTeamID')
tech <- c(ids, target, 'sample_type', 'season')

train6 <- train5[, c(tech[tech %in% names(train5)], features9, paste0(features9, '_woe'))]
oot6 <- oot5[, c(tech[tech %in% names(oot5)], features9, paste0(features9, '_woe'))]

VarAn(train5, col_bad = target, 'mean_shots_past_home', 85)

options(scipen=999)

features10 <- features9

features10 <- setdiff(features10, 
                      c('mean_shotsOnTarget_curr_home', 'mean_shots_home', 
                        'mean_ppda_past_home', 'mean_shots_past_home', 'mean_shotsOnTarget_away', 
                        'mean_goals_away', 'mean_goals_past_home', 'mean_deep_past_home', 
                        'mean_corners_past_home', 'mean_goals_curr_home', 
                        'pc_wins_prv_away', 'mean_deep_away', 'mean_deep_home', 
                        'mean_ppda_home', 'mean_shotsOnTarget_past_away', 
                        'mean_shotsOnTarget_curr_away'))

features11 <- setdiff(features10, c('cnt_prv_wins_home', 'mean_corners_past_away', 
                                    'mean_goals_home', 'cnt_prv_wins_away', 'mean_shots_away', 
                                    'mean_redCards_away', 'mean_deep_curr_home', 
                                    'mean_yellowCards_past_away', 'mean_deep_curr_away', 
                                    'mean_deep_past_away', 'mean_corners_curr_home', 
                                    'mean_shots_curr_away', 'pc_wins_2019_2018_home'))

features11_woe <- paste0(features11, '_woe')

fla <- paste("targ ~", paste(features11_woe, collapse="+"))

res <- glm(as.formula(fla)
           , 
           data = train6, 
           family = binomial(link = "logit"));

summary(res)

pROC::auc(train6[[target]], predict(res,train6, type="response")) #0.7537
pROC::auc(oot6[[target]], predict(res,oot6, type="response")) #0.7595


scored_oot <- oot6[,tech[tech %in% names(oot6)]]
scored_oot$pred <- predict(res,oot6, type="response")
scored_oot$sample_type <- 'oot'

scored_train <- train6[,tech[tech %in% names(train6)]]
scored_train$pred <- predict(res,train6, type="response")
scored_train$sample_type <- 'train'

all_scores <- rbind(scored_train, scored_oot)

#save(res, file = 'data_R/model_fin.Rda')
save(features11, file = 'data_R/features11.Rda')
#write.csv(scored_oot, file = 'scored_oot.csv')

#write.csv(binning_res[binning_res$var %in% features11 ,], file = 'features_model_11.csv')


# IVF 
source('C:/Users/Julia/Desktop/Scripts/R scripts/GLM/ivf.R',chdir=TRUE)
ivf(train6, features11_woe)

#look at values of performance 
scored_oot$pred_bin <- ifelse(scored_oot$pred > 0.65, 1, 
                              ifelse(scored_oot$pred > 0.35, 2, 3))
mean(scored_oot$pred) ; mean(scored_oot$targ)
scored_oot %>% group_by(pred_bin) %>% summarise(cnt = n(), bads = sum(targ), 
                                                x_br = mean(pred), br = sum(targ)/n())
features11

mean(scored_oot$targ) - 0.33/2 ; mean(scored_oot$targ) ; mean(scored_oot$targ) + 0.33/2
scored_oot$xAccuracy <- ifelse(scored_oot$pred < 0.56, 0, 
                               ifelse(scored_oot$pred < 0.56, -1, 1))

scored_oot %>% summarise(cnt = n(), bads = sum(targ), x_br = mean(pred), br = sum(targ)/n(), 
                         pc_correct_F = sum(targ == xAccuracy)/n())


#score the entire dataset and see Accuracy 
load(file = 'data_R/df_feat.Rda')

oot_ent <- df_feat[df_feat$gameID >= min(oot5$gameID), c(tech[tech %in% names(df_feat)], features11)]
oot_ent <- CopyBinning(binning_res, oot_ent, features11[features11 %in% features_num5])
View(oot_ent)

oot_ent$pred <- predict(res,oot_ent, type="response")

oot_ent$xAccuracy <- ifelse(oot_ent$pred < 0.56, 0, 
                               ifelse(oot_ent$pred < 0.60, -1, 1))

oot_ent %>% group_by(targ) %>% summarise(cnt = n()) ; oot_ent %>% group_by(xAccuracy) %>% summarise(cnt = n())

oot_ent %>% summarise(cnt = n(), bads = sum(ifelse(targ==1,1,0)), 
                      x_br = mean(pred), br = sum(ifelse(targ==1,1,0))/n(), 
                         pc_correct_F = sum(targ == xAccuracy)/n())

oot_ent$pred_bin <- ifelse(oot_ent$pred > 0.65, 1, 
                              ifelse(oot_ent$pred > 0.35, 2, 3))

oot_ent %>% group_by(pred_bin) %>% summarise(cnt = n(), bads = sum(ifelse(targ==1,1,0)), 
                                                x_br = mean(pred), br = sum(ifelse(targ==1,1,0))/n())









