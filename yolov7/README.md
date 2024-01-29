


<h1 align="center">Hi guys) We are team "Barcelona"
<img src="https://github.com/blackcater/blackcater/raw/main/images/Hi.gif" height="32"/></h1>

<h3 align="center">Data science people from Ukraine UA</h3>

<h1 align="center">Goal: detecting of ball possesion  in match Barcelona VS Real Madrid</h1>

<img src="img\Example.png" alt="result_img">
<img src="img\example_2.png" alt="result_img">

[Video of match Barcelona VS Real Madrid](https://drive.google.com/file/d/1OCz-WSO76S3x9s67sVTQTRpX2Xsltl22/view?usp=drive_link)<br>
[Video detecting of players](https://drive.google.com/file/d/1ZBJ6kvKmYimA1k17NF7uc55jQCRYUfLH/view?usp=drive_link)

<h2>Our steps)</h2>

1. Downloading video from Youtube.
2. Labeling of players team Barcelona, opponents, referee and ball.
3. Export of dataset that divide on train, validation and test to project(using Roboflow).
4. Train of model Yolov7 on our dataset(defining of weights and performance graph, confusion matrix).
5. Defining of ball`s probable flight path, through direction and speed.
   If ball is not detected that we define it from previous frame.
6. Ball possession calculation(top left corner and top right corner).


<h2>Problems of using Yolov7:</h2>

1. When we used model for detection: bounding box of ball was hide behind bounding box of players.
   We tried to solve it by retraining it on separate datasets. First dataset is referee, players of Barca, second - ball.

2. Ball is hide between legs of players - solving became yellow rectangle that detect direction of the ball,
   we used direction and speed. If ball was lost, we took it from previous frame.

