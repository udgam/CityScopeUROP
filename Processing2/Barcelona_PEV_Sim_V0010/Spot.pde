// Barcelona PEV Simulation v0010
// for MIT Media Lab, Changing Place Group, CityScope Project

// by Udgam Goyal <udgam@mit.edu>
// Feb.8th.2015
class Spot {

  //int id; //PEV agent id
  int status; //0 = Pick Up, 1 = Destination
  //int roadID; //the road the PEV is currently on
  Road road; //current road object
  float t; //t location of the current road;
  PVector locationPt; //location coordination on the canvas
  PVector locationTangent;
  float speedT; //current speed; units: t per frame
  boolean drawn;

  Spot(Road _road, float _t) {
    //id = _id;
    //roadID = _roadID;
    //road = roads.roads.get(roadID);
    road = _road;
    t = _t;
    status = int(random(0, 2));
    locationPt = road.getPt(t);
    speedT = 0; //speedT unit: t per frame
    drawn = true;
  }
  void run() {

    //move();

    getRotation();

    render();
  }

  void move() {
    // update the speed according to frameRate
    speedT = maxSpeedMPS / road.roadLengthMeter / frameRate; //speedT unit: t per frame

    // calc the next step
    t +=1;

    // if at end of road
    if (t + 1 > 1.0) {
      // simple test on one road
      //speedT = -speedT;

      // looking for all next road connected
      ArrayList<Road> nextRoads = new ArrayList<Road>();
      PVector roadEndPt = road.roadPts[road.ptNum-1];
      PVector roadStartPt = road.roadPts[0];
      //int i = 0;
      for (Road tmpRoad : roads.roads) {
        PVector tmpRoadStartPt = tmpRoad.roadPts[0];
        PVector tmpRoadEndPt = tmpRoad.roadPts[tmpRoad.ptNum-1];
        //println("tmpRoad ["+i+"]: ");
        //println("PVector.dist(roadEndPt, tmpRoadStartPt) = "+PVector.dist(roadEndPt, tmpRoadStartPt));
        //println("PVector.dist(roadStartPt, tmpRoadEndPt) = "+PVector.dist(roadStartPt, tmpRoadEndPt));
        if (PVector.dist(roadEndPt, tmpRoadStartPt) <= roadConnectionTolerance) {
          //println("pass if 01");
          if (PVector.dist(roadStartPt, tmpRoadEndPt) > roadConnectionTolerance) {
            //println("pass if 02");
            nextRoads.add(tmpRoad);
          }
        }
      }
      //i ++;
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

  void getRotation() {
    // get rotation
    locationPt = road.getPt(t);
    locationTangent = road.getTangentVector(t);
    //rotation = PVector.angleBetween(new PVector(1.0, 0.0, 0.0), locationTangent);
    if (locationTangent.y < 0) {
      //rotation = -rotation;
    }

    //// drawn tangent
    //stroke(255, 255, 255);
    //strokeWeight(0.5F);
    //PVector v1 = locationTangent.setMag(50);
    //PVector v2 = PVector.sub(locationPt,v1);
    //PVector v3 = locationTangent.setMag(100);
    //PVector v4 = PVector.add(locationPt,v3);
    //line(v2.x, v2.y, v4.x, v4.y);

    //println("locationPt: " + locationPt);
    //println("locationNextPt: " + locationNextPt);
    //println("subPVector: " + subPVector);
    //println("rotation: " + rotation);
  }

  void render() {

    pushMatrix();
    translate(locationPt.x, locationPt.y);
    if (status==0) {
      fill(255, 240, 0);
    } else {
      fill(255, 0, 0);
    }
    ellipse(0, 0, 10, 10);
    //// draw direction line
    //stroke(0, 255, 0); 
    //strokeWeight(0.5); 
    //line(0.0, 0.0, 25.0, 0.0);

    // draw PEV img
    scale(0.3);
    //translate(-img_PEV.width/2, -img_PEV.height/2);
    popMatrix();
  }
}