// Barcelona PEV Simulation v0010
// for MIT Media Lab, Changing Place Group, CityScope Project

// by Kevin Lyons <kalyons@mit.edu>
// Oct.21st.2016

public class Utils {
  
  String[] directionArray = new String[4];
  int maxDensity = 25;
  
  // Need a method to take in matrix and output Roads and Buildings
  
  void loadDirectionArray() {
    directionArray[0] = "-1,0";
    directionArray[1] = "0,1";
    directionArray[2] = "1,0";
    directionArray[3] = "0,-1";
  }
  
  CityOutput parseInputMatrix(int[][] matrix) {
    loadDirectionArray();
    int[][] og = matrix;
    int matrixHeight = matrix.length;
    int [] sample = matrix[0];
    int matrixWidth = sample.length;
    ArrayList<Building> buildings = new ArrayList<Building>(); // Change to "Buildings" class...
    int[][][] roadMatrix = new int[matrixHeight][matrixWidth][4];
    ArrayList<ArrayList<Node>> roadLists = new ArrayList<ArrayList<Node>>();
    for (int row = 0; row < matrixHeight; row++) {
      for (int column = 0; column < matrixWidth; column++) {
        int cell = matrix[row][column];
        if (cell != -1) {
          Building b = constructBuilding(cell, column, row);
          buildings.add(b);
        } else if (roadMatrix[row][column][0] == 0 && roadMatrix[row][column][1] == 0 && roadMatrix[row][column][2] == 0 && roadMatrix[row][column][3] == 0) {
          // We have a Road cell. We must determine where this should go and construct Roads accordingly.
          ArrayList<Integer> directions = getAdjacentRoadCells(matrix, row, column);
          for (int i = 0; i < directions.size(); i++) {
            int dir = directions.get(i);
            // Expand along this direction and its negative, if it exists...create Nodes along the way?
            ArrayList<Node> nodes = getRoadNodesAlongDirection(dir, row, column, matrix, roadMatrix);
            int newDir = -1;
            if (dir == 0)
              newDir = 2;
            else if (dir == 1)
              newDir = 3;
            if (newDir != -1) {
              directions.remove(Integer.valueOf(newDir));
              ArrayList<Node> otherNodes = getRoadNodesAlongDirection(newDir, row, column, matrix, roadMatrix);
              nodes = removeDuplicates(combineLists(nodes, otherNodes));
            }
            roadLists.add(nodes);
          }
        }
      }
    }
    writeRoadsToLocalFile(roadLists);
    Roads roads = new Roads();
    roads.addRoadsByRoadPtFile("roads.txt");
    roads = removeIsolatedRoads(roads, matrix, matrixWidth, matrixHeight);
    return formMatrix(roads, buildings, matrixWidth, matrixHeight);
  }
  
  CityOutput formMatrix(Roads roads, ArrayList<Building> buildings, int w, int h) {
    int[][] matrix = new int[h][w];
    CityOutput city;
    for (Road r : roads.roads) {
      for (PVector p : r.roadPts) {
        matrix[(int)p.y][(int)p.x] = -1;
      }
    }
    for (int i = 0; i < h; i++) {
      for (int j = 0; j < w; j++) {
        if (matrix[i][j] == 0) {
          // Need to add a building here.
          int randomDensity = (int)random(maxDensity);
          Building b = constructBuilding(randomDensity, j, i);
          buildings.add(b);
          matrix[i][j] = randomDensity;
        }
      }
    }
    city = new CityOutput(roads, buildings, true, matrix);
    return city;
  }
  
  Roads removeDeadEnds(Roads roads, int[][] matrix, int w, int h) {
    // Assume that we have already run removeIsolatedRoads...
    // Seeking road where one endpoint shares no others
    Roads res = new Roads();
    for (Road road: roads.roads) {
      PVector startPoint = road.roadPts[0];
      int x1 = (int)startPoint.x, y1 = (int)startPoint.y;
      ArrayList<Integer> adjacentStart = getAdjacentRoadCells(matrix, y1, x1);
      PVector endPoint = road.roadPts[road.roadPts.length - 1];
      int x2 = (int)endPoint.x, y2 = (int)endPoint.y;
      ArrayList<Integer> adjacentEnd = getAdjacentRoadCells(matrix, y2, x2);
      Boolean goodRoad = false;
      for (int i = 1; i < road.roadPts.length - 1; i++) {
        PVector point = road.roadPts[i];
        int x = (int)point.x, y = (int)point.y;
        ArrayList<Integer> adjacent = getAdjacentRoadCells(matrix, y, x);
        if (adjacent.size() > 2 && x != x1 && x != x2 && y != y1 && y != y2) {
          goodRoad = true;
          res.roads.add(road);
          break;
        }
      }
      if (goodRoad == false) {
        if ((adjacentStart.size() == 2 && adjacentEnd.size() == 1) || (adjacentStart.size() == 1 && adjacentEnd.size() == 2))
          goodRoad = false;
        else
          goodRoad = true;
      }
      if (! goodRoad) {
        // Connect locally, by row or column
        for (PVector p : road.roadPts) {
          Road newRoad = roads.findRoadWithLocation(startPoint);
          //println(newRoad.roadPts);
        }
      } else {
        res.roads.add(road);
      }
    }
    return res;
  }
  
  Roads removeIsolatedRoads(Roads roads, int[][] matrix, int w, int h) {
    Roads res = new Roads();
    for (Road road: roads.roads) {
      if (road.roadPts.length > 1) {
        PVector startPoint = road.roadPts[0];
        int x1 = (int)startPoint.x, y1 = (int)startPoint.y;
        ArrayList<Integer> adjacentStart = getAdjacentRoadCells(matrix, y1, x1);
        PVector endPoint = road.roadPts[road.roadPts.length - 1];
        int x2 = (int)endPoint.x, y2 = (int)endPoint.y;
        ArrayList<Integer> adjacentEnd = getAdjacentRoadCells(matrix, y2, x2);
        Boolean fullRoad = (x1 == 0 && x2 == w - 1) || (x2 == 0 && x1 == w - 1) || (y1 == 0 && y2 == h - 1) || (y2 == 0 && y1 == h - 1);
        if (fullRoad || (adjacentStart.size() > 1 || adjacentEnd.size() > 1))
          res.roads.add(road);
        else {
          // Need to check that each other node only has 2 adjacent nodes...
          Boolean goodRoad = false;
          for (int i = 1; i < road.roadPts.length - 1; i++) {
            PVector point = road.roadPts[i];
            int x = (int)point.x, y = (int)point.y;
            ArrayList<Integer> adjacent = getAdjacentRoadCells(matrix, y, x);
            if (adjacent.size() > 2) {
              goodRoad = true;
              res.roads.add(road);
              break;
            }
          }
          if (! goodRoad) {
            /*println("Invalid road detected.");
            println("x1 = " + x1 + ", y1 = " + y1 + ", x2 = " + x2 + ", y2 = " + y2);
            println("startList = " + adjacentStart);
            println("endList = " + adjacentEnd);*/
          }
        }
      }
    }
    return res;
  }
  
  // Temporary solution as we must currently input roads with this specific text file format.
  
  // Refactor - create method to directly convert between node lists and corresponding roads... [KEVIN]
  
  void writeRoadsToLocalFile(ArrayList<ArrayList<Node>> allRoads) {
    PrintWriter output = createWriter("roads.txt");
    for (ArrayList<Node> road: allRoads) {
      output.println("start");
      output.println("one way");
      for (Node n : road)
        output.println(n.point.x + ", " + n.point.y + ", " + n.point.z);
      output.println("end");
      output.println("start");
      output.println("one way");
      road = reverseList(road);
      for (Node n : road)
        output.println(n.point.x + ", " + n.point.y + ", " + n.point.z);
      output.println("end");
    }
    output.flush();
    output.close();
  }
  
  ArrayList removeDuplicates(ArrayList<Node> list) {
    for (int i = 0; i < list.size() - 1; i++) {
      for (int j = i + 1; j < list.size(); j++) {
        if (list.get(i).point.x == list.get(j).point.x && list.get(i).point.y == list.get(j).point.y)
          list.remove(j);
      }
    }
    return list;
  }
  
  ArrayList combineLists(ArrayList one, ArrayList two) {
    ArrayList res = new ArrayList();
    for (Object o : one)
      res.add(o);
    for (Object n : two)
      res.add(n);
    return res;
  }
  
  ArrayList reverseList(ArrayList input) {
    ArrayList newList = new ArrayList();
    for (int i = input.size() - 1; i >= 0; i--)
      newList.add(input.get(i));
    return newList;
  }
  
  Building constructBuilding(float density, float x, float y) {
    return new Building(density, x, y);
  }
  
  ArrayList<Integer> getAdjacentRoadCells(int[][] matrix, int row, int column) {
    ArrayList<Integer> returnArray = new ArrayList<Integer>();
    try {
      if (matrix[row - 1][column] == -1)
        returnArray.add(0);
    } catch (Exception e) {
    }
    try {
      if (matrix[row][column + 1] == -1)
        returnArray.add(1);
    } catch (Exception e) {
    }
    try {
      if (matrix[row + 1][column] == -1)
        returnArray.add(2);
    } catch (Exception e) {
    }
    try {
      if (matrix[row][column - 1] == -1)
        returnArray.add(3);
    } catch (Exception e) {
    }
    return returnArray;
  }
  
  ArrayList<Node> getRoadNodesAlongDirection(int dir, int row, int column, int[][] inputMatrix, int[][][] roadMatrix) {
    String moveString = directionArray[dir];
    String[] split = moveString.split(",");
    int rowIncrement = Integer.parseInt(split[0]);
    int colIncrement = Integer.parseInt(split[1]);
    int r = row, c = column;
    int matrixHeight = inputMatrix.length; //<>// //<>// //<>// //<>// //<>// //<>//
    int [] sample = inputMatrix[0]; //<>// //<>// //<>// //<>// //<>// //<>//
    int matrixWidth = sample.length;
    ArrayList<Node> list = new ArrayList<Node>();
    Node first = constructNode(column, row);
    list.add(first);
    r += rowIncrement;
    c += colIncrement;
    while (r >= 0 && r < matrixHeight && c >= 0 && c < matrixWidth) {
      if (inputMatrix[r][c] == -1 && roadMatrix[r][c][dir] != 1) { //<>// //<>// //<>// //<>// //<>// //<>//
        roadMatrix[r][c][dir] = 1;
        Node thisNode = constructNode(c, r);
        list.add(thisNode);
        r += rowIncrement;
        c += colIncrement;
      } else
        break;
    }
    if (dir == 1 || dir == 7)
      return reverseList(list);
    else
      return list;
  }
  
  Node constructNode(int x, int y) {
    return new Node(new PVector(x, y, 0));
  }
  
  int[][] fillMatrix(String fileName) {
    String[] rows = loadStrings(fileName);
    // Check length of integers. Assume good validation.
    int matrixHeight = rows.length;
    String[] firstRow = rows[0].split(",");
    int matrixWidth = firstRow.length;
    int[][] returnMatrix = new int[matrixHeight][matrixWidth];
    for (int row = 0; row < matrixHeight; row++) {
      String[] thisRow = rows[row].split(",");
      for (int col = 0; col < matrixWidth; col++) {
        returnMatrix[row][col] = Integer.parseInt(thisRow[col].trim());
      }
    }
    return returnMatrix;
  }
}

class CityOutput {
  
  Roads roads;
  ArrayList<Building> buildings;
  Boolean isValid;
  int[][] matrix;
  
  CityOutput(Roads roadsIn, ArrayList<Building> buildingsIn, Boolean validIn, int[][] matrixIn) {
    roads = roadsIn;
    buildings = buildingsIn;
    isValid = validIn;
    matrix = matrixIn;
  }
  
}