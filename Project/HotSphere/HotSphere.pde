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
int buttonSize = 230;
int startGameButtonX = 395;
int highscoresButtonX = 885;
int buttonsY = 562;
int waitingStartGame;
int waitingHighscores;
int choosingSpeed = 10;
int finderSize = 80;
int startingTime;

int xInc;
int yInc;

void setup() {
  frameRate(25);
  if (!mouseInput){

  //video = new Capture(this, 640, 480);
  video = new Capture(this, 640, 480, "USB2.0 Camera");
  video.start();

  opencv = new OpenCV(this, 1024, 576);
  contours = new ArrayList<Contour>();

  size(opencv.width, opencv.height, P2D);
  } else {
    size(1280,720);
  }
  //background(0);
  gameMode = 0;
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

/////////////////////
// Display Methods
/////////////////////

void displayImages() {

  pushMatrix();
  scale(1);
  image(src, 0, 0);
  popMatrix();

  stroke(255);
  fill(255);
  rect(0,0,width,height);

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
  
  float distStartGameButton= dist(mouseX,mouseY,startGameButtonX,buttonsY);
  float distHighscoresButton= dist(mouseX,mouseY,highscoresButtonX,buttonsY);
  
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
    //gameMode = 3;
    waitingHighscores=0;
  }
}

void trackPosition(){
  // Read last captured frame
  if (video.available()) {
    video.read();
  }

  // Load the new frame of our camera in to OpenCV
  opencv.loadImage(video);
  src = opencv.getSnapshot();

  ///////////////////////////////
  // <1> PRE-PROCESS IMAGE
  // - Grey channel 
  // - Brightness / Contrast
  ///////////////////////////////

  // Gray channel
  opencv.gray();

  //opencv.brightness(brightness);
  opencv.contrast(contrast);

  // Save snapshot for display
  preProcessedImage = opencv.getSnapshot();

  ///////////////////////////////
  // <2> PROCESS IMAGE
  // - Threshold
  // - Noise Supression
  ///////////////////////////////

  // Adaptive threshold - Good when non-uniform illumination
  if (useAdaptiveThreshold) {

    // Block size must be odd and greater than 3
    if (thresholdBlockSize%2 == 0) thresholdBlockSize++;
    if (thresholdBlockSize < 3) thresholdBlockSize = 3;

    opencv.adaptiveThreshold(thresholdBlockSize, thresholdConstant);

    // Basic threshold - range [0, 255]
  } else {
    opencv.threshold(threshold);
  }

  // Invert (black bg, white blobs)
  opencv.invert();

  // Reduce noise - Dilate and erode to close holes
  opencv.dilate();
  opencv.erode();

  // Blur
  opencv.blur(blurSize);

  // Save snapshot for display
  processedImage = opencv.getSnapshot();

  ///////////////////////////////
  // <3> FIND CONTOURS  
  ///////////////////////////////

  // Passing 'true' sorts them by descending area.
  contours = opencv.findContours(true, true);

  // Save snapshot for display
  contoursImage = opencv.getSnapshot();

  // Draw
  pushMatrix();

  // Display images
  displayImages();

  // Display contours in the lower right window
  pushMatrix();

  //displayContours();
  displayContoursBoundingBoxes();

  popMatrix(); 
  popMatrix();
}

void displayContours() {

  for (int i=0; i<contours.size (); i++) {

    Contour contour = contours.get(i);

    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    //contour.draw();
  }
}

void displayContoursBoundingBoxes() {

  for (int i=0; i<contours.size (); i++) {

    Contour contour = contours.get(i);
    Rectangle r = contour.getBoundingBox();
    int x = 0;
    int y = 0;

    if (//(contour.area() > 0.9 * src.width * src.height) ||
    (r.width < blobSizeThreshold || r.height < blobSizeThreshold))
      continue;

    stroke(255, 0, 0);
    fill(255, 0, 0, 150);
    strokeWeight(2);
    rect(r.x, r.y, r.width, r.height);
    println("X: " + r.x + "; Y: " + r.y);
    x = r.x - 347;
    y = r.y - 212;
    if (x > 10 || x < -10) xInc = xInc - x / 4;
    if (y > 10 || y < -10) yInc = yInc - y / 4;
    
    fill(0);
    ellipse(xInc,yInc,20,20);
  }
}

