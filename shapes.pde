
void runway(int x, int y) {
  rectMode(CENTER);
  //float x_offset = scalex/3;
  //float y_offset = scaley/3;  
  stroke(0, 255);
  strokeWeight(10);
  pushMatrix();
  translate(x, y);

  //line(-x_offset, y_offset, x_offset, -y_offset);
  //line(-x_offset, -y_offset, x_offset, y_offset);

  fill(255);
  noStroke();
  ellipse(0, 0, scalex/3, scaley/3);

  noFill();
  strokeWeight(2);
  stroke(255);
  ellipse(0, 0, scalex/1.3, scaley/1.3);

  popMatrix();
  rectMode(CORNER);
}


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

void chevron(float sizex, float sizey){
     beginShape();
    vertex(0, -sizex/2);
    vertex(-sizex, -sizey);
    vertex(0, sizex-1);
    vertex(sizex, -sizey);
    vertex(0, -sizex/2);
    endShape(); 
}



//// oldstyle of runway
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