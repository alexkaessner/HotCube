int i;
int i2;

void setup(){
  size(1000,1000);
}

void draw(){
  
  
  float d= dist(mouseX,mouseY,250,500);
  float d2= dist(mouseX,mouseY,750,500);

  if(d<100) {
    i++;
  } 
  else{
    i=0;
  }

 if(d2<100) {
    i2++;
  } 
  else{
    i2=0;
  }

  background(0);
 
  fill(255);                           //try again ellipse
   ellipse(250,500,200,200);
   
   fill(0);
   arc(250,500,190,190,radians(-90),radians(i-90));
   noStroke();
   fill(255);
    ellipse(250,500,170,170);
    
     textSize(25);
  fill(0);
  text("TRY AGAIN",185,505);
   
 
   fill(255);                           //leaderboard ellipse
   ellipse(750,500,200,200);
   
   fill(0);
   arc(750,500,190,190,radians(-90),radians(i2-90));
   noStroke();
   fill(255);
    ellipse(750,500,170,170);
    
     textSize(20);
  fill(0);
  text("LEADERBOARD",680,505);
  fill(255);
  textSize(100);
  text("GAME OVER",200,200);
   

}

