int x1=100;
int x2=500;
int y=500;
int w=300;
int h=100;
int i=0;

void setup(){
  size(1000,1000);
  
  
}


void draw(){
  background(125);
    if((mouseX>x1) && (mouseX<x1+w)&& (mouseY>y) && (mouseY<y+h))  {
    i++;
  }
  else if ((mouseX>x1) && (mouseX<x1+w)&& (mouseY>y) && (mouseY<y+h)){
    i++;
  }
  else {
   i=0;
  }
    


  fill(255);
  rect(x1,y,w,h);
  fill(255);
  rect(x2,y,w,h);

  noStroke();
  fill(0);
  arc(mouseX,mouseY,30,30,radians(-90), radians(i-90));
  fill(0);
  ellipse(mouseX,mouseY,20,20);
} 

