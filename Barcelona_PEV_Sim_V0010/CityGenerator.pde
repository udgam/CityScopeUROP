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
  
  Road generateFirstRoad() {
    int randomYStart = int(random(0, citySize/5));
    Road resultRoad = new Road();
    resultRoad.roadPts = new PVector[citySize];
    for (int row = 0; row < citySize; row++) {
      matrix[row][randomYStart] = -1;
      resultRoad.roadPts[row] = new PVector(randomYStart, row);
    }
    resultRoad.direction = down;
    return resultRoad;
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
    }
    resultRoad.roadPts = new PVector[newPoints.size()];
    for (int i = 0; i < newPoints.size(); i++) {
      resultRoad.roadPts[i] = newPoints.get(i);
    }
    return resultRoad;
  }
  
  Boolean isValidRoadPoint(int row, int col, PVector direction) {
    if (direction == right) {
      // Check the matrix around [row][col] for any illegal...
      try {
        Boolean oneAbove = matrix[row - 1][col] == -1;
        Boolean oneBelow = matrix[row + 1][col] == -1;
        return ! (oneAbove || oneBelow);
      } catch (Exception e) {
        println(e);
        return true;
      }
    } else if (direction == down) {
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
    
    Road firstRoad = generateFirstRoad();
    
    Road firstRoadBack = getReverse(firstRoad);
    
    roads.roads.add(firstRoad);
    roads.roads.add(firstRoadBack);
    
    // Add this first road to queue...
    
    queue.add(firstRoad);
    
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
    
    printMatrix();
    
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
            matrix[i][j] = 0;
            println(i, j);
          }
        } catch (Exception e) {
          // Okay.
        }
      }
    }
    
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
    
    if (road.direction == down)
      result.direction = right;
    else
      result.direction = down;
    
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