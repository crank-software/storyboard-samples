/*
Copyright 2018, Crank Software Inc.
All Rights Reserved.
For more information email info@cranksoftware.com
** FOR DEMO PURPOSES ONLY **
*/

attribute vec4 myVertex;
attribute vec4 myUV;

varying vec2 vpos;
varying vec2 vtex;

uniform mat4 projMatrix;
uniform mat4 mvMatrix;

void main(void)
{
    gl_Position = projMatrix * mvMatrix * myVertex;
    vpos = gl_Position.xy;
    vtex = myUV.st;
}

