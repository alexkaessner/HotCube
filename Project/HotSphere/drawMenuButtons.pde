void drawMenuButtons(){
 
  int buttonSize = 160;
  int repeatButtonX = 316;
  int startAgainButtonX = 708;
  int buttonsY = 552;
  
  float distRepeatButton= dist(xInc,yInc,repeatButtonX,buttonsY);
  float distStartAgainButton= dist(xInc,yInc,startAgainButtonX,buttonsY);
  
  // REPEAT BUTTON
  noStroke();
  fill(thatRed);
  arc(repeatButtonX,buttonsY,buttonSize,buttonSize,radians(-90),radians(waitingRepeatGame-90));
  
  // START AGAIN BUTTON 
  noStroke();
  fill(thatRed);
  arc(startAgainButtonX,buttonsY,buttonSize,buttonSize,radians(-200),radians(waitingStartAgain-200));
  
  // messure distance from buttons
  if(distRepeatButton < (buttonSize/2)) {
    waitingRepeatGame += choosingSpeed;
  }else{
    waitingRepeatGame = 0;
  }
  if(distStartAgainButton < (buttonSize/2)) {
    waitingStartAgain += choosingSpeed;
  }else{
    waitingStartAgain = 0;
  }
  
  // triggers if button loading is complete
  if(waitingRepeatGame > 320) {
    //drawLevel(currentStage,"level");
    gameMode = 1;
    waitingRepeatGame = 0;
  }
  if(waitingStartAgain > 230) {
    currentStage = 1;
    drawLevel(currentStage,"level");
    gameMode = 1;
    waitingStartAgain = 0;
  }
}

