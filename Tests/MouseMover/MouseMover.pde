import java.awt.Robot;
import java.awt.AWTException;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
Robot robot;
int i = 0;
void setup() {
robot = new Robot();
}
void draw() {
  
  try{
    
    robot.mouseMove(++i, 550);
    println(i);
  }   catch (AWTException e) {
    println(e);
    e.printStackTrace();
  }
  if (i > 100) exit();
}
