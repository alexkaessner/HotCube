void drawMenuButtons(){
 
  int buttonSize = 230;
  int startGameButtonX = floor(width*0.3);
  int highscoresButtonX = floor(width*0.7);
  int buttonsY = floor(height*0.75);
  
  float distStartGameButton= dist(xInc,yInc,startGameButtonX,buttonsY);
  float distHighscoresButton= dist(xInc,yInc,highscoresButtonX,buttonsY);
  
  // START GAME BUTTON
  stroke(0);
  strokeWeight(4);
  fill(255);
  ellipse(startGameButtonX,buttonsY,buttonSize,buttonSize);
    // create loading indicator
  noStroke();
  fill(0);
  arc(startGameButtonX,buttonsY,buttonSize,buttonSize,radians(-90),radians(waitingStartGame-90));
  fill(255);
  ellipse(startGameButtonX,buttonsY,buttonSize-20,buttonSize-20);
    // load Text SVG
  startGameText = loadShape("StartGameText.svg");
  shape(startGameText, startGameButtonX-88, buttonsY-20, 179, 38);
  
  // HIGHSCORE BUTTON
  stroke(0);
  strokeWeight(4);
  fill(255);
  ellipse(highscoresButtonX,buttonsY,buttonSize,buttonSize);
    // create loading indicator
  noStroke();
  fill(0);
  arc(highscoresButtonX,buttonsY,buttonSize,buttonSize,radians(-90),radians(waitingHighscores-90));
  fill(255);
  ellipse(highscoresButtonX,buttonsY,buttonSize-20,buttonSize-20);
    // load Text SVG
  highscoresText = loadShape("HighscoresText.svg");
  shape(highscoresText, highscoresButtonX-83, buttonsY-20, 174, 38);
  
  // messure distance from buttons
  if(distStartGameButton < (buttonSize/2)) {
    waitingStartGame+=choosingSpeed;
  }else{
    waitingStartGame=0;
  }
  if(distHighscoresButton < (buttonSize/2)) {
    waitingHighscores+=choosingSpeed;
  }else{
    waitingHighscores=0;
  }
  
  // triggers if button loading is complete
  if(waitingStartGame > 360) {
    drawLevel(currentStage,"level");
    gameMode = 1;
    waitingStartGame=0;
  }
  if(waitingHighscores > 360) {
    gameMode = 3;
    waitingHighscores=0;
  }
}

