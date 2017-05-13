import processing.pdf.*;

PFont font;
Table table, statetable;
TableRow row_indranil, staterow; //statetable is a single row; this structure makes getting values more concise
ArrayList<Table> wx =  new ArrayList<Table>();      // array list of all weather states
ArrayList<Table> state =  new ArrayList<Table>();    // array list of all states
// state -> [Index, Binary(radar detection state), plane_x, plane_y, heading, airport_x, airport_y, wind speed, wind direction (degrees clockwise from south), airspace size_x, airspace size_y]
// wx -> [cloud1_x, cloud1_y, value]
//       [cloud2_x, cloud2_y, value] ...

Table wx_indranil_table, state_indranil;
// wx_indranil -> [value value value value ... 150] 
//                [value value value value ... 150] ...
// state_indarnil -> [step, plane_x, plane_y, heading, airport_x, airport_y]
//                   [step, plane_x, plane_y, heading, airport_x, airport_y]...
ArrayList<Table> wx_indranil = new ArrayList<Table>();

int rows, cols, scalex, scaley, index=0;
Plane plane;
Plane indranil;
PVector airplane, airport, airplane_indranil;

int scenario = 32;
int time_per_move = 2;
String beginfp = "/Volumes/31G/WxRouting/Scenario"+str(scenario)+"_"+str(time_per_move)+"/";
String beginfp_indranil = "/Volumes/31G/WxRouting/Indranil/";
File[] files = new File(dataPath(beginfp)).listFiles(); 
File[] files_indranil = new File(dataPath(beginfp_indranil)).listFiles();

String pdf = "images/" + str(scenario) + "_" + str(time_per_move) + ".pdf";
boolean savepdf = false;





void setup() {
  //size(495, 350, PDF, pdf); 
  size(495, 350); 

  shapeMode(CENTER);
  plane = new Plane(0, 0, 0);
  indranil = new Plane(0, 0, 255);

  // Load Edward's .csv data
  for (int i=0; i<files.length; i++) {
    String filename = files[i].getAbsolutePath();
    String[] match_wx = match(filename, "wx");
    if (match_wx == null) {                 // if the filename doesn't have "wx" in it
      statetable = loadTable(filename, "header");
      state.add(statetable);
    } else {                                // if the filename _does_ have "wx" in it
      table = loadTable(filename, "header");
      wx.add(table);
    }
  }
  // set some stuff
  TableRow r = state.get(0).getRow(0);
  airport = new PVector(r.getInt(5)-1, r.getInt(6)-1);
  rows = r.getInt(10);
  cols = r.getInt(9);
  scalex = floor(width/rows);
  scaley = floor(height/cols);


  // Load Indranil's .csv data
  for (int i=0; i<files_indranil.length; i++) {
    String filename = files_indranil[i].getAbsolutePath();
    String[] match_scenario = match(filename, str(scenario));
    if (match_scenario != null) {                 // if the filename has the scenario number in it
      String[] match_wx = match(filename, "WX");
      if (match_wx==null) {                       // check to see if it has "WX" in it
        state_indranil = loadTable(filename, "header");
      } else {
        wx_indranil_table = loadTable(filename, "header");
      }
    }
  }

  // convert Indranil's Wx table
  for (int i=0; i<wx_indranil_table.getRowCount(); i++) {
    TableRow row =  wx_indranil_table.getRow(i);
    Table temp = new Table();
    temp.addColumn("CloudX");
    temp.addColumn("CloudY");
    temp.addColumn("value");
    for (int j=0; j<wx_indranil_table.getColumnCount(); j++) {
      Float value = row.getFloat(j);
      if (value>1) {
        int x = (j - j%rows)/rows;
        int y = j%rows;
        TableRow newrow = temp.addRow();
        newrow.setInt("CloudX", x);
        newrow.setInt("CloudY", y);
        newrow.setFloat("value", value);
      }
    }
    wx_indranil.add(temp);
  }
  saveTable(state_indranil, "table.csv");

  font = createFont("Arial-Black", 25);
  //font = createFont("AppleMyungjo", 18);
  //font = createFont("DevanagariMT-Bold", 25);
  textFont(font, 18);
}






void draw() {
  background(255);
  //index = 0;

  table = wx.get(index);
  wx_indranil_table = wx_indranil.get(index);
  staterow = state.get(index).getRow(0);
  TableRow row_indranil = state_indranil.getRow(index);

  //saveTable(wx_indranil_table, "table.csv");

  airplane = new PVector(staterow.getInt(3)-1, staterow.getInt(2)-1);
  airplane_indranil = new PVector(row_indranil.getInt(1)-1, row_indranil.getInt(2)-1);
  PVector samespace = PVector.sub(airplane, airplane_indranil);

  if (samespace.mag() == 0) {
    plane.update(airplane.x * scalex, (airplane.y + 0.3) * scaley, staterow.getString(4));
    indranil.update(airplane_indranil.x * scalex, (airplane_indranil.y - 0.3) * scaley, row_indranil.getString(3));
    //plane.update(airplane.x * scalex, airplane.y * scaley, staterow.getString(4));
    //indranil.update(airplane_indranil.x * scalex, airplane_indranil.y * scaley, row_indranil.getString(3));
  } else {
    plane.update(airplane.x * scalex, airplane.y * scaley, staterow.getString(4));
    indranil.update(airplane_indranil.x * scalex, airplane_indranil.y * scaley, row_indranil.getString(3));
  }

  pushMatrix();
  stroke(0, 255);
  strokeWeight(2);
  noFill();
  rect(1, 1, width-1, height-1);
  translate(scalex/2, scaley/2);  // move by half of one square to center everything

  // grid lines
  strokeWeight(1);
  stroke(50, 50);
  for (int j=0; j < cols; j++) {
    line(-100, j*scaley + scaley/2, width+100, j*scaley + scaley/2);
  }
  for (int i=0; i < rows; i++) {
    line(i*scalex + scalex/2, -100, i*scalex + scalex/2, height+100);
  }
  //


  // PATH
  strokeJoin(ROUND);
  beginShape();
  noFill();
  for (int i=index; i<wx.size(); i++) {
    staterow = state.get(i).getRow(0);

    float current_x= staterow.getInt(3)-1;
    float current_y= staterow.getInt(2)-1;
    if (i==index && i<wx.size()-1) {
      current_x = adjustx(current_x);
      current_y = adjusty(current_y);
    }
    airplane = new PVector(current_x, current_y);

    stroke(0);
    strokeWeight(3);
    //vertex(airplane.x * scalex, airplane.y * scaley);
  }
  endShape();
  //

  //RUNWAY
  runway(int(airport.x) * scalex, int(airport.y) * scaley);
  //
  //DRAW AIRPLANE
  if (samespace.mag() == 0) {
    println("samespace");
    //indranil.show(scalex/8, scaley/8);
    //plane.show(scalex/8, scaley/8);
    plane.show(scalex/4, scaley/4, true, true);
    indranil.show(scalex/4, scaley/4, true, false);
  } else {
    plane.show(scalex/4, scaley/4, false, false);
    indranil.show(scalex/4, scaley/4, false, false);
  }
  //

  // CLOUDS
  for (int i=0; i<table.getRowCount(); i++) {
    int y= table.getRow(i).getInt(0) -1; 
    int x = table.getRow(i).getInt(1) -1; 
    float value = table.getRow(i).getInt(2); 
    value = round(value * 10) * 0.1;
    String v = str(value);
    noStroke();
    fill(100, 200);
    rectMode(CENTER);
    rect(x*scalex, y*scaley, scalex, scaley);
    textAlign(CENTER, CENTER);
    textSize(18);
    fill(255);
    //text(v, x*scalex, y*scaley);
    rectMode(CORNER);
  }

  //table = wx_indranil_table;
  //for (int i=0; i<table.getRowCount(); i++) {
  //  int y= table.getRow(i).getInt(0); 
  //  int x = table.getRow(i).getInt(1) -1; 
  //  float value = table.getRow(i).getInt(2); 
  //  value = round(value * 10) * 0.1;
  //  String v = str(value);
  //  noStroke();
  //  fill(0, 200);
  //  rect(x*scalex - scalex/2 +10, y*scaley - scaley/2 +10, scalex-10, scaley-10);
  //  textAlign(CENTER, CENTER);
  //  textSize(18);
  //  fill(255);
  //  //text(v, x*scalex, y*scaley);
  //}
  //

  popMatrix();

  if (savepdf) {
    if (index + 1 < wx.size()) {
      PGraphicsPDF pdf = (PGraphicsPDF) g; 
      pdf.nextPage();

      index += 1;
    } else { 
      //index=0;
      exit();
    }
  }

  //noLoop();
}






void mousePressed() {
  int step = 1;
  if (index + step < wx_indranil.size()) {
    index+=step;
    if (savepdf) {
    }
  } else { 
    index=0;
  }
  redraw();
}

void keyPressed() {
  if (key =='s' || key=='S') {
    saveFrame("images/" + str(scenario) + "_" + str(time_per_move) + "_" + str(index) + ".png");
    // example filename:  ../images/34_4/14.png
    println("saved");
  }
}


float adjustx(float x) {
  String h = state.get(index+1).getRow(0).getString(4);
  if (h.equals("E")) {
    x += 0.3;
  }
  if (h.equals("W")) {
    x += -0.3;
  }
  return x;
}
float adjusty(float y) {
  String h = state.get(index+1).getRow(0).getString(4);
  if (h.equals("S")) {
    y += 0.3;
  }
  if (h.equals("N")) {
    y += -0.3;
  }
  return y;
}