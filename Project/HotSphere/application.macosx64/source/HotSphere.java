import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import gab.opencv.*; 
import java.awt.Rectangle; 
import processing.video.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class HotSphere extends PApplet {

/**
 * HotSphere
 * This sketch translates the tracking data of the HotSphere Device into a input
 * and uses these input data to control a hotwire game.
 *
 * It uses the OpenCV for Processing library by Greg Borenstein
 * https://github.com/atduskgreg/opencv-processing
 * 
 * @authors: Kevin Schiffer (@kschiffer), Alexander K\u00e4\u00dfner (@alexkaessner), Alvaro Garcia Weissenborn (@varusgarcia)
 * @modified: 17/10/2014
 * 
 * University of Applied Sciences Potsdam, 2014
 */

int gameMode = 0;
int sensitivity = 12;
boolean readyToGame = false;
boolean mouseInput = false; 




PFont Avenir;

PImage [] animation = new PImage [5];
PImage [] animationInvert = new PImage [5];
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
float contrast = 0.66f; //was 1.35
int brightness = 0;
int threshold = 82; // was 75
boolean useAdaptiveThreshold = false; // use basic thresholding
int thresholdBlockSize = 489;
int thresholdConstant = 45;
int blobSizeThreshold = 20;
int blurSize = 4;
PImage levelImage;

int thatRed = color(210, 67, 53);
PImage menuImage;
int waitingRepeatGame;
int waitingStartAgain;
int startTextSize = 200;
int startTextNumber = 0;

boolean gameOverAnimation=false;
int fadeGameOverRed = 0;
int fadeGameOverBlack = 0;

int choosingSpeed = 20;
int finderSize = 80;
int startingTime;
int endingTime;
int printLevelWait = 0;

int xInc = 500;
int yInc= 500;
int lastX;
int lastY;
int imageWidth;
int imageHeight;
float rotation = 0;

public void setup() {
  frameRate(25);
  size(1024, 640);
  titleMovie = new Movie(this, "title.mov");
  titleMovie.loop();

  for (int i=1; i < 5; i++) {
    String imageNameInvert = "frame" +i+".png";
    animationInvert[i] = loadImage(imageNameInvert);
    animationInvert[i].filter(INVERT);
  }
  for (int i=1; i < 5; i++) {
    String imageName = "frame" +i+".png";
    animation[i] = loadImage(imageName);
  }
  if (!mouseInput) {

    video = new Capture(this, 640, 480, "USB2.0 Camera");
    video.start();

    opencv = new OpenCV(this, 640, 480);
    contours = new ArrayList<Contour>();

    //size(opencv.width, opencv.height, P2D);
  }
  drawLevel(1, "level");
  Avenir = createFont("Avenir LT Std", 32);
  textFont(Avenir);
}

public void draw() {

  if (mouseInput) {
    xInc = mouseX;
    yInc = mouseY;
  } else {
    if (readyToGame || gameMode == 0) {
      trackPosition();
    }
  }
  if (gameMode == -1) {
    drawLevel(4, "three");
    noLoop();
  }

  //////////
  // MENU //
  //////////
  if (gameMode == 0) {
    background(255);
    image(titleMovie, 0, 0);

    drawMenuButtons();

    // HEADER GRAPHIC
    menuImage = loadImage("Menu.png");
    image(menuImage, (width-552)/2, 72, 552, 496); //552 496
  }

  ////////////
  // INGAME //
  ////////////
  if (gameMode == 1) {

    if (!readyToGame) {
      image(levelImage, 0, 0);
      fill(thatRed);
      textSize(startTextSize);
      textAlign(CENTER);

      // Ready, Set, Go! - Text Animation
      if (startTextNumber == 0) {
        text("STAGE "+ currentStage, width/2, height/2);
        if (startTextSize <= 20) {
          startTextNumber = 1;
          startTextSize = 200;
        }
      }
      if (startTextNumber == 1) {
        text("HOLD STILL!", width/2, height/2);
        if (startTextSize <= 20) {
          startTextNumber = 2;
          startTextSize = 200;
        }
      }
      if (startTextNumber == 2) {
        text("GO!", width/2, height/2);
        if (startTextSize <= 20) {
          xInc = 20;
          yInc = height/2;
          readyToGame = true;
          startTextSize = 200;
        }
      }
      startTextSize += -8;
    } else {
      image(levelImage, 0, 0);

      printLevelWait++;
      if (xInc > width-5 && !gameOverAnimation) {
        println("success!");
        drawLevel(currentStage++, "level");
        readyToGame = false;
        startTextNumber = 0;

        xInc = 20;
        yInc = height/2;
      }

      ///////////////
      // GAME OVER //
      ///////////////
      if (get(xInc, yInc) == -16777216) {
        println("GAME OVER");
        gameOverAnimation = true;
      }
      if (gameOverAnimation == true) {
        noStroke();
        fill(210,67,53, fadeGameOverRed);
        rect(0, 0, width, height);
        fadeGameOverRed += 10;

        fill(0);
        textSize(100);
        text("GAME OVER", width/2, height/2);

        if (fadeGameOverRed >= 255) {
          fadeGameOverRed = 255;
        }
      }
    }

    if (fadeGameOverRed == 255) {
      fill(0, 0, 0, fadeGameOverBlack);
      rect(0, 0, width, height);
      fadeGameOverBlack += 20;

      if (fadeGameOverBlack >= 255) {
        fadeGameOverBlack = 255;
      }
    }

    if (fadeGameOverBlack == 255) {
      readyToGame = false;
      gameOverAnimation = false;
      gameMode = 0;
      startTextNumber = 0;
      fadeGameOverRed = 0;
      fadeGameOverBlack = 0;
    } else {
      //println("good!");
    }
  }

if (readyToGame || gameMode == 0) {
  pushMatrix();
  imageWidth = animation[currentFrame].width;
  imageHeight = animation[currentFrame].height;
  translate(xInc + imageWidth/2, yInc + imageHeight/2);
  rotation = getAngle(lastX, lastY, xInc, yInc);
  //println("lastX: "+lastX+"; lastY: "+lastY+"; x: "+xInc+" y:"+yInc+"; rotation: "+rotation);
  rotate(rotation);
  translate(-imageWidth/2, -imageHeight/2);
  
  int repeatButtonX = 316;
  int startAgainButtonX = 708;
  int buttonsY = 488;
  
  float distRepeatButton= dist(xInc,yInc,repeatButtonX,buttonsY);
  float distStartAgainButton= dist(xInc,yInc,startAgainButtonX,buttonsY);
  if (gameMode == 0 && distRepeatButton > (160/2) && distStartAgainButton > (160/2) ) image(animationInvert[currentFrame], 0, 0);
  else image(animation[currentFrame], 0, 0);
  popMatrix();
} else {
  image(animation[currentFrame], 20, height/2);
}


//rotate(degrees(-rotation));
currentFrame++;
if (currentFrame >= 5) {
  currentFrame = 1 ;
}
}

public void movieEvent(Movie m) {
  m.read();
}

public float getAngle (int x1, int y1, int x2, int y2)
{
  int dx = x2 - x1;
  int dy = y2 - y1;
  return atan2(dy, dx);
}

public void drawLevel(int difficulty, String name){
  background(0);
  if (difficulty > 9) difficulty = 9;
  difficulty = 11 - difficulty;
  int ellipseSize = difficulty*20;
  int oscillation = difficulty*10;
  int ellipseSizeRandom = difficulty * 7;
  a = 0;
  fill(255);
  ellipse(20,height/2,ellipseSize,ellipseSize);
  for (int i = 0; i < width/3;i++){
    a = a + random(-oscillation,oscillation);
    if (a < -(height/2+paddingTop) + s){
      a = a + random(paddingTop,oscillation);
    }
    if (a > height/2 - s){
      a = a + random(-oscillation,0);
    }
    s = random(ellipseSizeRandom,ellipseSizeRandom*2);
    values[i][0] = i;
    values[i][1] = height/2+a;
    values[i][2] = s;
    //println(i +": "+ values[1]);
    ellipse(values[i][0]*3,values[i][1],values[i][2],values[i][2]);
  }
  filter(BLUR,10);
  filter(THRESHOLD,0.3f);
  
  save(name+".tif");
  levelImage = loadImage(name+".tif");
  println("stage "+currentStage);
  
}
public void drawMenuButtons(){
 
  int buttonSize = 160;
  int repeatButtonX = 316;
  int startAgainButtonX = 708;
  int buttonsY = 488;
  
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

public void trackPosition(){
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

public void displayContours() {

  for (int i=0; i<contours.size (); i++) {

    Contour contour = contours.get(i);

    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    contour.draw();
  }
}

public void displayContoursBoundingBoxes() {

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
    //rect(r.x, r.y, r.width, r.height);
    //println("X: " + r.x + "; Y: " + r.y);
    x = r.x - 280;
    y = r.y - 170;
    lastX = xInc;
    lastY = yInc;
    
    if (x > 10 || x < -10) xInc = xInc - x / sensitivity;
    if (y > 10 || y < -10) yInc = yInc - y / sensitivity;
    
    // let's not move out of the window!
    if (xInc > width) xInc = width;
    if (yInc > height) yInc = height;
    if (xInc < 0) xInc = 0;
    if (yInc < 0) yInc = 0;
    
    fill(0);
    //ellipse(xInc,yInc,20,20);
  }
}

/////////////////////
// Display Methods
/////////////////////

public void displayImages() {

  pushMatrix();
  scale(1);
  //image(src, 0, 0);
  popMatrix();

  //stroke(255);
  //fill(255);
  //rect(0,0,width,height);

}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "HotSphere" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
