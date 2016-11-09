// Hamburg PEV Simulation v0010
// for MIT Media Lab, Changing Place Group, CityScope Project

// by Yan Zhang (Ryan) <ryanz@mit.edu>
// Dec.8th.2015

// Test comment from Kevin < kalyons@mit.edu >

PFont myFont;
PImage img_BG;
PGraphics pg;
String roadPtFile;
float screenScale;  //1.0F(for normal res or OS UHD)  2.0F(for WIN UHD)
int totalPEVNum = 20;
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
boolean drawRoads = false;
boolean drawPath = false;
boolean drawTest = false;
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
Schedule schedule;
ArrayList <PVector> test, test2;
boolean add = true;
PrintWriter logger;
boolean drawEverything = true;
boolean nothingDrawn = false;
PrintWriter output;
ArrayList <Building> allBuildings;
boolean jobPresent = false;
Probability prob = new Probability();
int totalDensity = 0;

LogManager log = new LogManager();

int totalRunTime = 500; // 1 day in minutes - 20 minutes?

// TO DO - Create configurable input format...

LogStatus logStatus = LogStatus.DetailedPrint;

void setup() {
  
  //Testing new parser
  
  Utils u = new Utils();
  
  int[][] matrix = u.fillMatrix("matrix2.txt");
  
  ParseOutput out = u.parseInputMatrix(matrix);
  roads = out.roads;
  allBuildings = out.buildings;
  
  for (Building building: allBuildings){
    building.nearestRoad = roads.findRoadWithLocation(building.position);
    building.nearestPt = roads.findPVectorWithLocation(building.position);
    totalDensity += int(building.density);
  }

  
  prob.init("function.txt");
  
  float x = prob.getValue(1565);
  
  // Testing logging tools.
  
  log.init();
  
  output = createWriter("activity.txt");
  
  frameRate(9999);
  size(1024, 1024); //1920 x 1920: screenScale is about 1.5
  screenScale = width / 1920.0; //fit everything with screen size
  scale(screenScale); //<>//
  println("width = "+width);
  println("screenScale = "+screenScale);
  //if (drawEverything){
  pg = createGraphics(1920, 1920); //<>//

  setupScrollbars();

  smooth(8); //2,3,4, or 8

  img_BG = loadImage("BG_ALL_75DPI.png");
    
  //}
// add roads
  //roadPtFile = "RD_160420.txt";
  //roads = new Roads();
  //roads.addRoadsByRoadPtFile(roadPtFile); //<>//
  //smallerSampleRoads = new Roads();
  //smallerSampleRoads.roads.add(roads.roads.get(0));
  //smallerSampleRoads.roads.add(roads.roads.get(1));
  //roadPtFile = "RD_160420.txt";
  //roads = new Roads();
  //roads.addRoadsByRoadPtFile(roadPtFile);
  //smallerSampleRoads = new Roads();
  //smallerSampleRoads.roads.add(roads.roads.get(0));
  //smallerSampleRoads.roads.add(roads.roads.get(1));

  // add PEVs
  PEVs = new PEVs();
  PEVs.initiate(totalPEVNum);

  //add od data
  String d = "OD_160502_439trips_noRepeat_noIntersections.csv";
  String withRepeats = "OD_160503_1000trips_withRepeat_noIntersections.csv";
  schedule = new Schedule();
  
  //add Pickup Spots
  Spots = new Spots(); //<>// //<>//
  paths = new ArrayList<Path>();
  pickups = new Spots();
  destinations = new Spots();
  nodes.addNodesToAllNodes(roads);
  path = new Path(nodes);
  
  println(nodes.allNodes); //<>//
  //Missing PEV Construction //<>//
  PEV miss = new PEV(roads.roads.get(0), 0.0, -1);
  miss.drawn = false;
  PEVs.addPEV(miss);

  //Creating Writer
  // logger = createWriter("positions.csv");
  
  // logger.println("Job#, Delivered(Y/N), Waiting Time, Delivery Time");
  
  log.logEvent("Simulation initialized.");
  log.logEvent("Using LogStatus type of " + logStatus.toString() + ".");
}

void draw() {
  time += 1;
  
  if ((logStatus == LogStatus.PEVPrint || logStatus == LogStatus.DetailedPrint)) { // && time % 10 == 0 Only execute every 10 timesteps
    log.logPEVLocations(PEVs.PEVs, time);
  }
  
  if (! drawEverything && ! nothingDrawn) {
    for (PEV pev: PEVs.PEVs){
      pev.drawn = false; //<>// //<>//
      pev.inRoutePath.drawn = false;
      pev.deliveringPath.drawn = false;
      nothingDrawn = true;
    }
    
  }
  float currentProb = prob.getValue(time)*100;
  float randomJobProb = random(100);
  if (randomJobProb <= currentProb){
    jobPresent = true;
  }
  else{
    jobPresent = false;
  }
  // Getting a PEV to "pick up package"
  

  
  //If the job is found
  if (jobPresent) {
    
    // Finding random pickup Building and dropOff Building
    int pickupBuildingRand = int(random(totalDensity));
    int dropOffBuildingRand = int(random(totalDensity));
    Building pickupBuilding = null;
    Building dropOffBuilding = null;
    
    int currentDensity = 0;
    for(Building building: allBuildings){
      currentDensity += int(building.density);
      if (pickupBuildingRand <= currentDensity && pickupBuilding == null){
        pickupBuilding = building;
      }
      if (dropOffBuildingRand <= currentDensity && dropOffBuilding == null && pickupBuilding != building){
        dropOffBuilding = building;
      }
    }
    
    
    schedule.times.add(time);
    schedule.pickupX.add(pickupBuilding.position.x);
    schedule.pickupY.add(pickupBuilding.position.y);
    schedule.pickupY.add(dropOffBuilding.position.x);
    schedule.pickupY.add(dropOffBuilding.position.y);
    schedule.jobStarted.add(!jobPresent);

    println("CHECKING VALUES");
    println(totalDensity);
    println(pickupBuildingRand);
    println(dropOffBuildingRand);
    println(pickupBuilding.position);
    println(pickupBuilding.density);
    println(pickupBuilding.nearestPt);
    println(dropOffBuilding.position);
    
    PVector pickupLocation = pickupBuilding.nearestPt;
    PVector dropOffLocation = dropOffBuilding.nearestPt;
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
        //pickups.addSpot(s);
        //pickupsToSpots[pickupsIndex] = totalSpots;
        //totalSpots += 1;
        //pickupsIndex +=1;
      }
      //Add Delivery Spot
      if (i == 1) {
        
        s.locationPt = dropOffLocation;
        s.road = dropOffBuilding.nearestRoad;
        s.status = 1;
        s.t = roads.findTWithLocation(s.locationPt);
        //destinations.addSpot(s);
        //destinationsToSpots[destinationsIndex] = totalSpots;
        //totalSpots += 1;
        //destinationsIndex +=1;
        
        
      }
    }
    
    //Start currentJob
      // Moving to starting location path
    
    
      if (PEVs.findNearestPEV(pickupLocation) >= 0) {
        println("Empty PEV Found");
        currentPEVs.add(PEVs.findNearestPEV(pickupLocation));
        PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).action = "inRoute";
        PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).inRouteTime = time;
        int [] p = path.findPath(PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).locationPt, pickupLocation, nodes);
        PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).inRoutePath.pathOfNodes = path.pathFromParentArray(p, PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).locationPt, pickupLocation);
        //print("Path from PEV to pickup");
        //println(PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).inRoutePath.pathOfNodes);
        // Moving from start to finish path

        int [] p2 = path.findPath(pickupLocation, dropOffLocation, nodes);
        PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).deliveringPath.pathOfNodes = path.pathFromParentArray(p2, pickupLocation, dropOffLocation);
        //println("Path from pickup to dropOff");
        //println(PEVs.PEVs.get(currentPEVs.get(currentPEVs.size() - 1)).deliveringPath.pathOfNodes);
        Path temp = new Path(nodes);
        temp.pathOfNodes = PEVs.PEVs.get(currentPEVs.get(currentJob-1)).deliveringPath.pathOfNodes;
        temp.drawn = true;
        paths.add(temp);
        currentJob += 1;
        presenceOfPath = true;
        
      }
      //else {
        
      //  missingCount+=1;
        
      //  println("Missed Job#:" + currentJob);
        
      //  // KEVIN - MISSED
        
      //  currentJob+=1;
        
      //  // Using null PEV
        
      //  currentPEVs.add(PEVs.PEVs.size() - 1);
      //  Path fake = new Path(nodes);
      //  PVector r = new PVector(0.0, 0.0, 0.0);
      //  Node s = new Node(r);
      //  fake.pathOfNodes.add(s);
      //  paths.add(fake);
      //}
  }

  //Checking PEV Status, seeing if any PEVS have recently completed jobs
  if (currentPEVs.size() > 0) {
    int s = 0;
    int count  = 0;
    for (int job : currentPEVs) {
      if (PEVs.PEVs.get(job).action == "wandering") {
        if (s < Spots.Spots.size() && Spots.Spots.get(s).drawn) {
          Spots.Spots.get(s).drawn = false;
          Spots.Spots.get(s+1).drawn = false;
          paths.get(s/2).drawn = false;
          deliveredCount+=1;
          if (PEVs.PEVs.get(job).drawn == true) {
            // Job completed
            
            // KEVIN - JOB COMPLETED
            
            String statusString = "Y";
            String waitString = Integer.toString(PEVs.PEVs.get(job).deliveryTime-PEVs.PEVs.get(job).inRouteTime);
            String deliverString = Integer.toString(time - PEVs.PEVs.get(job).deliveryTime);
            
            // LOG THIS OUT
          }
        }
      }
      count += 1;
      s = s + 2;
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

    image(img_BG, 0, 0, 1920, 1920);
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
    image(pg, 0, 0);

    //show frameRate;
    //println(frameRate);
    textAlign(RIGHT);
    textSize(10*2/screenScale);
    fill(200);
    text("frameRate: "+str(int(frameRate)), 1620 - 50, 50);
    //println(frameRate);

    // draw scollbars
    drawScrollbars();
  }
  
  targetPEVNum = int(ScrollbarRatioPEVNum*45+5); //5 to 50
  PEVs.changeToTargetNum(targetPEVNum);
  maxSpeedKPH = (ScrollbarRatioPEVSpeed*20+10)*10; //units: kph  10.0 to 50.0 kph
  maxSpeedMPS = maxSpeedKPH * 1000.0 / 60.0 / 60.0; //20.0 KPH = 5.55556 MPS
  maxSpeedPPS = maxSpeedMPS / scaleMeterPerPixel;
  
  if (drawEverything) {
    fill(255);
    noStroke();
    rect(260, 701, 35, 14);
    rect(260, 726, 35, 14);
    textAlign(LEFT);
    textSize(10);
    fill(200);
    text("mouseX: "+mouseX/screenScale+", mouseY: "+mouseY/screenScale, 10, 20);
    fill(0);
    text(targetPEVNum, 263, 712);
    text(int(maxSpeedKPH/10), 263, 736);
    text(int(ScrollbarRatioProb), 263, 760);
  }
  
  int maxActivity = 0;
  
  //for(Node node: nodes.allNodes){
  //    if (node.activity > maxActivity){
  //      maxActivity = node.activity;
  //    }
  //    node.drawNode(node.activity);
      
  //}
  
  //println("Max Activity is " + maxActivity);
  
  //path.drawPath2(test);
  //path.drawPath2(test2);
  //ln(deliveredCount);
  //println(missingCount);
  
  //println(time);
  
  if (currentJob == 100) { // Should be totalRunTime
    // Make sure that all jobs have some "completed state", whether that be completed or missed.
    // Don't want any hanging jobs.
    log.logEvent("Simulation complete after total time of " + totalRunTime + " minutes.");
    log.logEvent("---------- Job Summary ----------");
    log.logEvent("Missed Job Count = " + missingCount + " jobs.");
    
    log.close();
    exit();
  }
}