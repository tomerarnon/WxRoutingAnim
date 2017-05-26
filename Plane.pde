class Plane { //<>// //<>// //<>//
  PVector pos;
  PVector next, lookAhead;
  PShape airplane = loadShape("Objects/Airplane_silhouette.svg");
  String dir = "N";
  int fill;
  Float angle;
  int turnCount;
  boolean turn= false;
  float f = 0.4;
  float dT = PI/(4*lps*f);

  Plane(float x, float y, int fill) {
    this.pos = new PVector(0, 0);
    this.pos.x = x;
    this.pos.y = y;
    this.fill = fill;
    this.angle = vecFromString(dir).heading();
    this.turnCount = 0;
    this.turn = false;
  }

  void update(String step1, String step2) {      // "N", "E"
    float theta = -1;
    if (this.turn) {
      theta = this.turnCount*dT; 
      this.turnCount += 1;
      if (this.turnCount == int(2*lps*f)) {
        this.turn = false;
        this.turnCount = 0;
      }
      //float radius = scalex * f/lps;
      //float dx = radius * cos(theta);
      //float dy = radius * sin(theta);
      PVector lA = PVector.mult(this.lookAhead, sin(theta));
      PVector n = PVector.mult(this.next, cos(theta));
      n.add(lA);
      print("||| next: ", nfc(n.x, 3), ", ", nfc(n.y, 3));
      print("||| Theta: ", nfc(theta/PI, 5));
      this.angle = n.heading();
      this.pos.add(n);
      //this.angle = new PVector(dx,dy).heading();
      //this.pos.x += dx;
      //this.pos.y += dy;
    } else {
      this.next = vecFromString(step1);
      this.lookAhead = vecFromString(step2);
      this.next.mult(1/lps);
      print("||| next: ", nfc(this.next.x, 3), ", ", nfc(this.next.y, 3));
      this.lookAhead.mult(1/lps);
      this.pos.add(next);
      this.angle = next.heading();
      if (!(step1.equals(step2)) && ((frameCount)%lps == int(lps*(1-f)))) {     // if we've got a turn coming up:
        if (PVector.angleBetween(this.next, this.lookAhead)<PI) {    // if it isn't a full reverse, do this:
          this.turn = true;
        }
        this.turn = true;
      }
    }
    if (theta == -1) print("||| Theta: ", nfc(theta, 5));
    print("||| ", nfc((frameCount-1)%lps, 1), "; ");
    println("||| ", "pos: ", int(this.pos.x), ", ", int(this.pos.y));
  }


  PVector vecFromString(String d) {
    float angle = HALF_PI;
    PVector vec;
    float mag = scaley;
    if (d.equals("S")) {
      angle = -HALF_PI;
    } else if (d.equals("E")) {
      angle = PI;
      mag = scalex;
    } else if (d.equals("W")) {
      angle = 0;
      mag = scalex;
    }
    vec = PVector.fromAngle(angle);
    vec.setMag(mag);
    vec.rotate(PI);
    return vec;
  }

  //PVector arcDelta(PVector r, float inc) {
  //  PVector arc = r 

  //    return arc;
  //}

  float turn(String d, String dnext, float stepsize) {
    float angle = 0;
    if (this.angle==null) {
      angle += PI;
      if (d.equals("S")) {
        angle += PI;
      } else if (d.equals("E")) {
        angle += HALF_PI;
      } else if (d.equals("W")) {
        angle -= HALF_PI;
      }
    } else { 
      angle = this.angle;
    }
    //angle -= QUARTER_PI;      // the plane image is diagonal

    float anglenext = 0.0;
    anglenext += PI;
    if (dnext.equals("S")) {
      anglenext += PI;
    } else if (dnext.equals("E")) {
      anglenext += HALF_PI;
    } else if (dnext.equals("W")) {
      anglenext -= HALF_PI;
    }

    //angle = angle % TWO_PI;
    //anglenext = anglenext % TWO_PI;

    if ((abs(angle-anglenext) <= PI/2) || ((abs(angle-anglenext)-PI) <= PI/2)) {
      if (stepsize >= (lps-5)/lps) {
        if (stepsize>0.9) { 
          stepsize = 1.0;
        } else { 
          stepsize /= 2;
        }
        angle = lerp(angle, anglenext, stepsize);
      }
    } else if (stepsize >= (lps-1)/lps) {
      angle = (angle + PI)%TWO_PI;
    }
    return angle;
  }



  void show(float sizex, float sizey) {
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    //fill(255-fill);    // circle fill
    //strokeWeight(1);
    //stroke(fill);
    //ellipse(0, 0, 4*sizex, 4*sizey);

    rotate(this.angle - HALF_PI);
    rotate(-QUARTER_PI);      // the plane image is diagonal
    rotate(PI);              // and backwards...
    airplane.disableStyle();
    fill(fill, 255);     
    //strokeWeight(2);
    //stroke(255);
    shapeMode(CENTER);
    shape(airplane, 0, 0, sizex*2, sizey*2);
    //chevron(sizex, sizey);
    popMatrix();
  }

  void avoid(Plane other, String _dir) {
    PVector dist = PVector.sub(this.pos, other.pos);
    if (dist.mag() == 0) {
      if (_dir.equals("up")) {
        this.pos.y += (0.3 * scaley);
        other.pos.y -= (0.3 * scaley);
      }
      if (_dir.equals("down")) {
        this.pos.y -= (0.3 * scaley);
        other.pos.y += (0.3 * scaley);
      }
    }
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

    //// Red triangle overlay
    PVector lpt = PVector.mult(leftpoint, 0.5);   //midpoint of the left side
    PVector rpt = PVector.mult(rightpoint, 0.5);  // midpoint of the right side
    String[] b = new String[binary.length()];

    fill(255, 0, 0, 100);           // fill for the detected state

    for (int i = 0; i < binary.length(); i++) {
      b[i] = str(binary.charAt(i));
    }
    for (int i = 0; i<b.length; i++) {
      // if closest to plane
      if (b[i].equals("1") && i==0) {
        fill(255, 0, 0, 120);           
        triangle(toppoint.x, toppoint.y, lpt.x, lpt.y, rpt.x, rpt.y);
      }
      //if left of plane
      if (b[i].equals("1") && i==1) {
        triangle(rpt.x, rpt.y, rightpoint.x, rightpoint.y, rpt.x, rightpoint.y);
      }
      // if farther ahead
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