#ifdef GL_ES
precision mediump float;
#endif

/*
Code modified from:
http://www.geeks3d.com/20091116/shader-library-2d-shockwave-post-processing-filter-glsl/
*/

uniform sampler2D sampler2d;
varying vec2 vtex;

uniform float center_x;
uniform float center_y;
uniform float time;

void main (void)
{
	vec2 center = vec2(center_x, center_y);
	vec3 shock_params = vec3(10.0, 0.8, 0.1);

	vec2 uv = vtex;
	vec2 texCoord = uv;
	
	float distance = distance(uv, center);
	if ((distance <= (time + shock_params.z)) && (distance >= (time - shock_params.z))) {
		float diff = (distance - time); 
		float powDiff = 1.0 - pow(abs(diff*shock_params.x), 
		                            shock_params.y); 
		float diffTime = diff  * powDiff; 
		vec2 diffUV = normalize(uv - center); 
		texCoord = uv + (diffUV * diffTime);
	}
	
	gl_FragColor = texture2D(sampler2d, texCoord);
}
