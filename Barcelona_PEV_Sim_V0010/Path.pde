// Barcelona PEV Simulation v0010
// for MIT Media Lab, Changing Place Group, CityScope Project

// by Udgam Goyal <udgam@mit.edu>
// Feb.8th.2015

class Path {
  ArrayList <Road> Roads;
  String roadPtFile;
  ArrayList <Node> pathOfNodes;
  boolean pathPresent = false;
  float roadConnectionTolerance = 1.0; //.75 originally
  int infinity = 999999999;
  boolean drawn = false;
  int destinationID = 99999999;
  int beginningID;
  int endID;

  Path(Nodes nodes) {
    pathOfNodes = new ArrayList <Node>();
    beginningID = 100000000;
    endID = 1000000000;
  }

  // Successors function
  ArrayList <Node> successors(Node parent, Nodes nodes) {
    ArrayList<Node> successorNodes = new ArrayList <Node>();
    for (Node child : nodes.allNodes) {
      if (PVector.dist(parent.point, child.point) <= roadConnectionTolerance) {
        successorNodes.add(child);
      }
    }
    return successorNodes;
  }


  // Path Algorithm

  int[] findPath(PVector startPt, PVector goalPt, Nodes nodes) {
    //int successorCount = 0;
    //int whileCount = 0;

    // Creation of parent array
    int [] parentArray = new int[nodes.allNodes.size()+1];
    for (Node node : nodes.allNodes) {
      parentArray[node.id] = infinity;
    }

    ArrayList <Node> agenda = new ArrayList<Node>();
    ArrayList <Node> specificSuccessorNodes = new ArrayList <Node>();
    Node beginning = null;
    Node end = null;
    // Finding the beginning node id
    //println ("START PT IS " +startPt);
    //println("END PT IS" + goalPt);
    for (Node node : nodes.allNodes) {
      if (node.point.x == startPt.x && node.point.y == startPt.y) {
        beginning = node;
        beginningID = node.id;
      }
    
      if (node.point.x == goalPt.x && node.point.y == startPt.y) {
        end = node;
        endID = node.id;
      }
    }
    //println("END");

    PVector destinationPt = goalPt;
    Node parent = null;
    if (beginning == null) {
      println("Beginning node"+ startPt +" not found in all nodes");
      return null;
    } else {
      agenda.add(beginning);
      while (agenda.size() > 0) {
        parent = agenda.get(0);
        agenda.remove(0);
        specificSuccessorNodes = successors(parent, nodes);
        //println(specificSuccessorNodes);
        //println(nodes.allNodes);

        //parent[child.id] = parent.id
        //parent of a child = parent

        for (Node next : specificSuccessorNodes ) {
          if (next.point.x == destinationPt.x && next.point.y == destinationPt.y) {
            //println("Path found");
            pathPresent = true;
            parentArray[next.id] = parent.id;
            //println(parent.id);
            destinationID = next.id;
            //println(parentArray[next.id]);
            return parentArray;
          } else if (parentArray[next.id] == infinity) {
            agenda.add(next);
            parentArray[next.id] = parent.id;
          }
        }
      }
      println("No path found");
      println(startPt + " " + destinationPt);
      return null;
    }
  }
  //Actually returning path (ArrayList of PVectors)
  ArrayList <Node> pathFromParentArray(int [] parentArray, PVector startPt, PVector goalPt) {
    ArrayList<Node> finalPath = new ArrayList <Node>();
    PVector destinationPt = goalPt;
    Node current = null;
    Node beginning = null;
    Node destination = null;
    // Finding the final node id
    for (Node node : nodes.allNodes) {
      if (node.id == destinationID) {
        current = node;
        destination = node;
      }
      if (node.point.x == startPt.x && node.point.y == startPt.y) {
        beginning = node;
        node.activity += 1;
      }
    }
    
    // UDGAM - Look at parentArray = null case
    
    finalPath.add(beginning);
    if (current == null || beginning == null) {
      return null;
    } else {
      //println("Parent Array: " + parentArray);
      while (parentArray[current.id] != beginningID) {
        int parentid = parentArray[current.id];
        //println(parentid);
        current = nodes.allNodes.get(parentid);
        nodes.allNodes.get(parentid).activity += 1;
        finalPath.add(current);
      }
      //println(finalPath);
      ArrayList <Node> inOrderPath = new ArrayList<Node>();
      
      for (int i = finalPath.size()-1; i >= 0; i -= 1) {
        inOrderPath.add(finalPath.get(i));
      }
      inOrderPath.remove(inOrderPath.size()-1);
      if (destination != null){
        inOrderPath.add(destination);
      }
      pathOfNodes = inOrderPath;
      for (Node node: pathOfNodes){
        //print(node.point+ " ");
      }
      return pathOfNodes;
    }
  }

  void drawAllPaths() {
    stroke(255, 0, 0); //cyan
    strokeWeight(1.0);
    for (int i = 0; i<=nodes.allNodes.size()-2; i++) {
      line(nodes.allNodes.get(i).point.x*constantFactor+starting, nodes.allNodes.get(i).point.y*constantFactor+starting, nodes.allNodes.get(i+1).point.x*constantFactor+starting, nodes.allNodes.get(i+1).point.y*constantFactor+starting);
    }
  }

  void drawPath(ArrayList<Node> path) {
    stroke(0, 255, 0);
    strokeWeight(1.0);
    int total = path.size();
    for (int i = 0; i<= total-3; i++) {
      line(path.get(i).point.x*constantFactor+starting, path.get(i).point.y*constantFactor+starting, path.get(i+1).point.x*constantFactor+starting, path.get(i+1).point.y*constantFactor+starting);
    }
  }

  void drawPath2(ArrayList <PVector> path) {
    stroke(0, 255, 0);
    fill(0, 255, 0);
    for (PVector p : path) {
      ellipse(p.x, p.y, 10, 10);
    }
  }
  
  PVector getTangentVector(int _n) {
    int n = _n;
    int l = pathOfNodes.size();
    if ( n < 0 || n >= l ) {
      println("\"n\" out of range!");
      return null;
    } else if (n == l - 1) {
      if (n>=1){
      PVector v1 = pathOfNodes.get(n-1).point;
      PVector v2 = pathOfNodes.get(n).point;
      PVector v3 = PVector.sub(v2, v1);
      v3.normalize();
      return  v3;}
      else{PVector v1 = pathOfNodes.get(n).point;
      PVector v2 = pathOfNodes.get(n).point;
      PVector v3 = PVector.sub(v2, v1);
      v3.normalize();
      return  v3;
  }
      
    } else {
      PVector v1 = pathOfNodes.get(n).point;
      PVector v2 = pathOfNodes.get(n+1).point;
      PVector v3 = PVector.sub(v2, v1);
      v3.normalize();
      return  v3;
    }
  }

}