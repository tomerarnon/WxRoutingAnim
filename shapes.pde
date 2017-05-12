
void runway(int x, int y) {
  rectMode(CENTER);
  float x_offset = scalex/3;
  float y_offset = scaley/3;  
  stroke(0, 255);
  strokeWeight(10);
  pushMatrix();
  translate(x, y);

  //line(-x_offset, y_offset, x_offset, -y_offset);
  //line(-x_offset, -y_offset, x_offset, y_offset);

  fill(0);
  noStroke();
  ellipse(0,0, scalex/4, scaley/4);

  noFill();
  strokeWeight(4);
  stroke(0);
  ellipse(0,0, scalex/1.3, scaley/1.3);

  popMatrix();
  rectMode(CORNER);
}






//void runway(int x, int y) {
//  rectMode(CENTER);
//  float x_offset = scalex * 0.1;
//  float y_offset = scaley * 0.9;  

//  pushMatrix();
//  translate(x, y);
//  scale(0.6);

//  //  // Circle
//  //  fill(0, 0, 205);
//  //  noStroke();
//  //  ellipse(0, 0, scalex, scaley);

//  //// With Stroke
//  // Vertical stripes
//  fill(244, 255, 255);
//  stroke(0);
//  strokeWeight(11);
//  rect(x_offset, 0, scalex/10, y_offset-2);
//  rect(-x_offset, 0, scalex/10, y_offset);
//  // Horizontal
//  pushMatrix();
//  rotate(HALF_PI);
//  rect(x_offset, 0, scalex/10, y_offset);
//  rect(-x_offset, 0, scalex/10, y_offset);
//  popMatrix();


//  //// Without Stroke
//  // Vertical stripes
//  noStroke();
//  rect(x_offset, 0, scalex/10, scaley*0.7);
//  rect(-x_offset, 0, scalex/10, y_offset);
//  // Horizontal
//  pushMatrix();
//  rotate(HALF_PI);
//  rect(x_offset, 0, scalex/10, y_offset);
//  rect(-x_offset, 0, scalex/10, y_offset);
//  popMatrix();

//  popMatrix();
//  rectMode(CORNER);
//}








//void legend(int x, int y) {
//  textAlign(CENTER, CENTER);
//  translate(x, y);

//  fill(0);
//  text("25-nmi", 0, 0);

//  stroke(0);
//  strokeWeight(1);
//  line(-scalex/2, 0, -scalex/3, 0);
//  line(scalex/2, 0, scalex/3, 0);
//}