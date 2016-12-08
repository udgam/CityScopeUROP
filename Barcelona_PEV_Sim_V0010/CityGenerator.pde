class CityGenerator {
  
  int maxBuildingDensity = 25;
  int citySize = 12;
  float roadDensity = 0.4;
  ArrayList<Road> queue = new ArrayList<Road>();
  int[][] matrix = new int[citySize][citySize];
  Roads roads = new Roads();
  ArrayList<Building> buildings = new ArrayList<Building>();
  Utils u = new Utils();
  
  PVector right = new PVector(0, 1);
  PVector left = new PVector(0, -1);
  PVector up = new PVector(-1, 0);
  PVector down = new PVector(1, 0);
  
  float extProbability = 0.7;
  
  ArrayList<Road> generateFirstRoads() {
    ArrayList<Road> result = new ArrayList<Road>();
    Road roadOne = new Road();
    roadOne.direction = down;
    roadOne.roadPts = new PVector[citySize];
    for (int row = 0; row < citySize; row++) {
      matrix[row][0] = -1;
      roadOne.roadPts[row] = new PVector(0, row);
    }
    result.add(roadOne);
    Road roadTwo = new Road();
    roadTwo.direction = down;
    roadTwo.roadPts = new PVector[citySize];
    for (int row = 0; row < citySize; row++) {
      matrix[row][citySize - 1] = -1;
      roadOne.roadPts[row] = new PVector(citySize - 1, row);
    }
    result.add(roadTwo);
    Road roadThree = new Road();
    roadThree.direction = right;
    roadThree.roadPts = new PVector[citySize];
    for (int col = 0; col < citySize; col++) {
      matrix[0][col] = -1;
      roadThree.roadPts[col] = new PVector(col, 0);
    }
    result.add(roadThree);
    Road roadFour = new Road();
    roadFour.direction = right;
    roadFour.roadPts = new PVector[citySize];
    for (int col = 0; col < citySize; col++) {
      matrix[citySize - 1][col] = -1;
      roadFour.roadPts[col] = new PVector(col, citySize - 1);
    }
    result.add(roadFour);
    return result;
  }
  
  Road extendInDirection(PVector direction, PVector startPoint) {
    Road resultRoad = new Road();
    resultRoad.direction = direction;
    int rowStart = int(startPoint.y);
    int colStart = int(startPoint.x);
    ArrayList<PVector> newPoints = new ArrayList<PVector>();
    if (direction == right) {
      for (int col = colStart + 1; col < citySize; col++) {
        if (isValidRoadPoint(rowStart, col, right)) {
          matrix[rowStart][col] = -1;
          newPoints.add(new PVector(col, rowStart));
          if (col != citySize - 1 && matrix[rowStart][col + 1] == -1) {
            break;
          }
        } else {
          break;
        }
      }
    } else if (direction == down) {
      for (int row = rowStart + 1; row < citySize; row++) {
        if (isValidRoadPoint(row, colStart, down)) {
          matrix[row][colStart] = -1;
          newPoints.add(new PVector(colStart, row));
          if (row != citySize - 1 && matrix[row + 1][colStart] == -1) {
            break;
          }
        } else {
          break;
        }
      }
    } else if (direction == left) {
      // Backwards case...
      for (int col = colStart - 1; col >= 0; col--) {
        if (isValidRoadPoint(rowStart, col, left)) {
          matrix[rowStart][col] = -1;
          if (col != 0 && matrix[rowStart][col - 1] == -1)
            break;
        } else break;
      }
      return null;
    } else if (direction == up) {
      // Backwards case...
      for (int row = rowStart - 1; row >= 0; row--) {
        if (isValidRoadPoint(row, colStart, up)) {
          matrix[row][colStart] = -1;
          if (row != 0 && matrix[row - 1][colStart] == -1)
            break;
        } else break;
      }
      return null;
    }
    resultRoad.roadPts = new PVector[newPoints.size()];
    for (int i = 0; i < newPoints.size(); i++) {
      resultRoad.roadPts[i] = newPoints.get(i);
    }
    return resultRoad;
  }
  
  Boolean isValidRoadPoint(int row, int col, PVector direction) {
    if (direction == right || direction == left) {
      // Check the matrix around [row][col] for any illegal...
      try {
        Boolean oneAbove = matrix[row - 1][col] == -1;
        Boolean oneBelow = matrix[row + 1][col] == -1;
        return ! (oneAbove || oneBelow);
      } catch (Exception e) {
        //println(e);
        return true;
      }
    } else if (direction == down || direction == up) {
      // Check the matrix around [row][col] for any illegal...
      try {
        Boolean oneRight = matrix[row][col + 1] == -1;
        Boolean oneLeft = matrix[row][col - 1] == -1;
        return ! (oneRight || oneLeft);
      } catch (Exception e) {
        return true;
      }
    } else return null;
  }
  
  PVector getOppositeDirection(PVector dir) {
  
    if (dir == right) {
      return left;
    } else if (dir == down) {
      return up;
    }
    
    else return null;
  
  }
  
  void extendAllRoads(Roads roads) {
    
    // Goal - extend all roads randomly with extProbability...
    
    for (Road r: roads.roads) {
    
      float rand = random(1);
      
      if (rand <= extProbability) {
      
        // Do extend in opposite direction...
        
        PVector newDir = getOppositeDirection(r.direction);
        
        if (r.roadPts.length > 0 && r.roadPts[0] != null) {
          Road n = extendInDirection(newDir, r.roadPts[0]);
        }
        
      }
    
    }
    
  }
  
  ArrayList<PVector> getRoadStartPoints(Road currentRoad, PVector extensionDirection) {
    ArrayList<PVector> result = new ArrayList<PVector>();
    
    int roadLength = currentRoad.roadPts.length;
    
    int randomCount = int(random(1, roadLength/3));
    
    ArrayList<Integer> distArray = new ArrayList<Integer>();
    
    for (int i = 0; i < randomCount; i++) {
      int randomStart = int(random(1, roadLength/2));
      while (distArray.indexOf(randomStart) > -1)
        randomStart = int(random(1, roadLength/2));
      distArray.add(randomStart);
    }
    
    try {
    
      for (int j = 0; j < randomCount; j++) {
        if (extensionDirection == right) {
          result.add(new PVector(currentRoad.roadPts[0].x, min(currentRoad.roadPts[0].y  + distArray.get(j), citySize - 1)));
        } else if (extensionDirection == down) {
          result.add(new PVector(min(currentRoad.roadPts[0].x  + distArray.get(j), citySize - 1), currentRoad.roadPts[0].y));
        }
      }
    
    } catch (Exception e) {
      //
    }
    
    return result;
  }
  
  CityOutput run() {
    
    ArrayList<Road> firstFour = generateFirstRoads();
    
    for (Road r : firstFour) {
      Road back = getReverse(r);
      roads.roads.add(r);
      roads.roads.add(back);
    }
    
    queue.add(firstFour.get(0));
    
    queue.add(firstFour.get(2));
    
    int roadCount = (int)(roadDensity * pow(citySize, 2));
    
    while (queue.size() > 0 && roads.roads.size() < roadCount) {
      
      // Get the earliest road...
      
      Road current = queue.get(0);
      
      queue.remove(0);
      
      PVector theDir;
      
      if (current.direction == down)
        theDir = right;
      else
        theDir = down;
        
      ArrayList<PVector> startPoints = getRoadStartPoints(current, theDir);
      
      for (PVector start: startPoints) {
        Road newRoad = extendInDirection(theDir, start);
        Road back = getReverse(newRoad);
        roads.roads.add(newRoad);
        roads.roads.add(back);
        queue.add(newRoad);
      }
    }
    
    extendAllRoads(roads);
    
    printMatrix();
    
    Utils u = new Utils();
    
    return u.parseInputMatrix(matrix);
    
  }
  
  Road getReverse(Road road) {
    
    // Return backwards Road
    
    Road result = new Road();
    
    result.roadPts = new PVector[road.roadPts.length];
    
    for (int i = road.roadPts.length - 1; i >= 0; i--) {
      result.roadPts[road.roadPts.length - 1 - i] = road.roadPts[i];
    }
    
    result.direction = road.direction;
    
    return result;
    
  }
  
  void printMatrix() {
    // Assuming square size x size matrix
    print(" \t");
    for (int i = 0; i < citySize; i++) {
      print(i + "\t");
    }
    println();
    for (int i = 0; i < citySize; i++) {
      print(i + "\t");
      for (int j = 0; j < citySize; j++) {
        if (matrix[i][j] == 0)
          print("\t");
        else
          print(matrix[i][j] + "\t");
      }
      println();
    }
  }
  
}