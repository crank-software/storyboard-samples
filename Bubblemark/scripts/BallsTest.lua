--[[
Copyright 2016, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
]]--

module("BallsTest", package.seeall)

require("Ball")

function BallsTest:init(numBalls)
    local newBT = {}
    setmetatable(newBT, self)
    self.__index = self
	
    newBT._N = numBalls;
    newBT._balls = {};
    newBT._isRunning = false;

    newBT._F = 0;  --// frames counter for FPS
    newBT._lastF = 0;
    newBT._lastTime = 0;
	
    return newBT;
end

-- Ball test start with number of balls
function BallsTest:startN(N) 
    self._N = N;
    self.start();
end

function BallsTest:start() 
    if (self._isRunning) then
      return;
    end
	
    self._isRunning = true;
        
    self._F = 0;  --// frames counter for FPS
    self._lastF = 0;
    self._lastTime = gre.mstime();
        
    --// create all our balls
    local i
    for i = 0,self._N-1,1 do
        self._balls[i] = Ball:init()
    end

	-- Handled in application        
	--self._frameTimer = new Timer(5, moveBalls);
	--self._fpsTimer = new Timer(3000, showFps);        
	--self._frameTimer.start();
	--self._fpsTimer.start();
end

function BallsTest:stop() 
    if (not self._isRunning) then
      return;
    end
    self._isRunning = false;
    --self._frameTimer.stop();
    --self._fpsTimer.stop();

    self._balls = {}        
    --for (int i=1; i<self._N; i++) {
        --self._balls.get(i).remove();
    --}
    --self._balls.clear();
end

function BallsTest:moveBalls() 
    if (not self) then
        print("Missing object");
        return
    end

    if (not self._isRunning) then
        print("Not running");
        return;
    end
	
    self._F = self._F + 1;

    --// move balls
    local i
    for i=0,self._N-1,1 do
        self._balls[i]:move();
    end

    --// process collisions
    for i=0,self._N-1,1 do
        local j
        for j=i+1,self._N-1,1 do
            self._balls[i]:doCollide(self._balls[j]);
        end
    end
	
    -- Visually update, was part of Ball object
    local prefix = "MainLayer.Ball" 
    local stem
    local data = {}
    for i=0,self._N-1,1 do
        stem = prefix .. tostring(i)
        --print(stem .. " --> " .. tostring(self._balls[i]._x) .. "," .. tostring(self._balls[i]._y)) 
        data[stem .. ".grd_x"] = self._balls[i]._x
        data[stem .. ".grd_y"] = self._balls[i]._y
    end
    gre.set_data(data)	
end

function BallsTest:showFPS() 
    if (self._F - self._lastF < 10) then
        return;
    end
	
    local currTime = gre.mstime();
    local delta_t = (currTime - self._lastTime) / 1000;
    local fps = ((self._F - self._lastF)/delta_t);
                
    self._lastF = self._F;
    self._lastTime = currTime;

    -- Set the data variable   
    local data = {}
    data["fpsText"] = "FPS: " .. tostring(math.floor(fps))
    gre.set_data(data)             
end

--[[
REFERENCE Java Source: http://bubblemark.com/

/*
 * BallsTest.java
 *
 * License: The code is released under Creative Commons Attribution 2.5 License
 * (http://creativecommons.org/licenses/by/2.5/)
 */

package javaballs;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;
import javax.swing.Timer;

/**
 *
 * @author rbair
 */
public class BallsTest {
    protected double _N;
    protected List<JavaBall> _ballsO;
    protected boolean _isRunning;
    protected JXImage _root_ball;
    protected double _F = 0;
    protected double _lastF = 0;
    protected double _lastTime;
    
    private Timer _frameTimer;
    private Timer _fpsTimer;
    
    public ShowFpsCallback _showFPS;
    
    public BallsTest(JXImage root_ball, int N) {
        this._root_ball = root_ball;
        this._N = N; // number of objects
        this._ballsO = new ArrayList<JavaBall>();
        this._isRunning = false;
    }
    
    public void startN(int N) {
        this._N = N;
        this.start();
    }
    
    public void start() {
        if (this._isRunning) return;
        this._isRunning = true;
        
        this._F = 0;  // frames counter for FPS
        this._lastF = 0;
        this._lastTime = System.currentTimeMillis();
        
        ActionListener moveBalls = new ActionListener() {
            public void actionPerformed(ActionEvent ae) {
                if (_N > _ballsO.size())
                    return;
                _F++;
                // move balls
                for (int i=0; i<_N; i++) {
                    _ballsO.get(i).move();
                }
                // process collisions
                for (int i=0; i<_N; i++) {
                    for (int j=i+1; j<_N; j++) {
                        _ballsO.get(i).doCollide(_ballsO.get(j));
                    }
                }
            }
        };
        
        ActionListener showFps = new ActionListener() {
            public void actionPerformed(ActionEvent ae) {
                if (_F - _lastF < 10) return;
                double currTime = System.currentTimeMillis();
                double delta_t = currTime - _lastTime;
                
                double fps = ((_F - _lastF)/delta_t) * 1000;
                
                _lastF = _F;
                _lastTime = currTime;
                
                if (_showFPS != null)
                    _showFPS.setFps(Math.round(fps));
            }
        };
        
        // create all our balls
        this._ballsO.add(new JavaBall(this._root_ball));
        
        for (int i=1; i<this._N; i++) {
            this._ballsO.add(this._ballsO.get(0).clone());
        }
        
        this._frameTimer = new Timer(5, moveBalls);
        this._fpsTimer = new Timer(3000, showFps);
        
        this._frameTimer.start();
        this._fpsTimer.start();
    }
    
    public boolean stop() {
        if (!this._isRunning) return false;
        this._isRunning = false;
        this._frameTimer.stop();
        this._fpsTimer.stop();
        
        for (int i=1; i<this._N; i++) {
            this._ballsO.get(i).remove();
        }
        this._ballsO.clear();
        return true;
    }
    
    static interface ShowFpsCallback {
        void setFps(double fps);
    }
}
]]
