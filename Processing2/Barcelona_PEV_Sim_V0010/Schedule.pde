// Barcelona PEV Simulation v0010
// for MIT Media Lab, Changing Place Group, CityScope Project

// by Udgam Goyal <udgam@mit.edu>
// Feb.8th.2015

class Schedule {
  String data;
  String [] allLines;
  int [] times = null;
  float [] pickupX;
  float [] pickupY;
  float [] dropoffX;
  float [] dropoffY;
  Schedule(String d) {
    addJobs(d);
  }
  
  void addJobs(String _data) {
    String [] job = null;
    data = _data;
    allLines = loadStrings(data);
    int totalLines = allLines.length;
    times = new int[totalLines];
    pickupX = new float[totalLines];
    pickupY = new float[totalLines];
    dropoffX = new float[totalLines];
    dropoffY = new float[totalLines];
    for (int i = 1; i <= totalLines-1; i++){
      job = split(allLines[i], ",");
      times[i] = int(job[0]);
      pickupX[i] = float(job[1]);
      pickupY[i] = float(job[2]);
      dropoffX[i] = float(job[3]);
      dropoffY[i] = float(job[4]);
    }
  }
}