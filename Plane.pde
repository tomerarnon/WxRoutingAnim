class Plane {
  PVector pos;
  PShape airplane = loadShape("Objects/Airplane_silhouette.svg");
  String dir = "E";
  int fill;

  Plane(float x, float y, int fill) {
    this.pos = new PVector(0, 0);
    this.pos.x = x;
    this.pos.x = y;
    this.fill = fill;
  }

  void update(float x, float y, String d) {
    this.pos.x = x;
    this.pos.y = y;
    this.dir = d;
  }

  void show(float sizex, float sizey, boolean half, boolean side) {
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    fill(255-fill);    // circle fill
    strokeWeight(1);
    //stroke(fill);      // circle stroke
    ////noStroke();
    //if (half) {
    //  if(side){
    //    rotate(PI);
    //  }
    //  arc(0, 0, sizex, sizey, HALF_PI, 3*HALF_PI, OPEN);
    //} else {
    //  ellipse(0, 0, sizex*3.7, sizey*3.7);
    //}

    if (this.dir.equals("S")) {
      rotate(PI);
    } else if (this.dir.equals("E")) {
      rotate(HALF_PI);
    } else if (this.dir.equals("W")) {
      rotate(-HALF_PI);
    }

    pushMatrix();
    //rotate(-QUARTER_PI);
    rotate(PI);
    airplane.disableStyle();
    fill(fill, 255);      // airplane fill (should be opposite of circle
    strokeWeight(1);
    stroke(0);
    //shape(airplane, 0, 0, sizex/1.2, sizey/1.2);
    beginShape();
    vertex(0, -sizex/2);
    vertex(-sizex, -sizey);
    vertex(0, sizex-1);
    vertex(sizex, -sizey);
    vertex(0, -sizex/2);
    endShape();
    popMatrix();


    popMatrix();
  }




  void radar(String binary) {
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    if (this.dir.equals("S")) {
      rotate(PI);
    } else if (this.dir.equals("E")) {
      rotate(HALF_PI);
    } else if (this.dir.equals("W")) {
      rotate(-HALF_PI);
    }

    //// Basic green triangle
    PVector toppoint = new PVector(0, -0.1*scalex);
    PVector rightpoint = new PVector(1.5*scalex, -(2.*scaley));
    PVector leftpoint = new PVector(-1.5*scalex, -(2.*scaley));
    noStroke();
    fill(0, 255, 0, 30);
    for (float t=0; t<1; t+=0.01) {
      fill(0, 255, 0, 2);
      triangle(toppoint.x, toppoint.y, 
        leftpoint.x*t*1.4*t, leftpoint.y*t*1.2, 
        rightpoint.x*t*1.4*t, rightpoint.y*t*1.2);
    }
    ////

    //triangle(toppoint.x, toppoint.y, 
    //  leftpoint.x, leftpoint.y, 
    //  rightpoint.x, rightpoint.y);
    //

    //// Red triangle overlay
    PVector lpt = PVector.mult(leftpoint, 0.5);   //midpoint of the left side
    PVector rpt = PVector.mult(rightpoint, 0.5);  // midpoint of the right side

    String[] b = new String[binary.length()];

    fill(255, 0, 0, 100);           // fill for the detected state

    for (int i = 0; i < binary.length(); i++) {
      b[i] = str(binary.charAt(i));
    }
    // if closest to plane
    for (int i = 0; i<b.length; i++) {
      if (b[i].equals("1") && i==0) {
        fill(255, 0, 0, 120);           

        triangle(toppoint.x, toppoint.y, lpt.x, lpt.y, rpt.x, rpt.y);
      }

      //if left of plane
      if (b[i].equals("1") && i==1) {
        triangle(rpt.x, rpt.y, rightpoint.x, rightpoint.y, rpt.x, rightpoint.y);
      }

      // if right in front
      if (b[i].equals("1") && i==2) {
        rectMode(CORNERS);
        rect(lpt.x+2, lpt.y-2, rpt.x-2, rightpoint.y);
      }

      //if right of plane
      if (b[i].equals("1") && i==3) {
        triangle(lpt.x, lpt.y, leftpoint.x, leftpoint.y, lpt.x, leftpoint.y);
      }
    }
    popMatrix();
  }
  //
}