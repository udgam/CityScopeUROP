class LogManager {

  PrintWriter writer;
  Boolean doPrint;
  
  void init(Boolean doIt) {
    String month = Integer.toString(month());
    String day = Integer.toString(day());
    String year = Integer.toString(year());
    String hour = Integer.toString(hour());
    String minute = Integer.toString(minute());
    String second = Integer.toString(second());
    
    String fileName = "SimLog_" + month + "-" + day + "-" + year + "_" + hour + ":" + minute + ":" + second;
    
    // Create output file based on simulation start time
    
    writer = createWriter(fileName);
    
    doPrint = doIt;
  }
  
  void logEvent(String input) {
    // Log the given input string to our writer
    writer.println(input);
    if(doPrint)
      println(input);
  }
  
  void close() {
    // Close our log stream for this simulation run.
    
    writer.flush();
    
    writer.close();
  }
  
  void logPEVLocations(ArrayList<PEV> theList, int time) {
    logEvent("\n>>> Logging PEV information for time = " + time + ".\n");
    logEvent("ID\tStatus\t\tX\tY");
    for (PEV p : theList) {
      logEvent(p.id + "\t" + p.action + "\t" + p.locationPt.x + "\t" + p.locationPt.y);
    }
  }
  
  void logMatrix(int[][] matrix, int size) {
    ArrayList<String> l = new ArrayList<String>();
    for (int i = 0; i < size; i++) {
      String current = "";
      for (int j = 0; j < size; j++) {
        current += matrix[i][j] + ",\t";
      }
      l.add(current);
    }
    logEvent("Current city configuration (" + size + " x " + size + ").\n");
    for (String s : l) {
      logEvent(s);
      println(s);
    }
  }
  
}

enum LogStatus {
  
  NoPrint, // 0 - Don't do anything until the end of simulation
  PEVPrint, // 1 - Where are PEV's
  DetailedPrint // 2 - PEV + status, waiting time, etc.
  
}