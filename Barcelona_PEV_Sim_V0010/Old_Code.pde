  ////While a job is within the bounds of our arrays for pickup and dropoff, we add the paths necessary to the closest PEVs
  //  while (pickups.Spots.size() >= currentJob && destinations.Spots.size() >= currentJob) {
  //    // Moving to starting location path
  //    if (PEVs.findNearestPEV(pickups.Spots.get(currentJob-1).locationPt) >= 0) {
  //      currentPEVs.add(PEVs.findNearestPEV(pickups.Spots.get(currentJob-1).locationPt));
  //      PEVs.PEVs.get(currentPEVs.get(currentJob-1)).action = "inRoute";
  //      PEVs.PEVs.get(currentPEVs.get(currentJob-1)).inRouteTime = time;
  //      int [] p = path.findPath(PEVs.PEVs.get(currentPEVs.get(currentJob-1)).locationPt, pickups.Spots.get(currentJob-1).locationPt, nodes);
  //      PEVs.PEVs.get(currentPEVs.get(currentJob-1)).inRoutePath.pathOfNodes = path.pathFromParentArray(p, PEVs.PEVs.get(currentPEVs.get(currentJob-1)).locationPt, pickups.Spots.get(currentJob-1).locationPt);

  //      // Moving from start to finish path

  //      int [] p2 = path.findPath(pickups.Spots.get(currentJob-1).locationPt, destinations.Spots.get(currentJob-1).locationPt, nodes);
  //      PEVs.PEVs.get(currentPEVs.get(currentJob-1)).deliveringPath.pathOfNodes = path.pathFromParentArray(p2, pickups.Spots.get(currentJob-1).locationPt, destinations.Spots.get(currentJob-1).locationPt);
        
  //      Path temp = new Path(nodes);
  //      temp.pathOfNodes = PEVs.PEVs.get(currentPEVs.get(currentJob-1)).deliveringPath.pathOfNodes;
  //      temp.drawn = true;
  //      paths.add(temp);
  //      currentJob += 1;
  //      presenceOfPath = true;
        
  //    } else {
        
  //      missingCount+=1;
        
  //      println("Missed Job#:" + currentJob);
        
  //      // KEVIN - MISSED
        
  //      currentJob+=1;
        
  //      // Using null PEV
        
  //      currentPEVs.add(PEVs.PEVs.size() - 1);
  //      Path fake = new Path(nodes);
  //      PVector r = new PVector(0.0, 0.0, 0.0);
  //      Node s = new Node(r);
  //      fake.pathOfNodes.add(s);
  //      paths.add(fake);
  //    }
  //  }
  //}
  
  
  
  
  
  
  //Spots.initiate(2);
  //  for (int i = 0; i<=1; i++) {
  //    Spot s = Spots.Spots.get(Spots.Spots.size()-(2-i));
  //    //println(s.locationPt);
  //    //Add Pickup Spot
  //    if (i == 0) {
  //      PVector p = new PVector(schedule.pickupX[currentJob], abs(schedule.pickupY[currentJob]), 0.0);
  //      s.locationPt = roads.findPVectorWithLocation(p);
  //      s.road = roads.findRoadWithLocation(s.locationPt);
  //      s.status = 0;
  //      s.t = roads.findTWithLocation(s.locationPt);
  //      pickups.addSpot(s);
  //      pickupsToSpots[pickupsIndex] = totalSpots;
  //      totalSpots += 1;
  //      pickupsIndex +=1;
  //    }
  //    //Add Delivery Spot
  //    if (i == 1) {
  //      PVector p = new PVector(schedule.dropoffX[currentJob], abs(schedule.dropoffY[currentJob]), 0.0);
  //      s.locationPt = roads.findPVectorWithLocation(p);
  //      s.road = roads.findRoadWithLocation(s.locationPt);
  //      s.status = 1;
  //      s.t = roads.findTWithLocation(s.locationPt);
  //      destinations.addSpot(s);
  //      destinationsToSpots[destinationsIndex] = totalSpots;
  //      totalSpots += 1;
  //      destinationsIndex +=1;
  //    }
  //  }
    
    
    
    
    
    ////If the job is missed
  //if (schedule.times[currentJob] < time) {
  //  println("Missed");
    
  //  //KEVIN - MISSED JOB
    
  //  currentJob+=1;
  //  Spot a = null;
  //  //Spots.initiate(2);
  //  pickups.addSpot(a);
  //  destinations.addSpot(a);
  //  pickupsIndex +=1;
  //  destinationsIndex +=1;
  //  int p = 0;
  //  currentPEVs.add(0);
  //}