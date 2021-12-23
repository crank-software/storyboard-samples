/*
Copyright 2018, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
*/

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D sampler2d;
varying vec2 vtex;
varying vec2 vpos;

uniform float grd_c_startR;
uniform float grd_c_startG;
uniform float grd_c_startB;
uniform float grd_c_endR;
uniform float grd_c_endG;
uniform float grd_c_endB;
uniform float grd_c_lineWidth;

uniform float grd_c_startAngle;
uniform float grd_c_endAngle;
uniform float grd_c_rotation;
uniform float grd_c_radius;

uniform float grd_c_width;
uniform float grd_c_height;

const float epsilon = 0.01;
const float TWO_PI_CONST = 6.28318531;

void main (void)
{
	vec2 xy = vtex.xy * 2.0 - 1.0;

	vec2 center = vec2(grd_c_width/2., grd_c_height/2.);

	vec2 position = gl_FragCoord.xy - center;
	float len = length(xy);
	
	float outerRadius = (grd_c_radius-1.)/(grd_c_width/2.);
	float innerRadius = clamp(outerRadius - grd_c_lineWidth/grd_c_radius, 0., outerRadius);
	float innerE = innerRadius + epsilon;
	float outerE = outerRadius - epsilon;
	
	float currentAngle = atan(xy.y, xy.x) - radians(grd_c_rotation);
    currentAngle = mod(currentAngle, TWO_PI_CONST);
	
	float percentage = (radians(grd_c_startAngle) + currentAngle) / radians(grd_c_endAngle); 
	
	float r = (grd_c_endR - grd_c_startR);
	float g = (grd_c_endG - grd_c_startG);
	float b = (grd_c_endB - grd_c_startB);
	vec4 col = vec4(r, g, b, 0.) * percentage + vec4(grd_c_startR, grd_c_startG, grd_c_startB, 0.);
	
	float a = 0.;
	if(percentage >= 0. && percentage <= 1.) {
		a = 1.;
	  	if(len >= innerRadius && len <= innerE) {
			a = 1. - (innerE-len)/epsilon;
		} else if(len > outerE && len <= outerRadius) {
			a = (outerRadius-len)/epsilon;
		}
	}
	
	if(len < innerRadius || len > outerRadius) { 
		gl_FragColor = vec4(vec3(0),0.);
	} else {	
		gl_FragColor = vec4(col.rgb, 1.*a);
	}
}
