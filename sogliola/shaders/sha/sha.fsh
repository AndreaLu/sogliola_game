//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vLightDir;
varying vec3 v_vCardCol;

void main()
{
	vec4 baseColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
    float coeff = abs( dot(v_vLightDir,v_vNormal));
    gl_FragData[0] = vec4(coeff*baseColor.rgb,1.0);
    gl_FragData[1] = vec4(v_vCardCol.xyz,1.0);
}
