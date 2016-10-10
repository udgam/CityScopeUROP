// Barcelona PEV Simulation v0010
// for MIT Media Lab, Changing Place Group, CityScope Project

// by Udgam Goyal <udgam@mit.edu>
// Feb.8th.2015

class Nodes {
  ArrayList <Node> allNodes;
  ArrayList <ArrayList<Node>> successorNodes;
  
  Nodes() {
    allNodes = new ArrayList <Node>();
    successorNodes = new ArrayList<ArrayList<Node>>();
  }
  void addNodesToAllNodes(Roads roads1) {
    int count = 0;
    Node last = null;
    for (Road road : roads1.roads) {
      for (float t = 0.0; t<=1.0; t+=(1.0/road.roadPts.length)) {
        //Making each road a two-way road, this method accounts for both directions
        Node node1 = new Node(road.getPt(t), count, road);
        allNodes.add(node1);
        count +=1;
        //last = node1;
        
        
        
      }
    }
  }
}