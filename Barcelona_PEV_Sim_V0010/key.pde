void keyPressed() {
  switch(key) {
  case 'e':
    drawEverything = !drawEverything;
    break;
  case 'r': 
    drawRoads = !drawRoads;
    break;
  case 'p':
    drawPath = !drawPath;
    break;
  case 't':
    drawTest= !drawTest;
    break;
  }

  //  if (key == CODED) { 
  //    if (keyCode == LEFT) {
  //      screenMoveX--;
  //    }  
  //    if (keyCode == RIGHT) {
  //      screenMoveX++;
  //    }  
  //    if (keyCode == DOWN) {
  //      screenMoveY++;
  //    }  
  //    if (keyCode == UP) {
  //      screenMoveY--;
  //    }
  //  }
}

//toggleRoadDraw() {
//  if (mode < maxMode) {
//    return mode + 1;
//  } else {
//    return 0;
//  }
//}