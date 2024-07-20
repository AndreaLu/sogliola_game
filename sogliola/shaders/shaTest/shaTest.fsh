//
// Improved distortion fragment shader without distortion map
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform float u_Time; 
uniform sampler2D t_Alpha;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

void main()
{

    // Create dynamic wave patterns based on time
    float wave = cos(u_Time*0.3) * 0.1;

    // Generate noise-based distortion
    vec2 noise_uv = v_vTexcoord * 6.0; // Scale to control noise frequency
    float noise_value = noise(noise_uv + vec2(u_Time * 0.5)); // Animate noise over time
    vec4 alpha_tex = texture2D(t_Alpha, v_vTexcoord + vec2(-0.01 + noise_value * 0.02, -0.03 + noise_value * 0.06));

    // Combine wave and noise for more complex distortion
    vec2 uv = v_vTexcoord + vec2(wave,0) + vec2(noise_value * 0.01, noise_value * 0.1);

    vec4 base_color = texture2D(gm_BaseTexture, fract(uv));
    gl_FragColor = vec4(base_color.xyz + alpha_tex.r, alpha_tex.r*1.0 + base_color.x*0.4);
}
