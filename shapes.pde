
//void runway(int x, int y, int fill) {
//  rectMode(CENTER);
//  //float x_offset = scalex/3;
//  //float y_offset = scaley/3;  

//  pushMatrix();
//  translate(x, y);
//  //stroke(0, 255);
//  //strokeWeight(10);
//  //line(-x_offset, y_offset, x_offset, -y_offset);
//  //line(-x_offset, -y_offset, x_offset, y_offset);

//  fill(fill);
//  noStroke();
//  ellipse(0, 0, scalex/3, scaley/3);

//  noFill();
//  strokeWeight(2);
//  stroke(fill);
//  ellipse(0, 0, scalex/1.3, scaley/1.3);

//  popMatrix();
//  rectMode(CORNER);
//}


void Path(ArrayList<Table> statedata, int index) {
  strokeJoin(ROUND);
  beginShape();
  noFill();
  for (int i=index+1; i<statedata.size(); i++) {
    staterow = statedata.get(i).getRow(0);
    float current_x= staterow.getInt(3)-1;
    float current_y= staterow.getInt(2)-1;
    if (i==index && i<statedata.size()-1) {
      current_x = adjustx(current_x, statedata.get(index+1).getRow(0).getString(4));
      current_y = adjusty(current_y, statedata.get(index+1).getRow(0).getString(4));
    }
    airplane = new PVector(current_x, current_y);

    stroke(255);
    strokeWeight(3);
    vertex(airplane.x * scalex, airplane.y * scaley);
  }
  endShape();
}

void Path_indranil(Table statedata, int index) {
  strokeJoin(ROUND);
  beginShape();
  noFill();
  for (int i=index; i<statedata.getRowCount(); i++) {
    staterow = statedata.getRow(i);
    float current_x= staterow.getInt(1)-1;
    float current_y= staterow.getInt(2)-1;
    if (i==index && i<statedata.getRowCount()-1) {
      current_x = adjustx(current_x, statedata.getRow(index+1).getString(3));
      current_y = adjusty(current_y, statedata.getRow(index+1).getString(3));
    }
    airplane = new PVector(current_x, current_y);

    stroke(255, 0, 0);
    strokeWeight(3);
    vertex(airplane.x * scalex, airplane.y * scaley);
  }
  endShape();
}


void unitsquare(ArrayList<PVector> square, float n) {
  // Bottom
  for (float x = 1; x > -1; x -= n) {
    square.add(new PVector(x, 1));
  }
  // Left side
  for (float y = 1; y > -1; y -= n) {
    square.add(new PVector(-1, y));
  }  // Top of square
  for (float x = -1; x < 1; x += n) {
    square.add(new PVector(x, -1));
  }
  // Right side
  for (float y = -1; y < 1; y += n) {
    square.add(new PVector(1, y));
  }
}

void chevron(float sizex, float sizey) {
  beginShape();
  vertex(0, -sizex/2);
  vertex(-sizex, -sizey);
  vertex(0, sizex-1);
  vertex(sizex, -sizey);
  vertex(0, -sizex/2);
  endShape();
}



//// oldstyle of runway
void runway(int x, int y) {
  rectMode(CENTER);
  float x_offset = scalex * 0.1;
  float y_offset = scaley * 0.9;  

  pushMatrix();
  translate(x, y);
  scale(0.6);

  //  // Circle
  //  fill(0, 0, 205);
  //  noStroke();
  //  ellipse(0, 0, scalex, scaley);

  //// With Stroke
  // Vertical stripes
  fill(255);
  stroke(0, 0, 200);
  strokeWeight(11);
  rect(x_offset, 0, scalex/10, y_offset);
  rect(-x_offset, 0, scalex/10, y_offset);
  // Horizontal
  pushMatrix();
  rotate(HALF_PI);
  rect(x_offset, 0, scalex/10, y_offset);
  rect(-x_offset, 0, scalex/10, y_offset);
  popMatrix();


  //// Without Stroke
  // Vertical stripes
  noStroke();
  rect(x_offset, 0, scalex/10, scaley*0.7);
  rect(-x_offset, 0, scalex/10, y_offset);
  // Horizontal
  pushMatrix();
  rotate(HALF_PI);
  rect(x_offset, 0, scalex/10, y_offset);
  rect(-x_offset, 0, scalex/10, y_offset);
  popMatrix();

  popMatrix();
}





void legend(int x, int y) {
  textAlign(CENTER, CENTER);
  pushMatrix();
  translate(x, y);

  fill(0);
  text("25-nmi", 0, 0);

  stroke(0);
  strokeWeight(1);
  line(-scalex/2, 0, -scalex/3, 0);
  line(scalex/2, 0, scalex/3, 0);
  popMatrix();
}



void compass(float x, float y, int v, int dir) {

  float sx = scalex*1;
  float sy = scaley*1;
  PVector w = PVector.fromAngle(radians(dir));
  //println(degrees(w.heading()));
  w.mult(sx*0.4);

  pushMatrix();
  translate(x*scalex, y*scaley);

  fill(0);
  stroke(255);
  strokeWeight(0.8);
  ellipse(0, 0, sx+5, sy+5);
  fill(0);
  noStroke();
  ellipse(0, 0, sx, sy);

  noFill();
  //ellipse(0, 0, sx*0.95, sy*0.95);

  // compass letters
  textSize(10);
  fill(255);
  noStroke();
  textAlign(CENTER, CENTER);
  text("N", 0, - sy * 0.3);
  text("S", 0, sy * 0.3);
  text("E", sx * 0.3, 0);
  text("W", - sx * 0.3, 0);

  // windspeed
  fill(0);
  String string = "Wind: " + str(v) + "kn";
  text(string, 0, -sy*0.68); 

  // compass lines
  stroke(255);
  strokeWeight(0.8);
  for (int t=0; t<360; t+=15) {
    pushMatrix();
    rotate(radians(t));
    line(0, sy*0.43, 0, sy*0.48);
    popMatrix();
  }

  // wind Arrow
  pushMatrix();
  rotate(PI/2);  // the whole grid is rotated as x <-> y relative to the julia code
  rotate(w.heading());
  noStroke();
  fill(255, 0, 0);
  //strokeWeight(0.2);
  rectMode(CENTER);
  rect(w.mag()/2, 0, w.mag(), 3);
  pushMatrix();
  translate(w.mag(), 0);
  triangle(0, 0, -sx/15, sy/20, -sx/15, -sy/20);
  popMatrix();
  popMatrix();

  popMatrix();
}