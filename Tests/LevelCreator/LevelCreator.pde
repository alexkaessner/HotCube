void setup() {
  size(800,460);
  frameRate(2000);
}
int i;
float a;
float s;
void draw(){
  fill (0);
  i = i + 5;
  a = a + random(-30,30);
  s = s + random(-2,2);
  ellipse(i,240+a,10 + s,10 + s);
  if ( i > 800 ) {
    filter(BLUR,10);
    filter(THRESHOLD,0.3);
    noLoop();
  } else {
    i = i+2;
    a = a + random(-20,20);
    s = s + random(-2,2);
    ellipse(i,240+a,60 + s,60 + s);
  }
}
