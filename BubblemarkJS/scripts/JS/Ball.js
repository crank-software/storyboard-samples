var Model = require('JS/Model');

var Ball = {};

Ball.init = function(existingBall) {
   var newBall = {};
   if(existingBall){
      newBall = existingBall;
   }
   
   var modelObject = Model.init();
   newBall.model = modelObject;
   
   var rand1 = Math.random();
   newBall._x = (modelObject.walls.right - modelObject.walls.left - (2*modelObject.ballRadius))*rand1;
   newBall._y = (modelObject.walls.bottom - modelObject.walls.top - (2*modelObject.ballRadius))*rand1;
   var rand2 = Math.random();
   newBall._vx = (((2*modelObject.maxSpeed)*rand2) - modelObject.maxSpeed);
   var rand3 = Math.random(); 
   newBall._vy = (((2*modelObject.maxSpeed)*rand3) - modelObject.maxSpeed);
   newBall._r = modelObject.ballRadius;
   newBall._d = 2*newBall._r;
   newBall._d2 = newBall._d*newBall._d;
  
   return newBall;
};

Ball.move = function(ballObj) {
   if(!ballObj){
	  print("I'm not an object");
	  return;
   }
   
   var model = ballObj.model;
   ballObj._x = ballObj._x + ballObj._vx;
   ballObj._y = ballObj._y + ballObj._vy;
  
    // left
    if (ballObj._x < model.walls.left && ballObj._vx<0) {
		    ballObj._vx = 0 - ballObj._vx;
    }
    // top
    if (ballObj._y < model.walls.top && ballObj._vy<0) {
		    ballObj._vy = 0 - ballObj._vy;
    }
    // right
    if (ballObj._x > (model.walls.right - ballObj._d) && ballObj._vx>0) {
		    ballObj._vx = 0 - ballObj._vx;
    }
    // bottom
    if (ballObj._y > (model.walls.bottom - ballObj._d) && ballObj._vy>0) {
        ballObj._vy = 0 - ballObj._vy;
    }
};

Ball.doCollide = function(ballObj, otherBallObj) {
  	if (!ballObj) {
        print("I'm not an object");
        return false;
    }
	
    // calculate some vectors
    var dx = ballObj._x - otherBallObj._x;
    var dy = ballObj._y - otherBallObj._y;
    var dvx = ballObj._vx - otherBallObj._vx;
    var dvy = ballObj._vy - otherBallObj._vy;
    var distance2 = (dx*dx) + (dy*dy);
        
    if (Math.abs(dx) > ballObj._d || Math.abs(dy) > ballObj._d) {
        return false;
    }
    if (distance2 > ballObj._d2) {
        return false;
    }
        
    // make absolutely elastic collision
    var mag = (dvx*dx) + (dvy*dy);
        
    // test that balls move towards each other
    if (mag > 0) {
        return false;
    }
	
    mag = mag / distance2;
        
    var delta_vx = dx*mag;
    var delta_vy = dy*mag;
            
    ballObj._vx = ballObj._vx - delta_vx;
    ballObj._vy = ballObj._vy - delta_vy;
           
    otherBallObj._vx = otherBallObj._vx + delta_vx;
    otherBallObj._vy = otherBallObj._vy + delta_vy;

    return true;
};

module.exports = Ball;