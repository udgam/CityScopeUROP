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
int totalPEVNum = 10;
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

// KEVIN TO DO - Determine proper structure to keep track of all timings, sort at finish and then output with logger...

void setup() {
  
  //Testing new parser
  
  Utils u = new Utils();
  
  int[][] matrix = u.fillMatrix("matrix2.txt");
  
  ParseOutput out = u.parseInputMatrix(matrix);
  
  println(out);
  
  // Issue - do NOT allow diagonal roads...
  
  output = createWriter("activity.txt"); //<>//
  
  
  frameRate(9999);
  size(1024, 1024); //1920 x 1920: screenScale is about 1.5
  screenScale = width / 1920.0; //fit everything with screen size
  scale(screenScale);
  println("width = "+width);
  println("screenScale = "+screenScale);
  //if (drawEverything){
  pg = createGraphics(1920, 1920);

  setupScrollbars();

  smooth(8); //2,3,4, or 8

  img_BG = loadImage("BG_ALL_75DPI.png");
    
  //}
// add roads
  roadPtFile = "RD_160420.txt";
  roads = new Roads();
  roads.addRoadsByRoadPtFile(roadPtFile); //<>//
  smallerSampleRoads = new Roads();
  smallerSampleRoads.roads.add(roads.roads.get(0));
  smallerSampleRoads.roads.add(roads.roads.get(1));

  // add PEVs
  PEVs = new PEVs();
  PEVs.initiate(totalPEVNum);

  //add od data
  String d = "OD_160502_439trips_noRepeat_noIntersections.csv";
  String withRepeats = "OD_160503_1000trips_withRepeat_noIntersections.csv";
  schedule = new Schedule(d);
  
  //add Pickup Spots
  Spots = new Spots();
  paths = new ArrayList<Path>();
  pickups = new Spots();
  destinations = new Spots();
  nodes.addNodesToAllNodes(roads);
  path = new Path(nodes);

  //Missing PEV Construction
  PEV miss = new PEV(roads.roads.get(0), 0.0);
  miss.drawn = false;
  PEVs.addPEV(miss);

  //Creating Writer
  logger = createWriter("positions.csv");
  
  logger.println("Job#, Delivered(Y/N), Waiting Time, Delivery Time");
}

void draw() {
  
  time += 1;
  
  if (!drawEverything && !nothingDrawn){
    for (PEV pev: PEVs.PEVs){
      pev.drawn = false;
      pev.inRoutePath.drawn = false;
      pev.deliveringPath.drawn = false;
      nothingDrawn = true;
    }
    
  }
  
  
  
  // Getting a PEV to "pick up package"
  
  //If the job is missed
  if (schedule.times[currentJob] < time) {
    println("Missed");
    
    //KEVIN - MISSED JOB
    
    currentJob+=1;
    Spot a = null;
    //Spots.initiate(2);
    pickups.addSpot(a);
    destinations.addSpot(a);
    pickupsIndex +=1;
    destinationsIndex +=1;
    int p = 0;
    currentPEVs.add(0);
  }
  
  //If the job is found
  if (schedule.times[currentJob] == time) {
    Spots.initiate(2);
    for (int i = 0; i<=1; i++) {
      Spot s = Spots.Spots.get(Spots.Spots.size()-(2-i));
      //println(s.locationPt);
      //Add Pickup Spot
      if (i == 0) {
        PVector p = new PVector(schedule.pickupX[currentJob], abs(schedule.pickupY[currentJob]), 0.0);
        s.locationPt = roads.findPVectorWithLocation(p);
        s.road = roads.findRoadWithLocation(s.locationPt);
        s.status = 0;
        s.t = roads.findTWithLocation(s.locationPt);
        pickups.addSpot(s);
        pickupsToSpots[pickupsIndex] = totalSpots;
        totalSpots += 1;
        pickupsIndex +=1;
      }
      //Add Delivery Spot
      if (i == 1) {
        PVector p = new PVector(schedule.dropoffX[currentJob], abs(schedule.dropoffY[currentJob]), 0.0);
        s.locationPt = roads.findPVectorWithLocation(p);
        s.road = roads.findRoadWithLocation(s.locationPt);
        s.status = 1;
        s.t = roads.findTWithLocation(s.locationPt);
        destinations.addSpot(s);
        destinationsToSpots[destinationsIndex] = totalSpots;
        totalSpots += 1;
        destinationsIndex +=1;
      }
    }
    
    //While a job is within the bounds of our arrays for pickup and dropoff, we add the paths necessary to the closest PEVs
    while (pickups.Spots.size() >= currentJob && destinations.Spots.size() >= currentJob) {
      // Moving to starting location path
      if (PEVs.findNearestPEV(pickups.Spots.get(currentJob-1).locationPt) >= 0) {
        currentPEVs.add(PEVs.findNearestPEV(pickups.Spots.get(currentJob-1).locationPt));
        PEVs.PEVs.get(currentPEVs.get(currentJob-1)).action = "inRoute";
        PEVs.PEVs.get(currentPEVs.get(currentJob-1)).inRouteTime = time;
        int [] p = path.findPath(PEVs.PEVs.get(currentPEVs.get(currentJob-1)).locationPt, pickups.Spots.get(currentJob-1).locationPt, nodes);
        PEVs.PEVs.get(currentPEVs.get(currentJob-1)).inRoutePath.pathOfNodes = path.pathFromParentArray(p, PEVs.PEVs.get(currentPEVs.get(currentJob-1)).locationPt, pickups.Spots.get(currentJob-1).locationPt);

        // Moving from start to finish path

        int [] p2 = path.findPath(pickups.Spots.get(currentJob-1).locationPt, destinations.Spots.get(currentJob-1).locationPt, nodes);
        PEVs.PEVs.get(currentPEVs.get(currentJob-1)).deliveringPath.pathOfNodes = path.pathFromParentArray(p2, pickups.Spots.get(currentJob-1).locationPt, destinations.Spots.get(currentJob-1).locationPt);
        
        Path temp = new Path(nodes);
        temp.pathOfNodes = PEVs.PEVs.get(currentPEVs.get(currentJob-1)).deliveringPath.pathOfNodes;
        temp.drawn = true;
        paths.add(temp);
        currentJob += 1;
        presenceOfPath = true;
        
      } else {
        
        missingCount+=1;
        
        println("Missed Job#:" + currentJob);
        
        // KEVIN - MISSED
        
        currentJob+=1;
        
        // Using null PEV
        
        currentPEVs.add(PEVs.PEVs.size() - 1);
        Path fake = new Path(nodes);
        PVector r = new PVector(0.0, 0.0, 0.0);
        Node s = new Node(r);
        fake.pathOfNodes.add(s);
        paths.add(fake);
      }
    }
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
  
  println("Max Activity is " + maxActivity);
  
  //path.drawPath2(test);
  //path.drawPath2(test2);
  //println(deliveredCount);
  //println(missingCount);
  
  if (currentJob >= 440) {
    logger.close();
    for (Node node: nodes.allNodes){
      output.println("Node: "+ node.id + ", Node activity: "+node.activity);
    }
    //logger.flush();
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
    
    exit();
  }
}

void writeAllData() {
  // Need to find a better structure here...
}