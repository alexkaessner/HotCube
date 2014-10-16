/**
 * HotSphere
 * This sketch translates the tracking data of the HotSphere Device into a input
 * and uses these input data to control a hotwire game.
 *
 * It uses the OpenCV for Processing library by Greg Borenstein
 * https://github.com/atduskgreg/opencv-processing
 * 
 * @authors: Kevin Schiffer (@kschiffer), Alexander Käßner (@alexkaessner), Alvaro Garcia Weissenborn (@varusgarcia)
 * @modified: 17/10/2014
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

PImage [] animation = new PImage [5];
int currentFrame = 1;

Movie titleMovie;

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

PImage menuImage;
int waitingRepeatGame;
int waitingStartAgain;
int startTextSize = 200;
int startTextNumber = 0;

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
  titleMovie = new Movie(this, "title.mov");
  titleMovie.loop();
  
  for (int i=1; i < 5; i++) {
   String imageName = "frame" +i+".png";
   animation[i] = loadImage(imageName);
   animation[i].filter(INVERT);
  }
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
  //////////
  if (gameMode == 0){
    background(255);
    image(titleMovie,0,0);
    
    drawMenuButtons();
    
    // HEADER GRAPHIC
    menuImage = loadImage("Menu.png");
    image(menuImage, (width-552)/2, 72, 552, 496); //552 496
  }
  
  ////////////
  // INGAME //
  ////////////
  if (gameMode == 1){
    
    if (!readyToGame){
      image(levelImage,0,0);
      fill(255,0,0);
      textSize(startTextSize);
      textAlign(CENTER);
      
      // Ready, Set, Go! - Text Animation
      if (startTextNumber == 0) {
        text("STAGE "+ currentStage,width/2, height/2);
        if (startTextSize <= 20) {
          startTextNumber = 1;
          startTextSize = 200;
        }
      }
      if (startTextNumber == 1) {
        text("3",width/2, height/2);
        if (startTextSize <= 20) {
          startTextNumber = 2;
          startTextSize = 200;
        }
      }
      if (startTextNumber == 2) {
        text("2",width/2, height/2);
        if (startTextSize <= 20) {
          startTextNumber = 3;
          startTextSize = 200;
        }
      }
      if (startTextNumber == 3) {
        text("1",width/2, height/2);
        if (startTextSize <= 20) {
          startTextNumber = 4;
          startTextSize = 200;
        }
      }
      if (startTextNumber == 4) {
        text("GO!",width/2, height/2);
        if (startTextSize <= 20) {
          xInc = 20;
          yInc = height/2;
          readyToGame = true;
          startTextSize = 200;
        }
      }
      startTextSize += -8;
      
    } else {
      image(levelImage,0,0);
      
      printLevelWait++;
      if (xInc > width-5){
        println("success!");
        drawLevel(currentStage++,"level");
        
        xInc = 20;
        yInc = height/2;
        
      }
      if (get(xInc,yInc) == -16777216) {
        println("GAME OVER");
        currentStage = 1;
        readyToGame = false;
        gameMode = 0;
        startTextNumber = 0;
      } else {
        //println("good!");
      }
    }
  }
  
  image(animation[currentFrame],xInc,yInc);
  currentFrame++;
  if (currentFrame >= 5){
    currentFrame = 1 ;
  }
}

void movieEvent(Movie m) {
  m.read();
}

