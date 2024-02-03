# Barcelona

- computer vision part;
- betting;
- regressions;
- some analytics;


## Project Goals

1. (TBD)


## Contributors

1. (TBD)

## Project Structure 

(TBD)

## Football Data from Transfermarkt
Football (Soccer) data scraped from Transfermarkt website

### About dataset

<img width="700" alt="image" src="https://github.com/Football-Analytics-UCU/Barcelona/assets/71069933/020f5c3d-29a2-4d9d-b62f-3728ab19a770">

- 60,000+ games from many seasons on all major competitions
- 400+ clubs from those competitions
- 30,000+ players from those clubs
- 400,000+ player market valuations historical records
- 1,200,000+ player appearance records from all games


(!) Idea here is to pre-process this dataset so that to have only data related to Barcelona team. 

### Info about tables and how it can be used 

#### players.csv

1. name (first name, last name)
2. country & city of birth
3. foot, height (cm)
4. contract expiration date
5. current club name
6. market value in eur 

**ideas**
- build prediction for transfer hunting (based on performance, valuation, contract expiration date, etc.)
- fairness based on country (race)
- we have player_valuantion by date - does it show how it was increase? does player's performance affect valuation? 

#### games.csv

1. competition
2. season
3. date
4. home/away club names, goals, position, formation (4-2-3-1, etc.), manager names (problem: some columns have 95% missing values)
5. stadium, attendance, referee

**ideas**
- (TBD)

#### game lineups csv

1. type: substitues, starting lineups, etc.
2. position, team captain

**ideas**
- (Task #1) we have to create starting lineups for N games (make sure 11 players in this lineups)
- how captain substitue affects the game? when it happens and why? does it possible to predict such things? 

#### game events csv

1. (linked by game id)
2. even minute, date
3. description (can get the next information: yellow or red card, penalty, right/left footed goal, etc.)
4. club id, player id, player assist id

**ideas**
- (TBD)

#### competitions csv

1. competition name
2. competition country

**ideas**
- (TBD)

#### appearences csv

1. game
2. player
3. date
4. yellow/red card
5. goals/assists/minutes played

**ideas**
- we get get some performance stats (especially with minutes played ones for young players)

#### club games csv

1. game id
2. hosting
3. goals, position, manager names

**ideas**
- (TBD)

#### clubs.csv

1. total market valuation
2. squad size, average age
3. foreigners number (percentage)
4. national team players
5. coach name, stedium seats 

**ideas**
- Barcelona over other clubs in Europe and Spanish league (how much foreigners allowed by "club policy")
- stedium attendance percentage during the season (we have data for that)

***Impact of Unexpected Outcomes on Betting Strategy aka "Betting"***

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

