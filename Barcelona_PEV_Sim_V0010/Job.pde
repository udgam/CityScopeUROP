class Job {
  int startTime;   PVector pickupLocation;
  PVector dropOffLocation;
  String jobState;
  int endTime;
  int jobCreated;
  PEV pev;// Either "notStarted", "inProgress", or "complete"

  Job(int time, PVector pickup, PVector dropOff) {
    jobCreated = time;
    pickupLocation = pickup;
    dropOffLocation = dropOff;
    jobState = "notStarted";
  }
}