//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform float u_Time;

void main()
{
	// Repeating the texture coordinates
    vec2 uv = mod(v_vTexcoord * 1.0, 1.0); // Adjust the 4.0 to control the repetition frequency
     // Adding wave effect
    
	float wave1 = sin((uv.x + u_Time) * 1.0) * 0.05; // Wave 1
    float wave2 = sin((uv.x * 2.0 + u_Time * 0.5) * 3.0) * 0.03; // Wave 2 with different frequency and amplitude
    
	uv.y += wave1 + wave2;
	uv.x += wave1 - wave2;
	vec4 baseColor = texture2D(gm_BaseTexture, fract(uv));
	float luminance = dot(baseColor.rgb, vec3(0.299, 0.587, 0.114));
	float alpha = 0.5;
	if (luminance > 0.7)
	{
		alpha = 0.8;
	}
	if (luminance > 0.9)
	{
		alpha = 0.9;
	}
	gl_FragColor = v_vColour * vec4(baseColor.xyz, alpha);
}
