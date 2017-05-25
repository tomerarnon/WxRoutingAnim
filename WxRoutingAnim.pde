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

int rows, cols, scalex, scaley;
Plane plane;
Plane indranil;
PVector airplane, airport, airplane_indranil;
ArrayList<Cloud> clouds = new ArrayList<Cloud>();
ArrayList<PVector> unitsquare = new ArrayList<PVector>();

int scenario = 14;
int time_per_move = 4;
int index=0;
String beginfp = "/Users/tomer/Documents/Processing/WxRoutingAnim/Edward/Scenario"+str(scenario)+"_"+str(time_per_move)+"/";
String beginfp_indranil = "/Users/tomer/Documents/Processing/WxRoutingAnim/Indranil/";
File[] files = new File(dataPath(beginfp)).listFiles(); 
File[] files_indranil = new File(dataPath(beginfp_indranil)).listFiles();
String pdf = "images/" + str(scenario) + "_" + str(time_per_move) + ".pdf";

boolean savepdf = false;
boolean saveframe = true;

Float lps = 20.0;     // lerps per step



void setup() {
  //size(495, 350, PDF, pdf); 
  size(500, 350, P2D); 
  if (!savepdf) {
    frameRate(30);
  }
  smooth();
  shapeMode(CENTER);
  plane = new Plane(0, 0, 255);
  //indranil = new Plane(0, 0, 255);
  unitsquare(unitsquare, 0.2); // .2 is 2*(360/9/4), the number of dots per side of square to match the PShape cloud

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
  //for (int i=0; i<files_indranil.length; i++) {
  //  String filename = files_indranil[i].getAbsolutePath();
  //  String[] match_scenario = match(filename, str(scenario));
  //  if (match_scenario != null) {                 // if the filename has the scenario number in it
  //    String[] match_wx = match(filename, "WX");
  //    if (match_wx==null) {                       // check to see if it has "WX" in it
  //      state_indranil = loadTable(filename, "header");
  //    } else {
  //      wx_indranil_table = loadTable(filename);
  //    }
  //  }
  //}
  //// convert Indranil's Wx table
  //wx_indranil = reshape(wx_indranil, wx_indranil_table);


  for (int i=0; i<wx.get(0).getRowCount(); i++) {
    TableRow tablerow = wx.get(0).getRow(i);
    float x = (tablerow.getInt(1)-1)*scalex;
    float y = (tablerow.getInt(0)-1)*scaley;
    Cloud c = new Cloud(x, y, tablerow.getInt(2));
    clouds.add(c);
  }
  for (Cloud c : clouds) {
    c.checkForNeighbors();
  }

  font = createFont("Arial-Black", 25);
  //font = createFont("AppleMyungjo", 18);
  //font = createFont("DevanagariMT-Bold", 25);
  textFont(font, 18);
}






void draw() {
  background(0);
  //index = 0;

  table = wx.get(index);
  //wx_indranil_table = wx_indranil.get(index);
  staterow = state.get(index).getRow(0);
  //row_indranil = state_indranil.getRow(index);

  airplane = new PVector(staterow.getInt("plane_y")-1, staterow.getInt("plane_x")-1);
  //airplane_indranil = new PVector(row_indranil.getInt(1)-1, row_indranil.getInt(2)-1);

  if (index + 1 < wx.size()) { // can we see one step ahead?
    TableRow staterownext = state.get(index+1).getRow(0);
    PVector ednext = new PVector(staterownext.getInt("plane_y")-1, staterownext.getInt("plane_x")-1);   // y and x are reversed for this plane
    float stepsize = ((frameCount-1)%lps)/lps;
    PVector lerped = new PVector(lerp(airplane.x, ednext.x, stepsize), lerp(airplane.y, ednext.y, stepsize));  // lerp the position from the current step to the next one by 1/lps each time
    airplane = lerped;
    if (index + 2 < wx.size()) {   // can we also see two steps ahead?
      //if so, start interpolating with the next-next heading
      String nextHeading = state.get(index+2).getString(0, "Heading");
      plane.update(airplane.x * scalex, airplane.y * scaley, staterownext.getString("Heading"), nextHeading, stepsize);
    } else {    // if only one step ahead, use the next heading as-is.
      String nextHeading = staterow.getString("Heading");
      plane.update(airplane.x * scalex, airplane.y * scaley, nextHeading, nextHeading, stepsize);
    }
  }
  //if (index + 1 < state_indranil.getRowCount()) {
  //  TableRow row_indranil_next = state_indranil.getRow(index + 1);
  //  PVector indnext = new PVector(row_indranil_next.getInt(1)-1, row_indranil_next.getInt(2)-1);
  //  float stepsize = ((frameCount-1)%lps)/lps;
  //  PVector lerped = new PVector(lerp(airplane_indranil.x, indnext.x, stepsize), lerp(airplane_indranil.y, indnext.y, stepsize));
  //  airplane_indranil = lerped;

  //  indranil.update(airplane_indranil.x * scalex, airplane_indranil.y * scaley, row_indranil_next.getString(3));
  //  plane.avoid(indranil, "up");
  //} else {
  //  indranil.update(airplane_indranil.x * scalex, airplane_indranil.y * scaley, row_indranil.getString(3));
  //  plane.avoid(indranil, "up");
  //}

  for (Cloud c : clouds) {    // reset all of the survives values
    c.survives = false;
  }
  for (int i=0; i<table.getRowCount(); i++) {    // go row by row of new data
    TableRow tablerow = table.getRow(i);
    float x = (tablerow.getInt(1)-1)*scalex;
    float y = (tablerow.getInt(0)-1)*scaley;
    float value = tablerow.getInt(2);
    PVector newpos = new PVector(x, y);          // hypothetical cloud position
    boolean exists = false;                      // has this row already matched a cloud?
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
      cloud.survives = true;                    // make sure that the new cloud survives for this iteration.
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
  stroke(150, 255);
  strokeWeight(2);
  noFill();
  //rect(1, 1, width-1, height-1);  // border outline
  translate(scalex/2, scaley/2);  // move by half of one square to center everything

  // grid lines
  strokeWeight(1);
  stroke(150, 50);
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


  shapeMode(CENTER);
  for (Cloud c : clouds) {
    c.show();
  }

  //RUNWAY
  runway(int(airport.x) * scalex, int(airport.y) * scaley);
  //
  //DRAW AIRPLANES
  plane.show(scalex/4, scaley/4);
  //indranil.show(scalex/4, scaley/4);
  //
  popMatrix();

  //if (index + 1 < state_indranil.getRowCount()) {
  if (index + 1 < wx.size()) {
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
  if (index + step < wx.size()) {
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