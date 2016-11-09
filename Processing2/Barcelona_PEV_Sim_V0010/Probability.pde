

class Probability {
  
  float[] values;

  void init(String fileName) {
    String[] rows = loadStrings(fileName);
    values = new float[rows.length];
    for (String s : rows) {
      String[] data = s.split(" ");
      values[Integer.parseInt(data[0]) - 1] = (float) Integer.parseInt(data[1]) / 35000;
    }
  }
  
  float getValue(float time) {
    // Run LERP to get value of function at this timestep in minutes
    try {
      float hourValue = time / 60;
      if (hourValue % 1 == 0) {
        float testValue = values[(int)hourValue];
        return testValue;
      } else if (hourValue > 23) {
        hourValue = hourValue % 24;
      }
      int lower = (int)Math.floor(hourValue - 0.5f); //<>//
      int upper = (int)Math.floor(hourValue + 0.5f);
      if (upper == 24)
        upper = 0; //<>//
      float slope = (values[upper] - values[lower]) / (upper - lower);
      float delta_x = hourValue - lower;
      return values[lower] + delta_x * slope;
    } catch (Exception e) {
      println(e);
      return -1;
    }
  }

}