var BallsTest = require("JS/BallsTest");
var eventsInsteadOfTimers = true;
var gBallsTest = {};

function CBInit(mapargs){
  gBallsTest = BallsTest.init(16);
  BallsTest.start(gBallsTest);
};

function CBStartFrame(mapargs){
   if (eventsInsteadOfTimers) {
        sb.sendEvent('next_frame');
    } else {
        sb.sendEvent('start_frame_timer');
    }
};

function CBMove(mapargs){
    BallsTest.moveBalls(gBallsTest);
    if (eventsInsteadOfTimers) {
        sb.sendEvent("next_frame")
    }
};

function CBFPSUpdate(mapargs){
    BallsTest.showFPS(gBallsTest);
};