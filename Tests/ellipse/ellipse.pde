 PShape way;
void setup()
{
  size(640, 360);
  fill(255, 204);
  noStroke();
 way=loadShape("Untitled-1.svg");
  
}
 
void draw()
{
  println(get(mouseX,mouseY));
 
  if(get(mouseX,mouseY)==-1){
    
    background(0,100,255,255);
  }
    else{background(0);
  }
  shape(way,0,0);
  stroke(100);

  
  
    
  
}
 

