void displayTime(int time){
  int seconds;
  int milliSeconds;
  fill(255,0,0);
  textSize(20);
  seconds = time / 1000;
  milliSeconds = time - seconds*1000;
  text(seconds + ":" +nf(milliSeconds,3),width/2,100);
}
