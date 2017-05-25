class Cloud {
  PVector pos;
  float value;
  PShape shape = createShape();
  boolean survives;
  Cloud[] neighbors;
  ArrayList<PShape> circles = new ArrayList<PShape>();
  color col1 = color(#AF1013);   // red
  color col2 = color(#EEF222);   // yellow
  color col3 = color(#22A012);   // green
  color c;

  Cloud(float x, float y, float _value) {
    this.pos = new PVector(x, y); 
    this.value = _value;
    //this.shape = randomShape();
    this.neighbors = new Cloud[4];
    this.survives = true;

    populate();
  }

  void update(float x, float y, float _value) {
    this.pos = new PVector(x, y); 
    this.value = _value;
    //circles = new ArrayList<PShape>();
    //populate();
    decimate();
  }

  //PShape randomShape() {
  //  PShape s = createShape();
  //  s.beginShape();
  //  float rand = random(100);

  //  for (int theta=45; theta<405; theta+=9) {
  //    float r = scalex/2;
  //    float noise = noise(rand+theta/80);
  //    noise -= 0.5;
  //    noise *= scalex;
  //    r += noise;
  //    //r += random(1)*scalex/5;
  //    PVector vec = PVector.fromAngle(radians(theta));
  //    vec.mult(0.5 * r);
  //    s.vertex(vec.x, vec.y);
  //  }
  //  s.endShape(CLOSE);
  //  return s;
  //}

  //void show() {
  //  shapeMode(CORNER);
  //  this.shape.setStrokeWeight(0);
  //  float amt = map(this.value, 0, 6.0, 0, 1); 
  //  //color c = amt >= 0.5 ? lerpColor(col1, col2, map(amt, 0.5, 1, 0, 1)) : lerpColor(col2, col3, map(amt, 0, 0.5, 0, 1)); 
  //  color c = amt >= 0.35 ? col2 : col3; 
  //  c = amt >= 0.75 ? col1 : c;
  //  this.c = color(c);
  //  lerpshape();
  //  this.shape.setFill(this.c);
  //  //shape(this.shape, this.pos.x, this.pos.y);
  //}

  void show() {
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    translate(scalex/2, scaley/2);
    for (int i =0; i<circles.size(); i++) {
      PShape cir = circles.get(i); 
      shape(cir);
    }
    popMatrix();
  }

  void populate() {
    float w = scalex;
    float h = scaley;
    for (int i=0; i<int(this.value*200); i++) {
      PShape cir = makeCircle(w, h); 
      circles.add(cir);
    }
  }

  void decimate() {
    float w = scalex;
    float h = scaley;
    for (int i=0; i<2; i++) {
      PShape cir = makeCircle(w, h); 
      circles.remove(i);
      circles.add(cir);
    }
  }

  PShape makeCircle(float w, float h) {
    float randy = random(-w/2, w/2);
    float randx = random(-h/2, h/2);
    float randrad1 = random(1) * w/1.3;
    float randrad2 = random(1) * h/1.3;
    float fillcol = map(this.value, 1, 7, 220, 40);
    fillcol += random(-30, 30);
    PShape cir = createShape(ELLIPSE, randx, randy, randrad1, randrad2);
    cir.setFill(color(fillcol, 20));
    cir.setStrokeWeight(0);
    return cir;
  }



  void lerpshape() {
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    int vcount = this.shape.getVertexCount();
    float iter = 2;
    for (float j = iter; j>=0; j--) {
      for (int n = 0; n < 4; n++) {
        color col = lerpFill(n, map(j/iter, 0, 1, 0.1, 1));
        fill(color(col), 255);
        noStroke();
        lerpSection(n*vcount/4, (n+1)*vcount/4, j/iter);
      }
    }
    popMatrix();
  }

  void lerpSection(int start, int stop, float amt) {
    beginShape(); 
    vertex(0, 0);
    if (stop < this.shape.getVertexCount()) {
      for (int i = start; i <= stop; i++) {
        PVector v = this.shape.getVertex(i); 
        PVector vs = PVector.mult(unitsquare.get(i), 4*scalex/2); 
        v.lerp(vs, amt/5); 
        vertex(v.x, v.y);
      }
    } else {
      for (int i = start; i <= stop; i++) {
        int l = i% this.shape.getVertexCount();
        PVector v = this.shape.getVertex(l); 
        PVector vs = PVector.mult(unitsquare.get(l), 4*scalex/2); 
        v.lerp(vs, amt/5); 
        vertex(v.x, v.y);
      }
    }

    endShape(CLOSE);
  }

  color lerpFill(int n, float amt) {
    color col;
    if (this.neighbors[n] != null) {
      col = lerpColor(this.c, this.neighbors[n].c, amt/2);
    } else {
      col = this.c;
      //col = lerpColor(col, color(0, 0, 0), amt/2);
    }

    col = lerpColor(col, color(#0A133E), amt/2);

    return col;
  }

  void checkForNeighbors() {
    this.neighbors[0] = null; 
    this.neighbors[1] = null; 
    this.neighbors[2] = null; 
    this.neighbors[3] = null; 

    for (Cloud c : clouds) {
      PVector diff = PVector.sub(this.pos, c.pos); 
      float mag = diff.mag();

      if (mag==scalex || mag == scaley) {
        diff.normalize(); 
        if (diff.x == -1) {         // c is below this cloud
          this.neighbors[0] = c;
        }
        if (diff.x == 1) {         // c is to the left of this cloud
          this.neighbors[1] = c;
        }
        if (diff.y == 1) {         // c is above this cloud
          this.neighbors[2] = c;
        }     
        if (diff.x == -1) {        // c is to the right of this cloud
          this.neighbors[3] = c;
        }

        //float ang = diff.heading();
        //if (ang == HALF_PI) {         // c is below this cloud
        //  this.neighbors[0] = c;
        //}
        //if (ang == PI) {             // c is to the left of this cloud
        //  this.neighbors[1] = c;
        //}
        //if (ang == -HALF_PI) {         // c is above this cloud
        //  this.neighbors[2] = c;
        //}     
        //if (ang == 0) {            // c is to the right of this cloud
        //  this.neighbors[3] = c;
        //}
      }
    }
  }
}