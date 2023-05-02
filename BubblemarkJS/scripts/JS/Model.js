var Model = {};
Model.init = function() {

    var newModel = {}

    newModel.walls = {}
    newModel.walls.top = 0
    newModel.walls.left = 0
    newModel.walls.right = 500
    newModel.walls.bottom = 300
    newModel.elasticity = -0.02
    newModel.ballRadius = 26
    newModel.maxSpeed = 3.0
    
    return newModel;
};

module.exports = Model;
