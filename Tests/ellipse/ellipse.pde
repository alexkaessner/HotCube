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
  background(0);
  shape(way,0,0);
  stroke(100);
  ellipse(mouseX,mouseY,20,20);
}
 

