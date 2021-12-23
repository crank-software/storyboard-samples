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

