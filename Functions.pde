ArrayList<Table> reshape(ArrayList<Table> list, Table table) {
  for (int i=0; i<table.getRowCount(); i++) {
    TableRow row =  table.getRow(i);
    Table temp = new Table();
    temp.addColumn("CloudX");
    temp.addColumn("CloudY");
    temp.addColumn("value");
    for (int j=1; j<table.getColumnCount(); j++) {
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
    list.add(temp);
  }
  return list;
}



// adjust functions slight alter the value of the x/y used to draw the overall path.
float adjustx(float x, String h) {
  if (h.equals("E")) {
    x += 0.3;
  }
  if (h.equals("W")) {
    x += -0.3;
  }
  return x;
}
float adjusty(float y, String h) {
  if (h.equals("S")) {
    y += 0.3;
  }
  if (h.equals("N")) {
    y += -0.3;
  }
  return y;
}



float round(float number, float decimal) {
    return (float)(round((number*pow(10, decimal))))/pow(10, decimal);
} 