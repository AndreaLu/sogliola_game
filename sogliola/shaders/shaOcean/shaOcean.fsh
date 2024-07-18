//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;

void main()
{
	vec2 repeatedTexcoord = fract(v_vTexcoord);
	vec4 baseColor = v_vColour * texture2D( gm_BaseTexture, repeatedTexcoord );
	
	float luminance = dot(baseColor.rgb, vec3(0.299, 0.587, 0.114));
	//float threshold = 0.9; // Adjust this value as needed
	//vec4 outputColor = (luminance > threshold) ? vec4(0.2) : vec4(0.0);
	vec4 outputColor = vec4(luminance*luminance/3.0);
	
    gl_FragColor = vec4(baseColor.rgb, 0.6) + outputColor;
	
	
}
