--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

require("BallsTest")

-- Call back functions for the BubbleMark benchmark test

-- This controls the runtime behaviour of this test.  The original JS version
-- runs on a fixed timer, but that means that the test is artificially
-- limited in its framerate.  By making the test entirely event driven (draw
-- a frame, trigger next frame) we make the test scale up/down more appropriately.
-- eventsInsteadOfTimers ==> TRUE makes the test purely event driven
-- eventsInsteadOfTimers ==> FALSE makes the test run at the timer rate
local eventsInsteadOfTimers = true

-- Our root control object
local gBallsTest

-- Initialize the test with 16 balls
function CBInit(mapargs)
    --print("Init Balls Test")
    gBallsTest = BallsTest:init(16)
    gBallsTest:start()
end

function CBStartFrame(mapargs)
    if (eventsInsteadOfTimers) then
        gre.send_event("next_frame")
    else
        gre.send_event("start_frame_timer")
    end
end

function CBMove(mapargs)
    --print("Move Balls")
    gBallsTest:moveBalls()
	
    if (eventsInsteadOfTimers) then
        gre.send_event("next_frame")
    end
end

function CBFPSUpdate(mapargs)
    --print("FPS Update")
    gBallsTest:showFPS()
end
