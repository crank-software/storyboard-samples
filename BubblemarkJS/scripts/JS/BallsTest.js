const Ball = require("JS/Ball");
var BallsTest = {};

BallsTest.init = function(numBalls) {
  	var newBT = {}
    newBT._N = numBalls;
    newBT._balls = {};
    newBT._isRunning = false;

    newBT._F = 0;  // frames counter for FPS
    newBT._lastF = 0;
    newBT._lastTime = 0;
    newBT.__index = newBT;
	
    return newBT;
};

BallsTest.startN = function(ballTestObj, N) {
 
  ballTestObj._N = N;
  start();
};

BallsTest.start = function(ballTestObj) {
  print("BallsTest start");
  if (ballTestObj._isRunning) {
	  print("BallsTest is already runnin;")
      return;
    }
	
    ballTestObj._isRunning = true;
        
    ballTestObj._F = 0;  // frames counter for FPS
    ballTestObj._lastF = 0;
    var currDate = new Date();
    ballTestObj._lastTime = currDate.getTime();
        
    // create all our balls
    var i = 0;
    for(i = 0; i<ballTestObj._N; i++) {
        ballTestObj._balls[i] = Ball.init();
    }
};

BallsTest.stop = function(ballTestObj) {
   if (!ballTestObj._isRunning) {
      return;
   }
   ballTestObj._isRunning = false;
   ballTestObj._balls = {}  
};

BallsTest.moveBalls = function(ballTestObj) {

  if (!ballTestObj) {
        print("Missing object");
        return;
    }

    if (!ballTestObj._isRunning) {
        print("Not running");
        return;
    }
	
    ballTestObj._F = ballTestObj._F + 1;

    // move balls
    var i=0;
    for(i=0;i<ballTestObj._N;i++) {
        Ball.move(ballTestObj._balls[i]);
    }

    // process collisions
    for(i=0;i<ballTestObj._N-1;i++){
        var j= 0;
        for(j=i+1;j<ballTestObj._N-1;j++){
            Ball.doCollide(ballTestObj._balls[j], ballTestObj._balls[i]);
        }
    }
	
    // Visually update, was part of Ball object
    var prefix = "MainLayer.Ball" 
    var stem;
    var data = {};
    var i = 0;
    for (i=0;i<ballTestObj._N;i++) {
        stem = prefix + i;
         
        data[stem + ".grd_x"] = ballTestObj._balls[i]._x;
        data[stem + ".grd_y"] = ballTestObj._balls[i]._y;
        
        sb.setValue(stem + ".grd_x", data[stem + ".grd_x"]+"");
        sb.setValue(stem + ".grd_y", data[stem + ".grd_y"]+"");
    }
};

BallsTest.showFPS = function(ballTestObj) {
  
   if (ballTestObj._F - ballTestObj._lastF < 10) {
        return;
    }
	
	var currDate = new Date();
    var currTime = currDate.getTime();
    var delta_t = (currTime - ballTestObj._lastTime) / 1000;
    var fps = ((ballTestObj._F - ballTestObj._lastF)/delta_t);
                
    ballTestObj._lastF = ballTestObj._F;
    ballTestObj._lastTime = currTime;

    // Set the data variable   
    var data = {}
    data["fpsText"] = "FPS: " + Math.floor(fps);
    sb.setValue("fpsText", data["fpsText"]);
};

module.exports = BallsTest;