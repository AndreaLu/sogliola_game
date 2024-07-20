//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
uniform float v_Time; 
uniform sampler2D t_Mask;
varying vec2 fragCoord;

void main()
{
	float wave = sin(v_Time*0.6) * 0.2;
	float shift = (v_Time*0.3) * 0.3;
	
	vec2 uvAlpha = v_vTexcoord + vec2(sin(fragCoord.y*5.0 + v_Time*2.0)*0.01,sin(fragCoord.x*5.0 + v_Time*2.0)*0.01);
	
	vec2 uv = uvAlpha + vec2(shift,wave);
	
	vec4 baseColor = v_vColour * texture2D( gm_BaseTexture,  fract(uv*0.7) );
	vec4 base_color2 = texture2D(t_Mask, fract(uv*0.7));
	vec4 base_mask = texture2D(t_Mask, fract(v_vTexcoord*0.8)) * base_color2.x;
	
    gl_FragColor = vec4(baseColor.xyz + base_mask.xyz, 0.8 + base_mask.x);
	
	
}
