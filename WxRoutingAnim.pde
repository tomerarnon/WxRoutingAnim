import processing.pdf.*;

PFont font;
Table table, statetable;
TableRow row_indranil, staterow; //statetable is a single row; this structure for it makes getting values more concise
ArrayList<Table> wx =  new ArrayList<Table>();      // array list of Edward's weather states
ArrayList<Table> state =  new ArrayList<Table>();    // array list of Edward's states
// state Table format -> [Index, Binary(radar detection state), plane_x, plane_y, heading, airport_x, airport_y, wind speed, wind direction (degrees clockwise from south), airspace size_x, airspace size_y]
//                        [ 0,        1,                          2,        3,       4,        5,        6,            7,          8,                                              9,                  10    ] 
// wx Table format ->     [cloud1_x, cloud1_y, value]
//                        [cloud2_x, cloud2_y, value] ...
Table wx_indranil_table, state_indranil;
// wx_indranil format ->    [value value value value ... 150] 
//                          [value value value value ... 150] ...
// state_indarnil format ->  [step, plane_x, plane_y, heading, airport_x, airport_y]
//                           [step, plane_x, plane_y, heading, airport_x, airport_y]...
ArrayList<Table> wx_indranil = new ArrayList<Table>();

int rows, cols, scalex, scaley, index=0;
Plane plane;
Plane indranil;
PVector airplane, airport, airplane_indranil;

int scenario = 14;
int time_per_move = 4;
String beginfp = "/Users/tomer/Documents/Processing/WxRoutingAnim/Edward/Scenario"+str(scenario)+"_"+str(time_per_move)+"/";
String beginfp_indranil = "/Users/tomer/Documents/Processing/WxRoutingAnim/Indranil/";
File[] files = new File(dataPath(beginfp)).listFiles(); 
File[] files_indranil = new File(dataPath(beginfp_indranil)).listFiles();
String pdf = "images/" + str(scenario) + "_" + str(time_per_move) + ".pdf";

boolean savepdf = false;
boolean saveframe = false;

Float lps = 15.0;     // lerps per step



void setup() {
  //size(495, 350, PDF, pdf); 
  size(495, 350); 
  if (!savepdf) {
    frameRate(999);
  }

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
  // set some global stuff from this data
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
        wx_indranil_table = loadTable(filename);
      }
    }
  }
  // convert Indranil's Wx table
  wx_indranil = reshape(wx_indranil, wx_indranil_table);

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
  row_indranil = state_indranil.getRow(index);

  airplane = new PVector(staterow.getInt("plane_y")-1, staterow.getInt("plane_x")-1);
  airplane_indranil = new PVector(row_indranil.getInt(1)-1, row_indranil.getInt(2)-1);

  if (index + 1 <= wx.size()-1) {
    TableRow staterownext = state.get(index+1).getRow(0);
    PVector ednext = new PVector(staterownext.getInt("plane_y")-1, staterownext.getInt("plane_x")-1);   // y and x are reversed for this plane
    float stepsize = ((frameCount-1)%lps)/lps;
    PVector lerped = new PVector(lerp(airplane.x, ednext.x, stepsize), lerp(airplane.y, ednext.y, stepsize));
    airplane = lerped;

    plane.update(airplane.x * scalex, airplane.y * scaley, staterownext.getString("Heading"));
  } else {
    plane.update(airplane.x * scalex, airplane.y * scaley, staterow.getString("Heading"));
  }

  if (index + 1 < state_indranil.getRowCount()) {
    TableRow row_indranil_next = state_indranil.getRow(index + 1);
    PVector indnext = new PVector(row_indranil_next.getInt(1)-1, row_indranil_next.getInt(2)-1);
    float stepsize = ((frameCount-1)%lps)/lps;
    PVector lerped = new PVector(lerp(airplane_indranil.x, indnext.x, stepsize), lerp(airplane_indranil.y, indnext.y, stepsize));
    airplane_indranil = lerped;

    indranil.update(airplane_indranil.x * scalex, airplane_indranil.y * scaley, row_indranil_next.getString(3));
    plane.avoid(indranil, "up");
  } else {
    indranil.update(airplane_indranil.x * scalex, airplane_indranil.y * scaley, row_indranil.getString(3));
    plane.avoid(indranil, "up");
  }

  pushMatrix();
  stroke(0, 255);
  strokeWeight(2);
  noFill();
  rect(1, 1, width-1, height-1);  // border outline
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
  //Path(state, index);
  //Path_indranil(state_indranil, index);


  // CLOUDS
  for (int i=0; i<table.getRowCount(); i++) {
    int y = table.getRow(i).getInt("CloudX") -1; 
    int x = table.getRow(i).getInt("CloudY") -1; 
    //float value = table.getRow(i).getInt(2); 
    //value = round(value * 10) * 0.1;
    //String v = str(value);
    noStroke();
    fill(100, 200);
    rectMode(CENTER);
    rect(x*scalex, y*scaley, scalex, scaley);
    textAlign(CENTER, CENTER);
    textSize(18);
    fill(255);
    //text(v, x*scalex, y*scaley);
    //rectMode(CORNER);
  }

  //RUNWAY
  runway(int(airport.x) * scalex, int(airport.y) * scaley);
  //
  //DRAW AIRPLANES
  plane.show(scalex/4, scaley/4);
  indranil.show(scalex/4, scaley/4);
  //
  popMatrix();

  if (index + 1 < state_indranil.getRowCount()) {
    if (savepdf) {
      PGraphicsPDF pdf = (PGraphicsPDF) g; 
      pdf.nextPage();
    }
    if (frameCount%lps == 0) {
      index+=1;
    }
  } else {
    if (savepdf) {
      exit();
    }
    //index = 0;
    noLoop();
  }

  if (saveframe) {
    if (index<10) {
      saveFrame("images/" + str(scenario) + "_" + str(time_per_move) + "/"  + "0" + str(index) + "_" + "###" + ".png");
    } else { 
      saveFrame("images/" + str(scenario) + "_" + str(time_per_move) + "/"  + str(index) + "_" + "###" + ".png");
    }
  }
      //noLoop();

}






void mousePressed() {
  int step = 1;
  if (index + step < state_indranil.getRowCount()) {
    //index+=step;
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
    // example filename:  ../images/34_4_14.png
    println("saved");
  }
}