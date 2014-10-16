/**
 * HotSphere
 * This sketch translates the tracking data of the HotSphere Device into a input
 * and uses these input data to control a hotwire game.
 *
 * It uses the OpenCV for Processing library by Greg Borenstein
 * https://github.com/atduskgreg/opencv-processing
 * 
 * @authors: Kevin Schiffer (@kschiffer), Alexander Käßner (@alexkaessner), Alvaro Garcia Weissenborn (@varusgarcia)
 * @modified: 14/10/2014
 * 
 * University of Applied Sciences Potsdam, 2014
 */
 
int gameMode = 0;
int sensitivity = 12;
boolean readyToGame = false;
boolean mouseInput = true; 
import gab.opencv.*;
import java.awt.Rectangle;
import processing.video.*;

int i;
float a;
float s;
int r;
float[][] values = new float[1280/3][3];

OpenCV opencv;
Capture video;
PImage src, preProcessedImage, processedImage, contoursImage;
ArrayList<Contour> contours;

int paddingTop = 60;
int currentStage = 1;
float contrast = 0.66; //was 1.35
int brightness = 0;
int threshold = 82; // was 75
boolean useAdaptiveThreshold = false; // use basic thresholding
int thresholdBlockSize = 489;
int thresholdConstant = 45;
int blobSizeThreshold = 20;
int blurSize = 4;
PImage levelImage;

PShape menuHeaderImage;
PShape startGameText;
PShape highscoresText;
PShape backText;
int waitingStartGame;
int waitingHighscores;
int waitingNextLevel;
int waitingBack;

int choosingSpeed = 20;
int finderSize = 80;
int startingTime;
int endingTime;
int printLevelWait = 0;

int xInc = 500;
int yInc= 500;

void setup() {
  frameRate(25);
  size(1024,640);
  if (!mouseInput){
  
    video = new Capture(this, 640, 480, "USB2.0 Camera");
    video.start();
  
    opencv = new OpenCV(this, 640, 480);
    contours = new ArrayList<Contour>();
  
    //size(opencv.width, opencv.height, P2D);
  }
  //drawLevel(4,"level");
}

void draw() {

  if (mouseInput){
    xInc = mouseX;
    yInc = mouseY;
  } else {
      trackPosition();
  }
  if (gameMode == -1){
    drawLevel(4,"three");
    noLoop();
  }
  //////////
  // MENU //
  //////////s
  if (gameMode == 0){
    background(255);
    
    // HEADER GRAPHIC
    menuHeaderImage = loadShape("MenuHeader.svg");
    shape(menuHeaderImage, (width-250)/2, 33, 250, 289); //306 354
    
    drawMenuButtons();
    
  }
  
  ////////////
  // INGAME //
  ////////////
  if (gameMode == 1){
    
    if (!readyToGame){
      image(levelImage,0,0);
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("MOVE TO STARTING POSITION",width/2, 45);
      fill(0,0,255);
      stroke(0,0,255);
      ellipse(20,height/2,finderSize,finderSize);
      finderSize -= 3;
      if (finderSize <= 20) finderSize = 80;
      if (dist(xInc,yInc,20,height/2) < 10) {
        readyToGame = true;
        image(levelImage,0,0);
        println("game starts");
        startingTime = millis();
      }
      
    } else {
      image(levelImage,0,0);
      //displayTime(millis()-startingTime);


      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Stage "+ currentStage,100, 45);
      
      printLevelWait++;
      if (xInc > width-5){
        println("success!");
        drawLevel(currentStage++,"level");
        
        xInc = 20;
        yInc = height/2;
        endingTime = millis();
        
      }
      if (get(xInc,yInc) == -16777216) {
        println("GAME OVER");
        currentStage = 1;
        readyToGame = false;
        gameMode = 2;
      } else {
        //println("good!");
      }
    }
  }
  
  //////////////////////
  // GAME OVER SCREEN //
  //////////////////////
  if (gameMode == 2){
    background(255);
    
    // add transparent level image
    //tint(255, 25/2);
    //levelImage = loadImage("level.tif");
    //image(levelImage,0,0);
    //filter(BLUR, 10);
    
    // HEADER GRAPHIC
    menuHeaderImage = loadShape("GameOverHeader.svg");
    shape(menuHeaderImage, (width-590)/2, 130, 590, 75);
    
    fill(0);
    textSize(48);
    textAlign(CENTER);
    //PFont avenir;
    //avenir = loadFont("Avenir.ttc");
    //textFont(avenir);
    text("23.5 sec", width/2, 355);
    
    drawGameOverButtons();
  }
  
  ////////////////
  // HIGHSCORES //
  ////////////////
  if (gameMode == 3){
    background(255);
    
    // HEADER GRAPHIC
    menuHeaderImage = loadShape("HighscoresHeader.svg");
    shape(menuHeaderImage, (width-627)/2, 50, 627, 75);
    
    fill(0);
    textSize(48);
    textAlign(CENTER);
    String space = "      ";
    String scoresList = "#1" + space + "23.5 sec" + "\n#2" + space + "23.5 sec" + "\n#3" + space + "23.5 sec" + "\n#4" + space + "23.5 sec" + "\n#5" + space + "23.5 sec";
    text(scoresList, (width-350)/2, 160, 350, 350);
    
    drawBackButton();
  }
  
    fill(255,0,0);
    stroke(255);
    strokeWeight(2);
    ellipse(xInc,yInc,20,20);
}


void drawBackButton(){
  float distBackButton= dist(xInc,yInc,640,613);
  
  // BACK BUTTON
  stroke(0);
  strokeWeight(4);
  fill(255);
  ellipse(640,613,150,150);
    // create loading indicator
  noStroke();
  fill(0);
  arc(640,613,150,150,radians(-90),radians(waitingBack-90));
  fill(255);
  ellipse(640,613,130,130);
    // load Text SVG
  backText = loadShape("BackText.svg");
  shape(backText, 604, 596, 74, 29);
  
  // messure distance from buttons
  if(distBackButton < (150/2)) {
    waitingBack+=choosingSpeed;
  }else{
    waitingBack=0;
  }
  
  // triggers if button loading is complete
  if(waitingBack > 360) {
    gameMode = 0;
    waitingBack=0;
  }
}

void drawGameOverButtons(){
  
  float distNextLevelButton= dist(xInc,yInc,290,buttonsY);
  float distTryAgainButton= dist(xInc,yInc,640,buttonsY);
  float distHighscoresButton= dist(xInc,yInc,highscoresButtonX+105,buttonsY);
  
  // NEXT LEVEL BUTTON
  stroke(0);
  strokeWeight(4);
  fill(255);
  ellipse(290,buttonsY,buttonSize,buttonSize);
    // create loading indicator
  noStroke();
  fill(0);
  arc(290,buttonsY,buttonSize,buttonSize,radians(-90),radians(waitingNextLevel-90));
  fill(255);
  ellipse(290,buttonsY,buttonSize-20,buttonSize-20);
    // load Text SVG
  startGameText = loadShape("NextLevelText.svg");
  shape(startGameText, 205, 547, 167, 38);
  
  // TRY AGAIN BUTTON
  stroke(0);
  strokeWeight(4);
  fill(255);
  ellipse(640,buttonsY,buttonSize,buttonSize);
    // create loading indicator
  noStroke();
  fill(0);
  arc(640,buttonsY,buttonSize,buttonSize,radians(-90),radians(waitingStartGame-90));
  fill(255);
  ellipse(640,buttonsY,buttonSize-20,buttonSize-20);
    // load Text SVG
  startGameText = loadShape("TryAgainText.svg");
  shape(startGameText, 564, 547, 147, 38);
  
  // HIGHSCORE BUTTON
  stroke(0);
  strokeWeight(4);
  fill(255);
  ellipse(highscoresButtonX+105,buttonsY,buttonSize,buttonSize);
    // create loading indicator
  noStroke();
  fill(0);
  arc(highscoresButtonX+105,buttonsY,buttonSize,buttonSize,radians(-90),radians(waitingHighscores-90));
  fill(255);
  ellipse(highscoresButtonX+105,buttonsY,buttonSize-20,buttonSize-20);
    // load Text SVG
  highscoresText = loadShape("HighscoresText.svg");
  shape(highscoresText, 903, 547, 174, 38);
  
  // messure distance from buttons
  if(distNextLevelButton < (buttonSize/2)) {
    waitingNextLevel+=choosingSpeed;
  }else{
    waitingNextLevel=0;
  }
  if(distTryAgainButton < (buttonSize/2)) {
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
  if(waitingNextLevel > 360) {
    gameMode = 1;
    waitingNextLevel=0;
  }
  if(waitingStartGame > 360) {
    gameMode = 1;
    waitingStartGame=0;
  }
  if(waitingHighscores > 360) {
    gameMode = 3;
    waitingHighscores=0;
  }
}

