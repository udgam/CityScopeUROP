// Hamburg PEV Simulation v0010 //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
// for MIT Media Lab, Changing Place Group, CityScope Project

// by Yan Zhang (Ryan) <ryanz@mit.edu>
// Dec.8th.2015

// Test comment from Kevin < kalyons@mit.edu >

PFont myFont;
PImage img_BG;
PGraphics pg;
String roadPtFile;
float screenScale;  //1.0F(for normal res or OS UHD)  2.0F(for WIN UHD)
int totalPEVNum = 50;
int totalSpotNum = 0;
int targetPEVNum;
int totalRoadNum;
float scaleMeterPerPixel = 2.15952; //meter per pixel in processing; meter per mm in rhino
float ScrollbarRatioPEVNum = 0.12;
float ScrollbarRatioPEVSpeed = 0.5;
float ScrollbarRatioProb = 0.25;
Roads roads = new Roads();
Roads smallerSampleRoads;
PEVs PEVs;
Spots Spots;
boolean drawRoads = true;
boolean drawPath = true;
boolean drawTest = false;
boolean drawAllNodes = false;
ArrayList <Path> paths;
Path path;
Spots pickups;
Spots destinations;
int[] pickupsToSpots = new int[100000];
int[] destinationsToSpots = new int[100000];
Nodes nodes = new Nodes();
boolean presenceOfPath = false;
int time = 0;
int currentJob = 1;
ArrayList <Integer> currentPEVs = new ArrayList <Integer>();
int currentSpot = 0;
int currentPEV = -1;
int totalSpots = 0;
int pickupsIndex = 0;
int destinationsIndex = 0;
int missingCount = 0;
int deliveredCount = 0;
ArrayList <Job> jobSchedule;
ArrayList <PVector> test, test2;
boolean add = true;
PrintWriter logger;
boolean drawEverything = true;
boolean nothingDrawn = false;
ArrayList <Building> allBuildings;
boolean jobPresent = false;
Probability prob = new Probability();
int totalDensity = 0;
int totalJobs = 0;
boolean drawOnce = true;
float constantFactor = 100.0;
float starting = 100;


int waitTime = 20*60; // maxWaitTime, minutes * 60

Boolean makeJobs = true;

LogManager log = new LogManager();

int totalRunTime = 60*60*24/2;

float simSpeed = 13; // (seconds/frame)

LogStatus logStatus = LogStatus.NoPrint;

void setup() {

  log.init(false);

  prob.init("demand.txt");

  CityGenerator c = new CityGenerator();

  CityOutput city = c.run();

  int[][] matrix = c.fillMatrix("matrix_custom.txt");

  //CityOutput city = u.parseInputMatrix(matrix, true);

  roads = city.roads; //<>//
  allBuildings = city.buildings;

  for (Building building : allBuildings) {
    building.nearestRoad = roads.findRoadWithLocation(building.position);
    building.nearestPt = roads.findPVectorWithLocation(building.position);
    totalDensity += int(building.density);
  }

  frameRate(9999);
  size(1024, 1024); //1920 x 1920: screenScale is about 1.5
  screenScale = width / 1920.0; //fit everything with screen size
  scale(screenScale); //<>// //<>//
  println("width = "+width);
  println("screenScale = "+screenScale);
  //if (drawEverything){
  pg = createGraphics(1920, 1920); //<>// //<>//

  //setupScrollbars();

  smooth(8); //2,3,4, or 8

  img_BG = loadImage("BG_ALL_75DPI.png"); //<>// //<>//

  // add PEVs
  PEVs = new PEVs();
  PEVs.initiate(totalPEVNum);

  //add od data
  //String d = "OD_160502_439trips_noRepeat_noIntersections.csv";
  //String withRepeats = "OD_160503_1000trips_withRepeat_noIntersections.csv";
  jobSchedule = new ArrayList<Job>();
  //add Pickup Spots
  Spots = new Spots(); //<>// //<>// //<>//
  paths = new ArrayList<Path>();
  pickups = new Spots();
  destinations = new Spots(); //<>// //<>//
  nodes.addNodesToAllNodes(roads);
  path = new Path(nodes);
  //Missing PEV Construction //<>// //<>//
  PEV miss = new PEV(roads.roads.get(0), 0.0, -1);
  miss.drawn = false;
  PEVs.addPEV(miss);

  log.logEvent("Simulation initialized with " + totalPEVNum + " available PEVs.");
  log.logEvent("Using LogStatus type of " + logStatus.toString() + ".\n");
  //log.logMatrix(city.matrix, city.matrix[0].length);
  
  
}

void draw() {
  time += simSpeed;
  
  if ((logStatus == LogStatus.PEVPrint || logStatus == LogStatus.DetailedPrint)) { // && time % 10 == 0 Only execute every 10 timesteps
    log.logPEVLocations(PEVs.PEVs, time);
  }

  if (! drawEverything && ! nothingDrawn) {
    for (PEV pev : PEVs.PEVs) {
      pev.drawn = false; //<>// //<>// //<>// //<>//
      pev.inRoutePath.drawn = false;
      pev.deliveringPath.drawn = false;
      nothingDrawn = true;
    } //<>// //<>//
  }

  if (makeJobs) {
    
    // Add j jobs to the queue, then continue as normal
    
    int jobCount = prob.getJobCount(time, simSpeed);
    
    for(int j = 0; j<jobCount; j++){

      // Finding random pickup Building and dropOff Building
      int pickupBuildingRand = int(random(totalDensity));
      int dropOffBuildingRand = int(random(totalDensity));
      Building pickupBuilding = null;
      Building dropOffBuilding = null;

      int currentDensity = 0;
      for (Building building : allBuildings) {
        currentDensity += int(building.density);
        if (pickupBuildingRand <= currentDensity && pickupBuilding == null) {
          pickupBuilding = building;
        }
        if (dropOffBuildingRand <= currentDensity && dropOffBuilding == null && pickupBuilding != building) {
          dropOffBuilding = building;
        }
      }
      if (pickupBuilding == null){
        println("Pickup Building is null");
      }
      else if (dropOffBuilding == null){
        println("Dropoff Building is null");
      } else {
        Job newJob = new Job(time, pickupBuilding.nearestPt, dropOffBuilding.nearestPt);
        jobSchedule.add(newJob);
        
  
        //println("CHECKING VALUES");
        //println(totalDensity);
        //println(pickupBuildingRand);
        //println(dropOffBuildingRand);
        //println(pickupBuilding.position);
        //println(pickupBuilding.density);
        //println(pickupBuilding.nearestPt);
        //println(dropOffBuilding.position);
  
        PVector pickupLocation = pickupBuilding.nearestPt;
        PVector dropOffLocation = dropOffBuilding.nearestPt;
        //println("pickup Location:" + pickupLocation);
        //println("dropoff Location:" +dropOffLocation);
        Spots.initiate(2);
        for (int i = 0; i<=1; i++) {
          Spot s = Spots.Spots.get(Spots.Spots.size()-(2-i));
          //println(s.locationPt);
          //Add Pickup Spot
          if (i == 0) {
  
            s.locationPt = pickupLocation;
            s.road = pickupBuilding.nearestRoad;
            s.status = 0;
            s.t = roads.findTWithLocation(s.locationPt);
            pickups.addSpot(s);
            pickupsToSpots[pickupsIndex] = totalSpots;
            totalSpots += 1;
            pickupsIndex +=1;
          }
          //Add Delivery Spot
          if (i == 1) {
  
            s.locationPt = dropOffLocation;
            s.road = dropOffBuilding.nearestRoad;
            s.status = 1;
            s.t = roads.findTWithLocation(s.locationPt);
            destinations.addSpot(s);
            destinationsToSpots[destinationsIndex] = totalSpots;
            totalSpots += 1;
            destinationsIndex +=1;
          }
        }
      }
    }
    
    //println("Current queue size = " + jobSchedule.size() + ". Time = " + time + ". Jobs added = " + jobCount + ".");
    
    println(time);
    
    }
      
      for (int i = 0; i <= jobSchedule.size() - 1; i++) {
        if (jobSchedule.get(i).jobCreated < time - waitTime){
            if (jobSchedule.get(i).jobState == "notStarted"){
              missingCount += 1;
            }
            jobSchedule.get(i).jobState = "missed";   
        }
        
        else {
          if (jobSchedule.get(i).jobState == "notStarted") {
            if (PEVs.findNearestPEV(jobSchedule.get(i).pickupLocation) >= 0) {
              Job current = jobSchedule.get(i);
              jobSchedule.get(i).startTime = time;
              jobSchedule.get(i).jobState = "inProgress";
              //println("Empty PEV Found");
              currentPEVs.add(PEVs.findNearestPEV(current.pickupLocation));
              PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).action = "inRoute";
              PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).inRouteTime = time;
              jobSchedule.get(i).pev = PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1));
              int [] p = path.findPath(PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).locationPt, current.pickupLocation, nodes);
              PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).inRoutePath.pathOfNodes = path.pathFromParentArray(p, PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).locationPt, current.pickupLocation);
              //print("Path from PEV to pickup");
              //println(PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).inRoutePath.pathOfNodes);
              // Moving from start to finish path
  
              int [] p2 = path.findPath(current.pickupLocation, current.dropOffLocation, nodes);
              ArrayList <Node> t = path.pathFromParentArray(p2, current.pickupLocation, current.dropOffLocation);
              PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).deliveringPath.pathOfNodes = t;
              //for(Node node: t){
              //  print(node.point);
              //}
              //println("Path from pickup to dropOff");
              //println(PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).deliveringPath.pathOfNodes);
              Path temp = new Path(nodes);
              temp.pathOfNodes = PEVs.PEVs.get(currentPEVs.get(currentJob-1)).deliveringPath.pathOfNodes;
              temp.drawn = true;
              paths.add(temp);
              currentJob += 1;
              presenceOfPath = true; //<>// //<>//
            }
          }
        }
        
      }
  

  //Checking PEV Status, seeing if any PEVS have recently completed jobs
  if (currentPEVs.size() > 0) {
    int s = 0;
    int count  = 0;
    for (int job : currentPEVs) {
      try {
      if (PEVs.PEVs.get(job).action == "wandering") {
        if (s < Spots.Spots.size() && Spots.Spots.get(s).drawn) {
          Spots.Spots.get(s).drawn = false;
          Spots.Spots.get(s+1).drawn = false;
          paths.get(s/2).drawn = false;
          deliveredCount += 1;
          // Need to link this "job" to an actual index in our schedule...
          //String waitString = Integer.toString(PEVs.PEVs.get(job).deliveryTime-PEVs.PEVs.get(job).inRouteTime);
          //String deliverString = Integer.toString(time - PEVs.PEVs.get(job).deliveryTime);
        }

        for (int i =0; i<= jobSchedule.size()- 1; i ++) {
          if (jobSchedule.get(i).pev == PEVs.PEVs.get(job)) {
            jobSchedule.get(i).jobState = "completed";
            jobSchedule.get(i).endTime = time;
          }
        }
        count += 1;
        s = s + 2;
      } } catch (Exception e) {
        // UDGAM - Take a look at this out of bounds error???
      }
    }
  }

  if (drawEverything) {
    scale(screenScale);
    background(0);

    pg.beginDraw();
    pg.background(0);
    pg.stroke(255);
    pg.line(20, 20, mouseX, mouseY);

    imageMode(CORNER);
    
    

    //image(img_BG, 0, 0, 1920, 1920);
  }

  // draw roads
  if (drawRoads && drawEverything) {
    roads.drawRoads();
  }

  if (drawTest) {
    //for (int i = 0; i<= nodes.allNodes.size()-2; i++){
    //path.drawAllPaths();
  }

  if (presenceOfPath && drawEverything) {
    for (Path eachPath : paths) {
      if (eachPath.drawn) {
        path.drawPath(eachPath.pathOfNodes);
      }
    }
  }

  // run PEVs
  PEVs.run(time);
  Spots.run();

  if (drawEverything) {
    //image(pg, 0, 0);

    //show frameRate;
    //println(frameRate);
    textAlign(RIGHT);
    textSize(10*2/screenScale);
    fill(200);
    text("frameRate: "+str(int(frameRate)), 1620 - 50, 50);
    //println(frameRate);

    // draw scollbars
    //drawScrollbars();
  }
  
  if (drawAllNodes){
      for (Node node: nodes.allNodes){
        node.drawNode();
    }
  }

  targetPEVNum = int(ScrollbarRatioPEVNum*45+5); //5 to 50
  PEVs.changeToTargetNum(targetPEVNum);
  maxSpeedKPH = (ScrollbarRatioPEVSpeed*20+10)*10; //units: kph  10.0 to 50.0 kph
  maxSpeedMPS = maxSpeedKPH * 1000.0 / 60.0 / 60.0; //20.0 KPH = 5.55556 MPS
  maxSpeedPPS = maxSpeedMPS / scaleMeterPerPixel;


  //Drawing Scrollbar stuff
  
  //if (drawEverything) {
  //  fill(255);
  //  noStroke();
  //  rect(260, 701, 35, 14);
  //  rect(260, 726, 35, 14);
  //  textAlign(LEFT);
  //  textSize(10);
  //  fill(200);
  //  text("mouseX: "+mouseX/screenScale+", mouseY: "+mouseY/screenScale, 10, 20);
  //  fill(0);
  //  text(targetPEVNum, 263, 712);
  //  text(int(maxSpeedKPH/10), 263, 736);
  //  text(int(ScrollbarRatioProb), 263, 760);
  //}
  
  int maxActivity = 0;

  //for(Node node: nodes.allNodes){
  //    if (node.activity > maxActivity){
  //      maxActivity = node.activity;
  //    }
  //    node.drawNode(node.activity);

  //}

  
  if (time >= totalRunTime) {
    makeJobs = false;
    println("---------");
    
    //for (int i = 0; i <= jobSchedule.size() - 1; i++) {
    //    println(jobSchedule.get(i).jobState);
    //  }
    
    //println(jobSchedule.size() + " " + deliveredCount + " " + missingCount);
    
    if (jobSchedule.size() == deliveredCount + missingCount || time > totalRunTime + 5 * waitTime) {

      if (drawOnce) {
        println("FINISHED");
        println("-----------------------------------------------");
        background(51);
        stroke(265, 265, 265);
        fill(0, 0, 0);
        rectMode(CORNERS);
        rect(70.0, 70.0, 350.0, 350.0);
        strokeWeight(10);
        float factor = 20;
        float start = 50;

        
        for (Node node : nodes.allNodes) {
          stroke(float(265 - node.activity*100),265 - float(node.activity*10),265 - float(node.activity*10));
          point(factor*node.point.x + start, factor*node.point.y + start);
          //println("Node at "+node.point+" has activity of "+node.activity );
        }
        drawOnce = false;
      }
      
      log.logEvent("\nSimulation complete after total time of " + totalRunTime + " seconds.");
      log.logEvent("\n---------- Job Summary ----------");
      // TO DOs
      log.logEvent("\nMissed Job Count = " + missingCount + " jobs.");
      log.logEvent("\nDelivered Job Count = " + deliveredCount + " jobs.");
      float percent2 = ((float)deliveredCount / (float)jobSchedule.size()) * 100.0;
      log.logEvent("\nJob Completion Percentage = " + deliveredCount + "/" + jobSchedule.size() + " = " + percent2 + "%.");
      log.logEvent("\nSimulation complete in " + millis()/1000 + " seconds.");
      log.close();
      println("Here!!! Okay to exit now.");
      //exit();
    }
  }
}