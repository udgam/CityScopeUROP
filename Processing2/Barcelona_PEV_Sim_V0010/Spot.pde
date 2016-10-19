// Barcelona PEV Simulation v0010
// for MIT Media Lab, Changing Place Group, CityScope Project

// by Udgam Goyal <udgam@mit.edu>
// Feb.8th.2015
class Spot {

  int status; //0 = Pick Up, 1 = Destination
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

  void getRotation() {
    // get rotation
    locationPt = road.getPt(t);
    locationTangent = road.getTangentVector(t);
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
    
    // draw PEV img
    scale(0.3);
    popMatrix();
  }
}