--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

module("Model", package.seeall)

function Model:init() 
    local newModel = {}

    newModel.walls = {}
    newModel.walls.top = 0
    newModel.walls.left = 0
    newModel.walls.right = 500
    newModel.walls.bottom = 300
    newModel.elasticity = -0.02
    newModel.ballRadius = 26
    newModel.maxSpeed = 3.0
    
    return newModel;
end

--[[
REFERENCE Java Source: http://bubblemark.com/

private static final class Model {
        private Insets walls = new Insets(0, 0, 300, 500);
        private double elastity = -.02;
        private double ballRadius = 26;
        private double maxSpeed = 3.0;
}
]]

