class Probability {
  
  int maximumJobCount = 10;
  
  float[] values;
  
  float maxVal;

  void init(String fileName) {
    String[] rows = loadStrings(fileName);
    values = new float[rows.length];
    for (int i = 0; i < rows.length; i++) {
      values[i] = Float.parseFloat(rows[i])*maximumJobCount/60;
    }
    maxVal = max(values);
  }
  
  float getValue(int time) { // time in seconds
    if (time >= values.length) {
      time -= values.length;
    }
    return values[time]; //<>// //<>// //<>// //<>//
  }
  
  int getJobCount(int time, float simSpeed) {
  
    float rand = random(0, maxVal);
    
    float val = getValue(time);
    
    if (rand <= val) {
      return max(1, Math.round(rand*simSpeed));
    } else return 0;
    
  }

}