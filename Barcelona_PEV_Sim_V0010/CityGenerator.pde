class CityGenerator {
  
  int maxBuildingDensity = 25;
  int citySize = 15;
  float roadDensity = 0.4;
  ArrayList<Road> queue = new ArrayList<Road>();
  int[][] matrix = new int[citySize][citySize];
  Roads roads = new Roads();
  ArrayList<Building> buildings = new ArrayList<Building>();
  Utils u = new Utils();
  
  void init() {
  
    // Nothing critical here, yet.
    
  }
  
  CityOutput run() {
    
    // Return a city.
    
    // Step 0 - Init.
    
    // Step 1 - Get random start point in top left.
    int start_x = (int)random(citySize/4);
    int start_y = (int)random(citySize/4);
    
    // Step 2 - Generate road from this start point, with partition and length
    
    int roadLength = (int)random(citySize/2, citySize);
    
    int p = (int)random(roadLength);
    
    Road firstRoad = generateRoad(start_x, start_y, (int)random(2), roadLength, p);
    
    Road firstRoadBack = getReverse(firstRoad);
    
    roads.roads.add(firstRoad);
    roads.roads.add(firstRoadBack);
    
    // Add this first road to queue...
    
    queue.add(firstRoad);
    
    int roadCount = (int)(roadDensity * pow(citySize, 2));
    
    while (queue.size() > 0 && roads.roads.size() < roadCount) {
      
      //println(roads.roads.size());
      
      // Get the earliest road...
      
      Road current = queue.remove(0);
      
      int newDir = 0;
      
      if (current.direction == 0)
        newDir = 1;
      
      // We want to randomly generate roads along the perpendicular direction...
      
      int randomRoadCount = (int)random(1, current.roadPts.length * 0.5);
      
      HashMap<PVector, HashMap<Integer, Integer>> expansions = generateExpansionRoads(randomRoadCount, current);
      
      if (expansions != null) {
      
        for (PVector start : expansions.keySet()) {
          
          int theLength = (int)expansions.get(start).keySet().toArray()[0];
          
          int theP = (int)expansions.get(start).get(theLength);
          
          Road theRoad = generateRoad((int)start.x, (int)start.y, newDir, theLength, theP);
      
          Road roadBack = getReverse(firstRoad);
          
          roads.roads.add(theRoad);
          roads.roads.add(roadBack);
          
          // Add this first road to queue...
          
          queue.add(theRoad);
        }
      
      }
    }
      
    extendDeadEnds(false);
    
    removeAdjacentSegments();
    
    printMatrix();
    
    // Loop needed?
    
    Utils u = new Utils();
    
    return u.parseInputMatrix(matrix);
    
  }
  
  void extendDeadEnds(Boolean doTrim) {
    Utils u = new Utils();
    for (int i = 0; i < citySize; i++) {
      for (int j = 0; j < citySize; j++) {
        if (matrix[i][j] == -1 && u.getAdjacentRoadCells(matrix, i, j).size() == 1 && i != 0 && i != citySize -1 && j != 0 && j != citySize -1) {
          // We have a dead end case...
          // From this point, we want to try to extend to edge...
          
          if (doTrim) {
            matrix[i][j] = 0;
          } else {
            PVector here = new PVector(j, i, 0);
            PVector top = new PVector(j, 0, 0);
            PVector right = new PVector(citySize - 1, i, 0);
            PVector bottom = new PVector(j, citySize - 1, 0);
            PVector left = new PVector(0, i, 0);
            float[] l = new float[4];
            l[0] = PVector.dist(here, top);
            l[1] = PVector.dist(here, right);
            l[2] = PVector.dist(here, bottom);
            l[3] = PVector.dist(here, left);
            Boolean shift = false;
            if (min(l) == PVector.dist(here, top)) {
              // Extend up to top, if possible...
              Boolean passed = false;
              for (int row = i; row >= 0; row--) {
                try {
                  if (matrix[row][j-1] == -1 || matrix[row][j+1] == -1) {
                    if (passed) {
                      shift = true;
                      break;
                    } 
                    else {
                      passed = true;
                    }
                  } else {
                    if (passed)
                      passed = false;
                    matrix[row][j] = -1;
                  }
                } catch(Exception e) {
                  //
                }
                if (shift) {
                  // Go on to next
                }
              }  
            }
            
            if (shift || min(l) == PVector.dist(here, right)) {
              shift = false;
              // Extend over to right, if possible...
              Boolean passed = false;
              for (int col = j; col < citySize; col++) {
                try {
                  if (matrix[i - 1][col] == -1 || matrix[i + 1][col] == -1) {
                    if (passed) {
                      shift = true;
                      break;
                    } 
                    else {
                      passed = true;
                    } 
                  } else {
                    if (passed)
                      passed = false;
                    matrix[i][col] = -1;
                  }
                } catch(Exception e) {
                  //
                }
                if (shift) {
                  // Go on to next
                }
              }  
            }
            
            if (shift || min(l) == PVector.dist(here, bottom)) {
              shift = false;
              // Extend over to right, if possible...
              Boolean passed = false;
              for (int row = i; row < citySize; row++) {
                try {
                  if (matrix[row][j - 1] == -1 || matrix[row][j + 1] == -1) {
                    if (passed) {
                      shift = true;
                      break;
                    } 
                    else {
                      passed = true;
                    } 
                  } else {
                    if (passed)
                      passed = false;
                    matrix[row][j] = -1;
                  }
                } catch(Exception e) {
                  //
                }
                if (shift) {
                  // Go on to next
                }
              }  
            }
            
            if (shift || min(l) == PVector.dist(here, left)) {
              // Extend up to top, if possible...
              Boolean passed = false;
              for (int col = i; col >= 0; col--) {
                try {
                  if (matrix[i - 1][col] == -1 || matrix[i + 1][col] == -1) {
                    if (passed) {
                      shift = true;
                      break;
                    } 
                    else {
                      passed = true;
                    }
                  } else {
                    if (passed)
                      passed = false;
                    matrix[i][col] = -1;
                  }
                } catch(Exception e) {
                  //
                }
                if (shift) {
                  // Go on to next
                }
              }  
            }
          }
        }
      }
    }
  }
  
  void removeAdjacentSegments() {
    
    // Iterate over...
    
    // If surrounded!!! - Remove
    
    for (int i = 0; i < citySize; i++) {
      for (int j = 0; j < citySize; j++) {
        // i = row, j = col
        
        try {
          
          final Boolean a = matrix[i-1][j-1] == -1; // 0
          final Boolean b = matrix[i-1][j] == -1; // 1
          final Boolean c = matrix[i-1][j + 1] == -1; // 2
          final Boolean d = matrix[i][j-1] == -1; // 7
          final Boolean e = matrix[i][j+1] == -1; // 3
          final Boolean f = matrix[i+1][j-1] == -1; // 6
          final Boolean g = matrix[i+1][j] == -1; // 5
          final Boolean h = matrix[i+1][j+1] == -1; // 4
          
          ArrayList<Boolean> l = new ArrayList<Boolean>() {{
              add(a);
              add(b);
              add(c);
              add(d);
              add(e);
              add(f);
              add(g);
              add(h);
          }};
          
          int count = 0;
          
          for (int k = 0; k < l.size(); k++) {
            if (l.get(k))
              count++;
          }
          
          if (count == 4 && (b && e && d && g)) {
            // Good
            // *** ACCOUNT FOR ACTUALLY 4 AROUND!!!
          } else if (count == 3 && ((b && g && d) || (d && b && e) || (b && e && g) || (e && g && d))) {
            // Good
          } else if (count == 2 && ((b && d) || (b && e) || (e && g) || (g && d))) {
            // Good
          } else if (count != 2) {
            matrix[i][j] = 5000;
            println(i, j);
          }
        } catch (Exception e) {
          // Okay.
        }
      }
    }
    
  }
  
  HashMap<PVector, HashMap<Integer, Integer>> generateExpansionRoads(int count, Road road) {
    
    HashMap<PVector, HashMap<Integer, Integer>> map = new HashMap<PVector, HashMap<Integer, Integer>>();
    
    PVector startPoint = road.roadPts[0];
      
    ArrayList<Integer> distArray = new ArrayList<Integer>();
    
    int perpDir = -1;
    int xMul = 0;
    int yMul = 0;
    
    if (road.direction == 0) {
      perpDir = 1;
      yMul = 1;
    } else if (road.direction == 1) {
      perpDir = 0;
      xMul = 1;
    }
      
    for (int i = 0; i < count; i++) {
    
       // Get a random value for start
       
       int dist = (int)random(road.roadPts.length);
       
       while (distArray.indexOf(dist) != -1 || distArray.indexOf(dist - 1) != -1 || distArray.indexOf(dist + 1) != -1) {
         dist = (int)random(road.roadPts.length);
       }
       
       distArray.add(dist);
       
       // Okay, so now we have our distance...
       
       PVector thisStart = new PVector(startPoint.x + xMul * dist, startPoint.y + yMul * dist, 0);
       
       HashMap<Integer, Integer> numMap = getDistancePartitionForStart(thisStart, perpDir);
       
       if (numMap == null) {
         // Skip here..., not a good place to expand...
         return null;
       }
       
       map.put(thisStart, numMap);
    }
    
    return map;
    
  }
  
  int getRealP(int x, int y, int p, int direction) {
    int realP = p;
    int param = -1;
    if (direction == 0)
      param = y;
    else
      param = x;
    if (param - p < 0) {
      realP = param;
    } else if (param + p > citySize - 1) {
      realP = citySize - 1 - param;
    }
    return realP;
  }
  
  HashMap<Integer, Integer> getDistancePartitionForStart(PVector start, int direction) { // direction refers to expansion direction
  
    HashMap<Integer, Integer> theMap = new HashMap<Integer, Integer>();
  
    int row = (int)start.y;
    int col = (int)start.x;
    int roadLength = -1;
    int p = -1;
    
    Boolean isValid = false;
    
    int index = 0;
    
    while (! isValid && index < 15) {
      
      index++;
      
      isValid = true;
      
      roadLength = (int)random(citySize/4, citySize*2/3);
    
      p = (int)random(roadLength);
      
      p = getRealP(col, row, p, direction);
      
      if (direction == 0 && start.y + roadLength > citySize - 1) {
        isValid = false;
      } else if (direction == 1 && start.x + roadLength > citySize - 1) {
        isValid = false;
      } else if (direction == 0) {
        // First, go up...
        
        int j = row;
        
        if (p > 0) {
        
          for (int i = row; i >= row - p; i--) {
            try {
              if (i != row && (matrix[i][col-1] == -1 || matrix[i][col+1] == -1)) {
                isValid = false;
                break;
              }
            } catch (Exception e) {
              // Move on...
            }
          }
          
          j++;
        
        }
        
        // Then, go down...
        
        for (int i = j; i < roadLength; i++) {
            try {
              if (i != j && (matrix[i][col-1] == -1 || matrix[i][col+1] == -1)) {
                isValid = false;
                break;
              }
            } catch (Exception e) {
              // Move on...
            }
        }
        
      } else if (direction == 1) {
        // First, go left...
        
        int j = col;
        
        if (p > 0) {
        
          for (int i = col; i >= col - p; i--) {
            try {
              if (i != col && (matrix[row - 1][i] == -1 || matrix[row + 1][i] == -1)) {
                isValid = false;
                break;
              }
            } catch (Exception e) {
              // Move on...
            }
          }
          
          j++;
        
        }
        
        // Then, go down...
        
        for (int i = j; i < roadLength; i++) {
            try {
              if (i != j && (matrix[row - 1][i] == -1 || matrix[row + 1][i] == -1)) {
                isValid = false;
                break;
              }
            } catch (Exception e) {
              // Move on...
            }
        }
      }
    }
    
    if (index == 15) {
      // Can't find a valid...
      return null;
    }
    
    theMap.put(roadLength, p);
    
    return theMap;
    
  }
  
  Road getReverse(Road road) {
    
    // Return backwards Road
    
    Road result = new Road();
    
    result.roadPts = new PVector[road.roadPts.length];
    
    for (int i = road.roadPts.length - 1; i >= 0; i--) {
      result.roadPts[road.roadPts.length - 1 - i] = road.roadPts[i];
    }
    
    if (road.direction == 0)
      result.direction = 1;
    else
      result.direction = 0;
    
    return result;
    
  }
  
  Road generateRoad(int start_x, int start_y, int direction, int roadLength, int p) { // 0 = up/down, 1 = left/right
    
    // Step 0 - Pick length of road...
    
    // Partition point could be anywhere from 0 to roadLength - 1...
    // We need to ensure that this does not go out of bounds..
    
    int realP = p;
    int param = -1;
    if (direction == 0)
      param = start_y;
    else
      param = start_x;
    if (param - p < 0) {
      realP = param;
    } else if (param + p > citySize - 1) {
      realP = citySize - 1 - param;
    }
    
    /*println("First partition..." + p);
    println("Real partition... " + realP);
    println("Start x = " + start_x);
    println("Start y = " + start_y);
    println("Direction = " + direction);
    println("Length = " + roadLength);*/
    
    // Now, we are good with partition.
    
    p = realP;
    
    // Now, iterate over and set to -1.
    
    ArrayList<Integer> xValues = new ArrayList<Integer>();
    ArrayList<Integer> yValues = new ArrayList<Integer>();
    
    // Relates x (keys) to y (values) ^^^
    
    if (direction == 0) {
      // First, go up...
      
      int j = start_y;
      
      if (p > 0) {
      
        for (int i = start_y; i >= start_y - p; i--) {
          matrix[i][start_x] = -1;
          xValues.add(start_x);
          yValues.add(i);
        }
        
        j++;
      
      }
      
      // Then, go down...
      
      for (int i = j; i < roadLength + start_y; i++) {
        matrix[i][start_x] = -1;
        xValues.add(start_x);
        yValues.add(i);
      }
    } else if (direction == 1) {
      // First, go left...
      
      int j = start_x;
      
      if (p > 0) {
      
        for (int i = start_x; i >= start_x - p; i--) {
          matrix[start_y][i] = -1;
          xValues.add(i);
          yValues.add(start_y);
        }
        
        j++;
      
      }
      
      // Then, go right...
      
      for (int i = j; i < roadLength + start_x; i++) {
        matrix[start_y][i] = -1;
        xValues.add(i);
        yValues.add(start_y);
      }
    }
    
    //println(xValues);
    //println(yValues);
    
    // NOW - Keep track of those points so we can add Roads to our queue!!!
    
    Road road = new Road();
    
    road.roadPts = new PVector[roadLength];
    
    for (int i = 0; i < roadLength; i++) {
      road.roadPts[i] = new PVector(xValues.get(i), yValues.get(i), 0);
    }
    
    road.direction = direction;
    
    return road;
    
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