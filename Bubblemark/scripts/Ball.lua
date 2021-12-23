--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

module("Ball", package.seeall)

require("Model")

function Ball:init(controlName) 
    local newBall = {}
    setmetatable(newBall, self)
    self.__index = self

    local model = Model.init();
	
    newBall.model = model;
    newBall._x = (model.walls.right - model.walls.left - 2*model.ballRadius)*math.random();
    newBall._y = (model.walls.bottom - model.walls.top - 2*model.ballRadius)*math.random();
    newBall._vx = 2*model.maxSpeed*math.random() - model.maxSpeed;
    newBall._vy = 2*model.maxSpeed*math.random() - model.maxSpeed;
    newBall._r = model.ballRadius; -- d = 52 px
    newBall._d = 2*newBall._r;
    newBall._d2 = newBall._d*newBall._d;
	
    return newBall
end

function Ball:move()
    if (not self) then
        print("I'm not an object");
        return
    end
	
    local model = self.model
	 
    self._x = self._x + self._vx;
    self._y = self._y + self._vy;
    -- walls collisons
        
    --// left
    if (self._x < model.walls.left and self._vx<0) then
        --self._vx += (self._x - walls.left)*elastity;
		    self._vx = -self._vx;
    end
    --// top
    if (self._y < model.walls.top and self._vy<0) then
        --self._vy += (self._y - walls.top)*elastity;
		    self._vy = -self._vy;
    end
    --// left
    if (self._x > model.walls.right - self._d and self._vx>0) then
        --self._vx += (self._x - walls.right + self._d)*elastity;
		    self._vx = -self._vx;
    end
    --// top
    if (self._y > model.walls.bottom - self._d and self._vy>0) then
		    --self._vy += (self._y - walls.bottom + self._d)*elastity;
        self._vy = -self._vy;
    end
end

-- b is a Ball object
function Ball:doCollide(b) 
    if (not self) then
        print("I'm not an object");
        return false
    end
	
    --// calculate some vectors
    local dx = self._x - b._x;
    local dy = self._y - b._y;
    local dvx = self._vx - b._vx;
    local dvy = self._vy - b._vy;
    local distance2 = dx*dx + dy*dy;
        
    if (math.abs(dx) > self._d or math.abs(dy) > self._d) then
        return false;
    end
    if (distance2 > self._d2) then
        return false;
    end
        
    --// make absolutely elastic collision
    local mag = dvx*dx + dvy*dy;
        
    --// test that balls move towards each other
    if (mag > 0) then
        return false;
    end
	
    mag = mag / distance2;
        
    local delta_vx = dx*mag;
    local delta_vy = dy*mag;
            
    self._vx = self._vx - delta_vx;
    self._vy = self._vy - delta_vy;
           
    b._vx = b._vx + delta_vx;
    b._vy = b._vy + delta_vy;
            
    return true;
end
    
--[[
REFERENCE Java Source: http://bubblemark.com/

public class Ball {
    private Model model = new Model();
    protected double _x = 0;
    protected double _y = 0;
    protected double _vx = 0;
    protected double _vy = 0;
    protected double _r = 0;
    protected double _d = 0;
    protected double _d2 = 0;
    
    public Ball() {
        //default provisioning
        // default provisioning
        this._x = (model.walls.right - model.walls.left - 2*model.ballRadius)*Math.random();
        this._y = (model.walls.bottom - model.walls.top - 2*model.ballRadius)*Math.random();
        this._vx = 2*model.maxSpeed*Math.random() - model.maxSpeed;
        this._vy = 2*model.maxSpeed*Math.random() - model.maxSpeed;
        this._r = model.ballRadius; // d = 52 px
        this._d = 2*this._r;
        this._d2 = this._d*this._d;
    }
    
    public void move() {
        this._x += this._vx;
        this._y += this._vy;
        // walls collisons
        
        // left
        if (this._x < model.walls.left && this._vx<0) {
            //this._vx += (this._x - walls.left)*elastity;
            this._vx = -this._vx;
        }
        // top
        if (this._y < model.walls.top && this._vy<0) {
            //this._vy += (this._y - walls.top)*elastity;
            this._vy = -this._vy;
        }
        // left
        if (this._x > model.walls.right - this._d && this._vx>0) {
            //this._vx += (this._x - walls.right + this._d)*elastity;
            this._vx = -this._vx;
        }
        // top
        if (this._y > model.walls.bottom - this._d && this._vy>0) {
            //this._vy += (this._y - walls.bottom + this._d)*elastity;
            this._vy = -this._vy;
        }
    }
    
    public boolean doCollide(Ball b) {
        // calculate some vectors
        double dx = this._x - b._x;
        double dy = this._y - b._y;
        double dvx = this._vx - b._vx;
        double dvy = this._vy - b._vy;
        double distance2 = dx*dx + dy*dy;
        
        if (Math.abs(dx) > this._d || Math.abs(dy) > this._d)
            return false;
        if (distance2 > this._d2)
            return false;
        
        // make absolutely elastic collision
        double mag = dvx*dx + dvy*dy;
        
        // test that balls move towards each other
        if (mag > 0)
            return false;
        
        mag /= distance2;
        
        double delta_vx = dx*mag;
        double delta_vy = dy*mag;
        
        this._vx -= delta_vx;
        this._vy -= delta_vy;
        
        b._vx += delta_vx;
        b._vy += delta_vy;
        
        return true;
    }    
}
]]