class Plane { //<>//
  PVector pos;
  PVector next, lookAhead;
  PShape airplane = loadShape("Objects/Airplane_silhouette.svg");
  String dir = "N";
  int fill;
  float angle;
  boolean turn = false;
  float f = 0.4;
  float dT = 180/(4*lps*f);
  float theta;
  float radius = scalex * f;
  float mag = radius * dT * (PI/180);

  Plane(float x, float y, int fill) {
    this.pos = new PVector(0, 0);
    this.pos.x = x;
    this.pos.y = y;
    this.fill = fill;
    this.angle = vecFromString(dir).heading();
    this.turn = false;
  }

  void update(String step1, String step2) {      // "N", "E"
    if (this.turn) {
      if (PVector.angleBetween(this.next, this.lookAhead)<PI) {    // if it's a 90 degree turn:
        this.theta += dT;
        // weighted sum of next and next-next (called lookAhead) using cos() and sin()
        PVector n = PVector.add(PVector.mult(this.lookAhead, sin(radians(this.theta))), PVector.mult(this.next, cos(radians(this.theta)))); 
        n.setMag(mag);              // mag is specified according to dS = r*dT
        this.angle = n.heading();
        this.pos.add(n);
        if (this.theta >= 90) {
          this.turn = false;
          this.theta = 0;
        }
      } else {                                                   // if this is a 180 degree turn:
        this.theta += 2*dT;
        PVector heading = PVector.fromAngle(this.angle);         // get the current heading (akin to velocity vector)
        heading.setMag(mag);
        PVector L = new PVector();
        PVector.cross(heading, new PVector(0, 0, 1), L);          // perpendicular vector
        L.mult(2*mag*mag/radius);                                   // |a| = v^2/r
        L.add(heading);                                             // v_n ~ a + v_(n-1)  
        //L.setMag(mag);                                            // dS = r*dT
        this.angle = L.heading();
        this.pos.add(L);
        println(this.theta, " ", degrees(this.angle));
        if (this.theta >= 110) {    // WHY ON EARTH IS THIS A PROBLEM AT ALL. todo: resolve this (L.mult(2) is also conspicuous)
          this.turn = false;
          this.theta = 0;
        }
      }
    } else {
      this.next = vecFromString(step1).mult(1/lps);
      this.lookAhead = vecFromString(step2).mult(1/lps);
      this.pos.add(this.next);
      this.angle = next.heading();
      //if (PVector.angleBetween(this.next, this.lookAhead) >= PI) {   
      //  this.turn = true;
      //}
      //if (!(step1.equals(step2)) && ((frameCount-1)%lps == int(lps*(1-f))) && PVector.angleBetween(this.next, this.lookAhead) < PI) {     // if we've got a turn coming up && we've reached where the radius starts
      if (!(step1.equals(step2)) && ((frameCount-1)%lps == int(lps*(1-f)))) {     // if we've got a turn coming up && we've reached where the radius starts
        this.turn = true;
      }
    }
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



  void show(float sizex, float sizey, String binary) {
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    //fill(255-fill);    // circle fill
    //strokeWeight(2);
    //stroke(fill);
    //ellipse(0, 0, 2.5*sizex, 2.5*sizey);

    rotate(this.angle - HALF_PI);
    rotate(-QUARTER_PI);          // the plane image is diagonal
    rotate(PI);                   // and backwards...
    airplane.disableStyle();
    fill(fill, 255);    
    //stroke(255-fill);
    //strokeWeight(2);
    //stroke(255);
    shapeMode(CENTER);
    shape(airplane, 0, 0, sizex*1.5, sizey*1.5);
    //radar(binary);
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
    rotate(PI/4);
    //// Green triangle underlay
    PVector toppoint = new PVector(0, -0.2*scalex);      // think of this as (0,0)...
    PVector rightpoint = new PVector(1.5*scalex, -(2.*scaley));
    PVector leftpoint = new PVector(-1.5*scalex, -(2.*scaley));
    noStroke();
    fill(0, 255, 0, 30);
    for (float t=0; t<1; t+=0.01) {
      fill(0, 255, 0, 2);
      triangle(toppoint.x, toppoint.y, 
        leftpoint.x*1.4*t*t, leftpoint.y*t*1.2, 
        rightpoint.x*1.4*t*t, rightpoint.y*t*1.2);
    }
    ////

    //// Red triangle overlay
    PVector lpmp = PVector.mult(leftpoint, 0.5);   //midpoint of the left side
    PVector rpmp = PVector.mult(rightpoint, 0.5);  // midpoint of the right side
    String[] b = new String[binary.length()];

    fill(255, 0, 0, 100);           // fill for the detected state

    for (int i = 0; i < binary.length(); i++) {
      b[i] = str(binary.charAt(i));
    }
    for (int i = 0; i<b.length; i++) {
      // if closest to plane
      if (b[i].equals("1") && i==0) {
        fill(255, 0, 0, 120);           
        triangle(toppoint.x, toppoint.y-5, lpmp.x+5, lpmp.y+5, rpmp.x-5, rpmp.y+5);
      }
      //if left of plane
      if (b[i].equals("1") && i==1) {
        triangle(rpmp.x, rpmp.y, rightpoint.x, rightpoint.y, rpmp.x, rightpoint.y);
      }
      // if farther ahead
      if (b[i].equals("1") && i==2) {
        rectMode(CORNERS);
        rect(lpmp.x+5, lpmp.y-5, rpmp.x-5, rightpoint.y+5);
      }
      //if right of plane
      if (b[i].equals("1") && i==3) {
        triangle(lpmp.x, lpmp.y, leftpoint.x, leftpoint.y, lpmp.x, leftpoint.y);
      }
    }
    popMatrix();
  }
  //
}