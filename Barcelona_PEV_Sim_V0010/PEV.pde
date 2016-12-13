// Andorra PEV Simulation v0010
// for MIT Media Lab, Changing Place Group, CityScope Project

// by Yan Zhang (Ryan) <ryanz@mit.edu>
// Dec.8th.2015


float maxSpeedKPH = 200.0; //units: kph  20.0 kph
float maxSpeedMPS = maxSpeedKPH * 1000.0 / 60.0 / 60.0; //20.0 KPH = 5.55556 MPS
float maxSpeedPPS = maxSpeedMPS / scaleMeterPerPixel; 
float roadConnectionTolerance = 1.5; //pxl; smaller than 1.0 will cause error
float stateChangeOdd = 0.0075;

class PEV {

  int id; //PEV agent id
  int status; 
  String action = "wandering";
  //int roadID; //the road the PEV is currently on
  Road road; //current road object
  float t; //t location of the current road;
  PVector locationPt; //location coordination on the canvas, LOCATES PEV
  PVector locationTangent;
  float rotation; //rotation in radius on the canvas
  float speedT; //current speed; units: t per frame
  PImage img_PEV;
  Path inRoutePath;
  Path deliveringPath;
  float speedIRP = 0.0;
  float speedDP = 0.0;
  int inRoutePathCount = 0;
  int deliveringPathCount = 0;
  Nodes nodes2 = new Nodes();
  boolean drawn = true;
  int inRouteTime = 0;
  int deliveryTime = 0;

  PEV(Road _road, float _t, int _id) {
    id = _id;
    //roadID = _roadID;
    //road = roads.roads.get(roadID);
    road = _road;
    t = _t; //location within road; will be important for distance between location and PEV
    status = 0;
    locationPt = road.getPt(t);
    speedT = maxSpeedMPS / road.roadLengthMeter / frameRate; //speedT unit: t per frame
    img_PEV = imgs_PEV.get(0);
    inRoutePath = new Path(nodes2);
    deliveringPath = new Path(nodes2);
  }

  void run(int time) {
    //if (inRoutePath == null && deliveringPath == null) {
    move();
    //} else if (inRoutePath != null) {
    //  move2();
    //} else {
    //  move3();
    //}
    if (action == "wandering") {
      getRotation();
    } else if (action == "inRoute") {
      getRotation2();
    } else if (action == "delivering") {
      getRotation3();
    }

    //changeState();

    render();
  }

  void move() {
    //println(speedT);
    if (action == "delivering") {
      if (deliveringPathCount<deliveringPath.pathOfNodes.size()-1) {
        makeFull();
        action = "delivering";
        locationPt = deliveringPath.pathOfNodes.get(int(deliveringPathCount)).point;
        if (nodes.allNodes.size() > 0){
          nodes.allNodes.get(deliveringPath.pathOfNodes.get(int(deliveringPathCount)).id).activity += 1;
        }
        deliveringPathCount += 1;
      } else {
        action = "wandering";
        makeEmpty();
        PVector end = deliveringPath.pathOfNodes.get(int(deliveringPathCount)).point;
        deliveringPathCount = 0;
        deliveringPath.pathOfNodes = null;
        for (Road road2 : roads.roads) {
          for (PVector roadPt : road2.roadPts) {
            int count = 0;
            if (roadPt == end) {
              road = road2;
              t = count/road.roadPts.length;
            }
            count += 1;
          }
        }

        //for (Spot spot : Spots.Spots) {
        //  int c = 0;
        //  if (spot.locationPt == end || spot.locationPt == deliveringPath.pathOfNodes.get(0)) {
        //    Spots.Spots.remove(c);
        //  }
        //  c ++;
        //}
      }
    } else if (action == "inRoute") {
      if (inRoutePathCount<inRoutePath.pathOfNodes.size()-1) {
        action = "inRoute";
        locationPt = inRoutePath.pathOfNodes.get(int(inRoutePathCount)).point;
        if (nodes.allNodes.size() > 0 ){
          nodes.allNodes.get(inRoutePath.pathOfNodes.get(int(inRoutePathCount)).id).activity += 1;
        }
        inRoutePathCount+=1;
      } else {
        action = "delivering";
        deliveryTime = time;
        inRoutePathCount = 0;
        inRoutePath.pathOfNodes = null;
      }
    } else if (action == "wandering") {
      // update the speed according to frameRate
      speedT = maxSpeedMPS / road.roadLengthMeter / frameRate; //speedT unit: t per frame

      // calc the next step
      t = t + 1.0/road.roadPts.length;
      
      //println("Length = " + road.roadPts.length);
      
      //println(road.roadPts);
      
      //println("T = " + t);

      // if at end of road
      if (t > 1.0) {
        //println("Reached end of road!!!!!!!!!!!!!!!!!!!!");
        //println(locationPt);
        //println(road.roadPts);
        // simple test on one road
        //1 = -speedT;

        // looking for all next road connected
        ArrayList<Road> nextRoads = new ArrayList<Road>();
        PVector roadEndPt = road.roadPts[road.ptNum-1];
        PVector roadStartPt = road.roadPts[0];
        //int i = 0;
        for (Road tmpRoad : roads.roads) {
          //for (PVector roadPt: tmpRoad.roadPts) {
          //  // Check if == start or end...
          //  if (roadPt.x == roadEndPt.x && roadPt.y == roadEndPt.y) {
          //    nextRoads.add(tmpRoad);
          //  }
          //}
          PVector tmpRoadStartPt = tmpRoad.roadPts[0];
          PVector tmpRoadEndPt = tmpRoad.roadPts[tmpRoad.ptNum-1];
          //println(tmpRoad.roadPts);
          //println("tmpRoad ["+i+"]: ");
          //println("PVector.dist(roadEndPt, tmpRoadStartPt) = "+PVector.dist(roadEndPt, tmpRoadStartPt));
          //println("PVector.dist(roadStartPt, tmpRoadEndPt) = "+PVector.dist(roadStartPt, tmpRoadEndPt));
          //println("Distance to temp road start point " + tmpRoadStartPt + " from road end point " + roadEndPt + " is " + PVector.dist(roadEndPt, tmpRoadStartPt) + ".");
          //println("Current location = " + locationPt);
          if (PVector.dist(roadEndPt, tmpRoadStartPt) <= roadConnectionTolerance && tmpRoad != road) {
            //println("pass if 01");
            //println("Here!!!");
            //println("Distance to temp road end point " + tmpRoadEndPt + " from road start point " + roadStartPt + " is " + PVector.dist(roadStartPt, tmpRoadEndPt) + ".");
            
            //println("Found next road.");
            nextRoads.add(tmpRoad);
            
            if (PVector.dist(roadStartPt, tmpRoadEndPt) > roadConnectionTolerance) {
              //println("pass if 02");
              
            }
          }
          //i ++;
        }
        //println("find: "+nextRoads.size());
        // pick one next road
        if (nextRoads.size() <= 0) {
          println("ERROR: CAN NOT FIND NEXT ROAD!" + 
            "THERE MUST BE DEADEND ROAD! CHECK ROAD RHINO FILE OR ROAD PT DATA TXT");
        }
        int n = int(random(0, nextRoads.size()-1)+0.5); //int(0.7) = 0, so need +0.5
        //println("n = "+n+"; nextRoads.size()-1 = "+str(nextRoads.size()-1)
        //  +"; random(0, nextRoads.size()-1) = "+str(random(0, nextRoads.size()-1)));
        //println("t = "+t);
        Road nextRoad = nextRoads.get(n);

        // switch current road to next road
        road = nextRoad; 
        t = 0.0;
      }
    }
  }

  void getRotation() {
    // get rotation
    locationPt = road.getPt(t);
    locationTangent = road.getTangentVector(t);
    rotation = PVector.angleBetween(new PVector(1.0, 0.0, 0.0), locationTangent);
    if (locationTangent.y < 0) {
      rotation = -rotation;
    }
  }

  //When PEV is in Route to pickup
  
  void getRotation2() {
    // get rotation
    locationTangent = inRoutePath.getTangentVector(int(inRoutePathCount));
    rotation = PVector.angleBetween(new PVector(1.0, 0.0, 0.0), locationTangent);
    if (locationTangent.y < 0) {
      rotation = -rotation;
    }
  }

  //When PEV is delivering
  void getRotation3() {
    // get rotation
    locationTangent = deliveringPath.getTangentVector(int(deliveringPathCount));
    rotation = PVector.angleBetween(new PVector(1.0, 0.0, 0.0), locationTangent);
    if (locationTangent.y < 0) {
      rotation = -rotation;
    }
  }

  void changeState() {
    float rnd = random(0.0, 1.0);
    if (rnd <= stateChangeOdd) {
      int n = int(random(0, imgs_PEV.size()-1)+0.5);
      img_PEV = imgs_PEV.get(n);
    }
  }

  void render() {
    if (drawn){
    pushMatrix();
    translate(locationPt.x*constantFactor+starting, locationPt.y*constantFactor+starting);
    rotate(rotation);

    //// draw direction line
    //stroke(0, 255, 0); 
    //strokeWeight(0.5); 
    //line(0.0, 0.0, 25.0, 0.0);

    // draw PEV img
    scale(0.3);
    translate(-img_PEV.width/2, -img_PEV.height/2);
    image(img_PEV, 0, 0);
    popMatrix();
    }
  }

  void makeFull() {
    img_PEV = imgs_PEV.get(1);
  }

  void makeEmpty() {
    img_PEV = imgs_PEV.get(0);
  }
}