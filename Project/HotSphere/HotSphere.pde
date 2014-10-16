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
boolean mouseInput = false; 
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

float contrast = 1.35;
int brightness = 0;
int threshold = 75;
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
int buttonSize = 230;
int startGameButtonX = 395;
int highscoresButtonX = 885;
int buttonsY = 562;
int waitingStartGame;
int waitingHighscores;
int waitingBack;

int choosingSpeed = 10;
int finderSize = 80;
int startingTime;

int xInc = 500;
int yInc= 500;

void setup() {
  frameRate(25);
  size(1280,720);
  if (!mouseInput){
  
    video = new Capture(this, 640, 480, "USB2.0 Camera");
    video.start();
  
    opencv = new OpenCV(this, 640, 480);
    contours = new ArrayList<Contour>();
  
    //size(opencv.width, opencv.height, P2D);
  }
  background(0);
  drawLevel();
  save("level.tif");
  levelImage = loadImage("level.tif");
}

void draw() {

  if (mouseInput){
    xInc = mouseX;
    yInc = mouseY;
  } else {
      trackPosition();
  }
  if (gameMode == -1){
    background(255);
  }
  //////////
  // MENU //
  //////////
  if (gameMode == 0){
    background(255);
    
    // HEADER GRAPHIC
    menuHeaderImage = loadShape("MenuHeader.svg");
    shape(menuHeaderImage, (width-306)/2, 43, 306, 354);
    
    drawMenuButtons();
    
  }
  
  ////////////
  // INGAME //
  ////////////
  if (gameMode == 1){
    
    if (!readyToGame){
      image(levelImage,0,0);
      fill(255,0,0);
      textSize(48);
      textAlign(CENTER);
      text("MOVE TO STARTING POSITION",width/2, height/2);
      fill(0,0,255);
      stroke(0,0,255);
      ellipse(20,height/2,finderSize,finderSize);
      finderSize--;
      if (finderSize <= 20) finderSize = 80;
      if (dist(xInc,yInc,20,height/2) < 80) {
        readyToGame = true;
        image(levelImage,0,0);
        println("game starts");
        startingTime = millis();
      }
    } else {
      image(levelImage,0,0);
      displayTime(millis()-startingTime);
      if (get(xInc,yInc) != -1) {
        println("GAME OVER");
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
    shape(menuHeaderImage, (width-590)/2, 170, 590, 75);
    
    fill(0);
    textSize(48);
    textAlign(CENTER);
    //PFont avenir;
    //avenir = loadFont("Avenir.ttc");
    //textFont(avenir);
    text("23.5 sec", width/2, 380);
    
    drawMenuButtons();
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
  
    fill(255,0,0);
    stroke(255);
    strokeWeight(2);
    ellipse(xInc,yInc,20,20);
}

void displayTime(int time){
  int seconds;
  int milliSeconds;
  textSize(20);
  seconds = time / 1000;
  milliSeconds = time - seconds*1000;
  text(seconds + ":" +nf(milliSeconds,3),width/2,100);
}


void drawLevel(){
  ellipse(20,height/2,80,80);
  for (int i = 0; i < width/3;i++){
    a = a + random(-40,40);
    if (a < -(height/2) + s){
      a = a + random(0,40);
    }
    if (a > height/2 - s){
      a = a + random(-40,0);
    }
    s = random(30,60);
    values[i][0] = i;
    values[i][1] = height/2+a;
    values[i][2] = s;
    //println(i +": "+ values[1]);
    ellipse(values[i][0]*3,values[i][1],values[i][2],values[i][2]);
  }
  filter(BLUR,10);
  filter(THRESHOLD,0.3);
}

void drawMenuButtons(){
  
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
  shape(startGameText, 306, 547, 179, 38);
  
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
  shape(highscoresText, 800, 547, 174, 38);
  
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
    gameMode = 1;
    waitingStartGame=0;
  }
  if(waitingHighscores > 360) {
    gameMode = 3;
    waitingHighscores=0;
  }
}

