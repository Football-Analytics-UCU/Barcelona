# Train 2019, OOT 2020
# 1. Remove features with >90% nulls 
# 2. Feature selection by auc-stab, IV, and correlation
# 3. Numeric binning 

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

getwd()
setwd("C:/Users/Julia/Desktop/Football_Analytics/data_more/5/modeling_v2")
dir()

load(file = "data_R/features.Rda")
load(file = "data_R/df.Rda")
load(file = "data_R/df_feat.Rda")


target <- 'targ'

ids <-c( 'gameID', 'homeTeamID', 'awayTeamID')
tech <- c(ids, target, 'sample_type', 'season')

# replace missing - in sample

features_num <- features 

for (i in features_num[features_num %in% names(df_feat)]) {
  if (nrow(df_feat[is.na(df_feat[[i]]),])) {
    df_feat[is.na(df_feat[[i]]), i] <- -999
    
    print(i)
  }
}

#Define train/oot
df %>% group_by(season) %>% summarise(cnt = n(), cnt_bads = sum(targ), br = sum(targ)/n(), mean_gameID = mean(gameID))

df$sample_type <- ifelse(df$season == 2020 & df$gameID > 14950, 'oot', 'train')
df %>% group_by(sample_type) %>% summarise(cnt = n(), cnt_bads = sum(targ), br = sum(targ)/n(), mean_gameID = mean(gameID))

df_feat <- merge(x = df_feat, y = df[,c('gameID', 'sample_type')], by = 'gameID')


# calculate NAs
# in our samples NA is denoted by -1
create_table_with_na <- function(df, feat, feat_num, feat_char){
  
  cnt_na <- data.frame(varr=as.character(NA), 
                       na_cnt =as.numeric(NA),
                       stringsAsFactors=FALSE)
  
  for(i in feat){
    
    if(i %in% names(df)) {
      tmp <- df[[i]]
    } 
    
    if(i %in% feat_num) {
      newrow_na <- list(i, length(tmp[is.na(tmp)]) + length(tmp[!is.na(tmp) & tmp %in% c(-1, -999)])) 
    } 
    if(i %in% feat_char) {
      newrow_na <- list(i, length(tmp[is.na(tmp)]) + length(tmp[!is.na(tmp) & tmp %in% c('', 'NotKnown')])) 
    }
    cnt_na = rbind(cnt_na,newrow_na)
  }
  cnt_na
}


remove_vars_with_99nulls <- function(df, feat, feat_num, feat_char){
  tmp_df <- df %>% filter(sample_type == 'train')

  cnt_na_train <- create_table_with_na(tmp_df, feat, feat_num, feat_char)
  
  feat_new <- setdiff(feat, 
                  cnt_na_train[!is.na(cnt_na_train$varr) & 
                                 cnt_na_train$na_cnt > nrow(tmp_df) * 0.99, 'varr'])
  
  #tmp_df <- df %>% filter(sample_type == 'oot')
  #
  #cnt_na_test <- create_table_with_na(tmp_df, feat, feat_num, feat_char)
  
  #feat_new <- setdiff(feat_new, 
  #                cnt_na_test[!is.na(cnt_na_test$varr) & 
  #                              cnt_na_test$na_cnt > nrow(tmp_df) * 0.99, 'varr'])
  
  df_res <- df[, c(tech[tech %in% names(df)], feat_new[feat_new %in% names(df)])]
  
  list(df_res, feat_new, cnt_na_train)
}

  

tmp <- remove_vars_with_99nulls(df_feat, features, features, c())
View(tmp[[3]])
df_feat2 <- tmp[[1]]

save(df_feat2, file = "data_R/df_feat2.rda")

#to_delete <-c()

features3 <- tmp[[2]]
features_num3 <- features3
#features_num3 <- features_num2[features_num2 %in% features3]
#features_char3 <- features_char2[features_char2 %in% features3]

#features3 <- setdiff(features3, to_delete)
#features_num3 <- setdiff(features_num3, to_delete)
#features_char3 <- setdiff(features_char3, to_delete)
#rm(tmp)

rm(df_feat)

gc()

####################################################################################################################
############################ DEFINE TRAIN/TEST ####################################################################
####################################################################################################################

train2 <- df_feat2 %>% filter(sample_type == 'train') %>% filter(targ %in% c(0,1))
oot2 <- df_feat2 %>% filter(sample_type == 'oot') %>% filter(targ %in% c(0,1))

####################################################################################################################
############################ BINNING ###############################################################################
####################################################################################################################

source('numeric_binning_part1.R')


source("manual_binning.R")


source('numeric_binning_part2.R')

####################################################################################################################
############################ RUDE FEATURE SELECTION ################################################################
####################################################################################################################

source('feature_selection.R',chdir=TRUE)


features9


