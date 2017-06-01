import processing.pdf.*;

PFont font;
PImage topo;
Table table, statetable;
TableRow row_indranil, staterow; //statetable is a single row; this structure for it makes getting values more concise
ArrayList<Table> wx =  new ArrayList<Table>();      // array list of Edward's weather states
ArrayList<Table> state =  new ArrayList<Table>();    // array list of Edward's states
// state Table format -> [Index, Binary(radar detection state), plane_x, plane_y, heading, airport_x, airport_y, wind speed, wind direction (degrees clockwise from south), airspace size_x, airspace size_y]
//                        [ 0,        1,                          2,        3,       4,        5,        6,            7,          8,                                              9,                  10    ] 
Table wx_indranil_table, state_indranil;
// wx_indranil format ->    [value value value value ... 150] 
//                          [value value value value ... 150] ...
// state_indarnil format ->  [step, plane_x, plane_y, heading, airport_x, airport_y]
//                           [step, plane_x, plane_y, heading, airport_x, airport_y]...
ArrayList<Table> wx_indranil = new ArrayList<Table>();

int rows, cols, scalex, scaley;
Plane plane, indranil;
PVector airplane, airport, airplane_indranil;
ArrayList<Cloud> clouds = new ArrayList<Cloud>();
//ArrayList<PVector> unitsquare = new ArrayList<PVector>();

int scenario = 14;
int time_per_move = 4;
//String beginfp = "/Users/tomer/Documents/Processing/WxRoutingAnim/Edward/Scenario"+str(scenario)+"_"+str(time_per_move)+"/";
String beginfp = "/Users/tarnon/Documents/Processing/WxRoutingAnim/Edward/Scenario"+str(scenario)+"_"+str(time_per_move)+"/";
String beginfp_indranil = "/Users/tarnon/Documents/Processing/WxRoutingAnim/Indranil/";

//String beginfp = "/C:/Users/Tomer/Documents/Processing/WxRoutingAnim/Edward/Scenario"+str(scenario)+"_"+str(time_per_move)+"/";
//String beginfp_indranil = "/Users/tomer/Documents/Processing/WxRoutingAnim/Indranil/";

File[] files = new File(dataPath(beginfp)).listFiles(); 
File[] files_indranil = new File(dataPath(beginfp_indranil)).listFiles();

String pdf = "images/" + str(scenario) + "_" + str(time_per_move) + ".pdf";

boolean savepdf = false;
boolean saveframe = true;

Float lps = 30.0;     // lerps per step
int index = 0;


void setup() {
  //size(495, 350, PDF, pdf); 
  size(900, 600, P2D); 
  if (!savepdf) {
    frameRate(60);
  }

  topo = loadImage("Objects/gEarth.png");
  topo.resize(width, height);
  shapeMode(CENTER);
  //unitsquare(unitsquare, 0.2); // .2 is 2*(360/9/4), the number of dots per side of square to match the PShape cloud

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

  //Load Indranil's .csv data
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
  //wx_indranil = reshape(wx_indranil, wx_indranil_table);



  // set some global stuff from this data
  TableRow r = state.get(index).getRow(0);
  TableRow I = state_indranil.getRow(index); 
  airport = new PVector(r.getInt(5)-1, r.getInt(6)-1);
  rows = r.getInt(10);
  cols = r.getInt(9);
  scalex = floor(width/rows);
  scaley = floor(height/cols);

  airplane = new PVector(r.getInt("plane_y")-1, r.getInt("plane_x")-1);
  airplane_indranil = new PVector(I.getInt(1)-1, I.getInt(2)-1);

  plane = new Plane(airplane.x * scalex, airplane.y * scaley, 0);
  indranil = new Plane(airplane_indranil.x * scalex, airplane_indranil.y * scaley, 255);

  //font = createFont("Arial", 12);
  //textFont(font, 12);
}






void draw() {
  //background(0);

  table = wx.get(index);
  staterow = state.get(index).getRow(0);
  //wx_indranil_table = wx_indranil.get(index);
  //row_indranil = state_indranil.getRow(index);

  //airplane = new PVector(staterow.getInt("plane_y")-1, staterow.getInt("plane_x")-1);

  if (index + 1 < wx.size()) { // can we see one step ahead?
    PVector waypoint = new PVector(staterow.getInt("plane_y")-1, staterow.getInt("plane_x")-1);
    //if (index + 1 < state_indranil.getRowCount()) {
    TableRow nextstate = state.get(index+1).getRow(0);
    String step1 = nextstate.getString("Heading");
    if (index + 2 < wx.size()) {   // can we also see two steps ahead?
      //if (index + 2 < state_indranil.getRowCount()) {
      String step2 = state.get(index+2).getString(0, "Heading");
      plane.update(waypoint, step1, step2);
    } else {    // if only one step ahead, use the next heading as-is.
      plane.update(waypoint, step1, step1);
    }
  }
  //if (index + 1 < wx.size()) { // can we see one step ahead?
  if (index + 1 < state_indranil.getRowCount()) {
    PVector waypoint = new PVector(state_indranil.getInt(index, 1)-1, state_indranil.getInt(index, 2)-1);
    String step1 = state_indranil.getString(index+1, 3);
    //if (index + 2 < wx.size()) {   // can we also see two steps ahead?
    if (index + 2 < state_indranil.getRowCount()) {
      String step2 = state_indranil.getString(index+2, 3);
      indranil.update(waypoint, step1, step2);
      indranil.avoid(plane, "up");
    } else {    // if only one step ahead, use the next heading as-is.
      indranil.update(waypoint, step1, step1);
      indranil.avoid(plane, "up");
    }
  }






  for (Cloud c : clouds) {    // reset all of the survives values
    c.survives = false;
  }
  float x, y, value;
  PVector newpos;
  for (int i=0; i<table.getRowCount(); i++) {    // go row by row of new data
    x = (table.getInt(i, 1)-1)*scalex;
    y = (table.getInt(i, 0)-1)*scaley;
    value = table.getInt(i, 2);
    newpos = new PVector(x, y);          // hypothetical cloud position
    boolean exists = false;                      // does a cloud already exist at this location?
    for (Cloud c : clouds) {
      if (c.pos.equals(newpos) && abs(c.value-value)<1.5) { // is this cloud position occupied from last time? If so, is the cloud currently occupying it similar to the one we're checking against?
        c.survives = true;                      // in that case that cloud gets to live another day!
        exists = true;                          // Also note that this row is matched and a new cloud doesn't need to be made.
        c.update(x, y, value);      // update the value of the surviving cloud
        break;
      }
      if (exists) break;
    }
    if (!exists) {                            // if the cloud doesn't already exist, make new one for that spot
      Cloud cloud = new Cloud(x, y, value);
      clouds.add(cloud);
    }
  }
  for (int i = clouds.size()-1; i>=0; i-- ) {
    Cloud c = clouds.get(i);
    if (!c.survives) {
      clouds.remove(c);
    }
  }
  for (Cloud c : clouds) {    // reset all of the survives values
    c.checkForNeighbors();
  }




  pushMatrix();
  translate(scalex/2, scaley/2);  // move by half of one square to center everything
  background(topo);

  fill(255, 80);
  rectMode(CORNER);
  rect(-100, -100, width+100, height+100);

  // grid lines
  strokeWeight(1);
  stroke(0, 100);
  for (int j=0; j < cols; j++) line(-100, j*scaley + scaley/2, width+100, j*scaley + scaley/2);
  for (int i=0; i < rows; i++) line(i*scalex + scalex/2, -100, i*scalex + scalex/2, height+100);

  // show the clouds
  shapeMode(CENTER);
  for (Cloud c : clouds) {
    c.show();
  }

  //Path(state, index);                                               // real path taken to airport
  //runway(int(airport.x) * scalex, int(airport.y) * scaley, 0);      // airport
  runway(int(airport.x) * scalex, int(airport.y) * scaley);         // airport

  if (indranil.avoid) {
    plane.show(scalex/5, scaley/5);                               // edward's plane
    indranil.show(scalex/5, scaley/5);                            // indranil's plane
  } else {
    plane.show(scalex/4, scaley/4);                               // edward's plane
    indranil.show(scalex/4, scaley/4);                            // indranil's plane
  }
  compass((rows-1.5), 0.5, staterow.getInt(7), staterow.getInt(8));
  legend((rows-3)*scalex, (0)*scaley);

  popMatrix();








  //if (index + 1 < wx.size()) {
  if (index + 1 < state_indranil.getRowCount()) {
    if (savepdf) {
      PGraphicsPDF pdf = (PGraphicsPDF) g; 
      pdf.nextPage();
    }
    if (frameCount%lps == 0) index+=1;
  } else {
    if (savepdf) exit();
    //index = 0;
    noLoop();
  }

  if (saveframe) {
    if (index<10)  saveFrame("images/" + str(scenario) + "_" + str(time_per_move) + "/"  + "0" + str(index) + "_" + "####" + ".png");
    else           saveFrame("images/" + str(scenario) + "_" + str(time_per_move) + "/"  + str(index) + "_" + "####" + ".png");
  }
  //noLoop();
}






void mousePressed() {
  //int step = 1;
  if (index + 1 > wx.size()) index=0;
  redraw();
}

void keyPressed() {
  if (key =='s' || key=='S') {
    saveFrame("images/" + str(scenario) + "_" + str(time_per_move) + "_" + str(index) + ".png");
    // example filename:  ../images/34_4_14.png
    println("saved");
  }
}