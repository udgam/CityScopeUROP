class CityGenerator {
  
  // Test
  
  int maxPopulation = 1500; // May not be necessary
  int minRoads = 14;
  int maxDensity = 25;
  int citySize = 12;
  
  Boolean noAdjacents(int[] matrix) {
    // Assume matrix is already sorted in ascending order
    for (int i = 0; i < matrix.length - 1; i++) {
      if (matrix[i] + 1 == matrix[i + 1])
        return false;
    }
    return true;
  }
  
  int[] sortArray(int[] array) {
    IntList iList = new IntList(array);
    iList.sort();
    array = new int[array.length];
    for (int i = 0; i < array.length; i++) {
      array[i] = iList.get(i);
    }
    return array;
  }

  CityOutput run() {
    // Goal: Generate a CityOutput that contains proper distribution of roads and buildings...
    int[][] matrix = new int[citySize][citySize];
    // Step 1: Roads
    // A. Start by determining random edge start points...
    int roadsWide = (int)random(citySize/2, citySize);
    int[] xRoads = new int[roadsWide];
    Boolean test = false;
    while (test == false) {
      xRoads = new int[roadsWide];
      for (int i = 0; i < roadsWide; i++) {
        xRoads[i] = (int)random(citySize);
      }
      xRoads = sortArray(xRoads);
      test = noAdjacents(xRoads);
    }
    // Get smallest value we must go down to...
    IntList l = new IntList(xRoads);
    l.sort();
    int minHeight = l.get(0) + 1;
    int roadsTall = (int)random(citySize/2, citySize);
    int[] yRoads = new int[roadsTall];
    Boolean testTwo = false;
    while (testTwo == false) {
      yRoads = new int[roadsTall];
      for (int i = 0; i < roadsTall; i++) {
        yRoads[i] = (int)random(citySize);
      }
      yRoads = sortArray(yRoads);
      testTwo = noAdjacents(yRoads);
    }
    for (int i = 0; i < roadsWide; i++) {
      // Generate a road that starts at 0 and extends right certain distance
      int roadLength = (int)random(2, citySize);
      int colPos = xRoads[i];
      for (int j = 0; j < roadLength; j++) {
        matrix[colPos][j] = -1;
      }
    }
    for (int i = 0; i < roadsTall; i++) {
      // Generate a road that starts at 0 and extends down certain distance
      int roadLength = (int)random(minHeight, citySize);
      int rowPos = yRoads[i];
      for (int j = 0; j < roadLength; j++) {
        matrix[j][rowPos] = -1;
      }
    }
    // Step 2: Buildings
    for (int i = 0; i < citySize; i++) {
      for (int j = 0; j < citySize; j++) {
        if (matrix[i][j] == 0) {
          int randomDensity = (int)random(maxDensity);
          matrix[i][j] = randomDensity;
          //matrix[i][j] = 0;
        }
      }
    }
    Utils u = new Utils();
    CityOutput city = u.parseInputMatrix(matrix);
    if (city == null) {
      return run();
    } else if (city.roads.roads.size() < minRoads) {
      return run();
    } else {
      printMatrix(city.matrix, citySize);
      return city;
    }
  }
  
  void printMatrix(int[][] matrix, int size) {
    // Assuming square size x size matrix
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        print(matrix[i][j] + "\t");
      }
      println();
    }
  }
  
}