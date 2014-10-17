void drawLevel(int difficulty, String name){
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
  filter(THRESHOLD,0.3);
  
  save(name+".tif");
  levelImage = loadImage(name+".tif");
  println("stage "+currentStage);
  
}
