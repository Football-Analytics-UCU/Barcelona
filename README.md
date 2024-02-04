# Barcelona

## Team

- Inna Dragota
- Yurii Kharabara
- Oleh Bondar
- Vasyl Dorozhynskyi
- Iuliia Gridneva
- Dmytro Omelian

<h1 align="center">Computer vision part
<img src="https://github.com/blackcater/blackcater/raw/main/images/Hi.gif" height="32"/></h1>

<h3 align="center">Yurii Kharabara and Inna Dragota</h3>

<h1 align="center">Goal: detecting of ball possesion  in match Barcelona VS Real Madrid</h1>

<img src="yolov7/img/Example.png" alt="result_img">
<img src="yolov7/img/example_2.png" alt="result_img">

[Video of match Barcelona VS Real Madrid](https://drive.google.com/file/d/1OCz-WSO76S3x9s67sVTQTRpX2Xsltl22/view?usp=drive_link)<br>
[Video detecting of players](https://drive.google.com/file/d/1ZBJ6kvKmYimA1k17NF7uc55jQCRYUfLH/view?usp=drive_link)

<h2>Our steps:</h2>

1. Downloading video from Youtube.
2. Labeling of players team Barcelona, opponents, referee and ball.
3. Export of dataset that divide on train, validation and test to project(using Roboflow).
4. Train of model Yolov7 on our dataset(defining of weights and performance graph, confusion matrix).
5. Defining of ball's probable flight path: </br>
   a) attempt to detection of ball;</br>
   b) if it don't detect, we use information about direction and speed for understanding of probable trajectory. We think that it's right way of flying (1 second);</br>
   с) if it don't detect during 1 second, we define it from previous frame.
6. Ball possession calculation(top left corner and top right corner).

<h2>Problems of using Yolov7:</h2>

1. When we used model for detection: bounding box of ball was hide behind bounding box of players.
   We tried to solve it by retraining it on separate datasets. First dataset is referee, players of Barca, second - ball.

2. Ball is hide between legs of players - solving became yellow rectangle that detect direction of the ball,
   we used direction and speed. If ball was lost, we took it from previous frame.</br>

If you want to use our model you can add more pictures from defferent matches to your dataset)

## Impact of Unexpected Outcomes on Betting Strategy aka "Betting"

<h3 align="center">Vasyl Dorozhynskyi</h3>

Goals:

- detect how many Barcelona matches ended with “unexpected” results, i.e. result doesn’t match lowest betting odd.
- detect is there profitable long-run betting strategy(period - season), if user always bets against odds.
- detect correlation between number of “unexpected” results in season and profit/loss
  Input data: results of LaLiga in seasons 2014/2015 - 2020/2021 from [Football Database dataset](https://www.kaggle.com/datasets/technika148/football-database)

Implementation - [notebooks/unexpected_results.ipynb](notebooks/unexpected_results.ipynb)

At first we analyzed how many matches ended with “unexpected” results.

And we got 3 "better" and 73 "worse" matches.

After that we analyzed two strategies for betting on unexpected results

- Linear - betting the same amount every game in season
- Catch-up strategy - betting amount is calculated by formula:

S = X+Y/K-1

S - is the stake or the amount of the required bet.

X - is the amount of potential profit from the first bet, minus the stake.

Y - is the sum of all previous losses.

K - is the odds of the upcoming event.

This gives us the following result:
the linear betting strategy, as expected, resulted in losses in four out of seven seasons. In contrast, the catch-up strategy yielded profits in every season, with its least profitable season still outperforming the best season of the linear strategy by double. Interestingly, basing the betting strategy on 'unexpected' results did not correlate with overall profit. This is likely because profitability is more influenced by the sequence of 'unexpected' matches rather than their total count in a season.

## Modeling of the match results 

<h3 align="center">Iuliia Gridneva</h3>

Implementation - https://github.com/Football-Analytics-UCU/Barcelona/tree/main/Modeling

Modeling was caarried out in 2 ways : 
1. Logistic regression
2. Bradley Terry model from the R-package "BradleyTerry2". Approach for BradleyTerry taken from here : https://link.springer.com/article/10.1007/s10994-018-5741-1

For both models, the same dataset was used. 
The initial data was taken from https://www.kaggle.com/datasets/technika148/football-database and covers seasons 2014-2020 in 5 leagues : Premier League, Serie A, Bundesliga, La Liga (Spain) and Ligue 1. 

Initially it was attempted to train model on LaLiga only; however, the dataset size proved to be insufficient for any reliable results. Therefore, all 5 leagues were used for training, seasons 2019-2020. The rest of the seasosn was used to generate model features. Overall, 36 features were created covering history of goals, wins, corners, yellow/red cards, etc. No playesr data was introduced into the models since there was no appropriate vocabulary how to relate players to teams in respective seasons. Future steps would include finding such dictionary ; player-related features should be the core of such modeling. 

Dataset size : 1.8K / 0.9K train/oot
OOT was defined as season == 2020 & gameID > 14950 (which corresponds to the sufficient number of the latest observations ; since the dataset is itself small, such OOT happened to be ~1/3 of it, but smaller dataset could distort the evaluation result) 
Target : match winning
Draws : excluded from modeling 

From the initial set of features, 8 features were selected for final modeling. Methods of features exclusion : correlations > 0.9, information value, features stability.

Model 1 : logistic regression : performance AUC 0.75/0.76 train/oot. It corresponds to 69% of correctly predicted match results in OOT . 
![pic1](https://github.com/Football-Analytics-UCU/Barcelona/assets/13146810/9963078f-a4b7-4c34-8f3e-1b3eb2c58897)


However, if add draws to this dataset, it's not obvious how to define the match outcome. If define match outcome in the following way : 
prediction < 0.5 : away win 
prediction 0.5 - 0.65 : draw
prediction > 0.65 : home win , 
then it will give only 48% of correctly predicted match outcomes . 

![pic2](https://github.com/Football-Analytics-UCU/Barcelona/assets/13146810/f94562cc-a5c3-427d-8639-4cd6e9e4f37c)


This figure is significantly lower compared to the coefficients of the betting companies. However, this is only an initial model and there's a lot of possible options how to improve it. 

Model 2 : Bradley Terry. 
In the original Bradley Terry, prediction is based on <math xmlns="http://www.w3.org/1998/Math/MathML">
  <msub>
    <mi>&#x03BB;<!-- λ --></mi>
    <mi>i</mi>
  </msub>
</math> 
which is understood as the “strength” of team i. In the original Bradley–Terry formulation, it does not vary with time. However, the approach was used which allowed team strength to be linearly dependent on the set of parameters which can change with time. 
Modeling was carried out on the same dataset (after convertion to the appropriate format) and the same 8 features. Larger set of features was tested , but its results were rather a noise than a prediction. 

![pic3](https://github.com/Football-Analytics-UCU/Barcelona/assets/13146810/bb883889-4d9b-4c46-9513-e2846e3cfd1d)


However, it's results are far from the desired. 

## Some analytics

<h3 align="center">Dmytro Omelian</h3>

**_ Datasets _**

- Transfermarkt dataset (for game events, players, etc.);
- StatsBomb (transfers);

**_ Goals _**

- find the best players group (connections graph);
- analyse young academy (Barcelona B players);
- some other приколи;

**_ Player connections _**

Tried to identify strong connections between some players
Used Leuvian method for building communities.
Results show that players that have more common seasons and games are more likely to be part of the same community. Partitioning of 3 periods (Messi, Puyol, current one)

Potential use-case: analyse game lineups and potential performance

<img src="images/image1.jpeg" alt="result_img">
<img src="images/image2.jpeg" alt="result_img">

**_ Barcelona B -> Barcelona A _**

Steps:

1. get all players in Barca A transferred from Barca B (18 players)
2. check out some things
3. players contribution rate

<img src="images/image3_1.jpg" alt="result_img">
<img src="images/image3_2.jpeg" alt="result_img">

**_ Minutes played and substitute strategies (Xavi) _**

<img src="images/image4.jpeg" alt="result_img">

**_ Miscellaneous _**

- referee stuff
- pass maps
- positional distribution of incoming academy players (covid?)
- player performance index

<img src="images/image5_1.jpeg" alt="result_img">
<img src="images/image5_2.jpeg" alt="result_img">
<img src="images/image5_3.jpeg" />

Implementation - [notebooks/transfrmarket_processing.ipynb](notebooks/transfrmarket_processing.ipynb)
