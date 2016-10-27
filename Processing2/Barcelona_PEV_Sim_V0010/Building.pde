// Barcelona PEV Simulation v0010
// for MIT Media Lab, Changing Place Group, CityScope Project

// by Kevin Lyons <kalyons@mit.edu>
// Oct.21st.2016

class Building {
  // To be implemented...
  ArrayList<Road> nearestRoads; // Represents nearest Road to building, from which we're going to 
  float density;
  float probability;
  PVector position;
  
  
  Building(float d, float x, float y){
    nearestRoads = new ArrayList <Road>();
    density = d;
    position.x = x;
    position.y = y;
    probability = 0;
  }
  
// Returns a float with the relative probability of a job spawning from this Building in comparison to other Buildings on the grid

  float jobProbability(){
     return 0.0;
  }

  
  
}


//Methods

//jobProbability() = returns a float with the relative probability of a job spawning from this Building in comparison to other Buildings on the grid [KEVIN]
//getJobForBuilding() = returns a Job from this building, randomly assigning the pickup location to be at the building [UDGAM]
//Parameters

//nearestRoads = ArrayList<Road>, represents the nearest Roads to the Building that me will reference during the simulation
//density = float, represents population living in that building, determined from the parser
//probability = float, determined from jobProbability() method
//xPos, yPos = float, coordinates of Building on the input matrix, starting at index [0, 0] in top left