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
    contour.draw();
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

void displayImages() {

  pushMatrix();
  scale(1);
  //image(src, 0, 0);
  popMatrix();

  //stroke(255);
  //fill(255);
  //rect(0,0,width,height);

}

