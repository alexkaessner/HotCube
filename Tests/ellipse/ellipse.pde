 PShape way;
 int score=0;
void setup()
{
  size(600, 360);
  background(255);
  noStroke();
  way=loadShape("Untitled-1.svg");
 /* stroke(0, 0, 0);
  noFill();
  strokeWeight(60);
  beginShape();
  curveVertex(0, 170); // the first control point
  curveVertex(0, 170); // is also the start point of curve
  curveVertex(100, random(0,360));
  curveVertex(200,random(0,360));
  curveVertex(300,random(0,360));
  curveVertex(400,random(0,360));
  curveVertex(500,random(0,360));
  curveVertex(600, 170); // the last point of curve
  curveVertex(600, 170); // is also the last control point
  endShape();
  */
}


void draw(){
score= mouseX/6;
  
 
  if(get(mouseX,mouseY)!=-1){
    
    background(255,0,0,255);
  }
    else{background(0);
  }
  
  shape(way,0,0);
  stroke(100);  
  text("YOU ARE:"+score+"% DONE",100,100);
}

