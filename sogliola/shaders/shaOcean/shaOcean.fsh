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
    gl_FragColor = vec4(baseColor.rgb, 0.8);
}
