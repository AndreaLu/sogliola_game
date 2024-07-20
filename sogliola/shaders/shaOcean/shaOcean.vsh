//
// Enhanced waving vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec2 fragCoord;

uniform float u_Time;                        // Uniform for time

void main()
{
    // Parameters for the first wave
    float waveFrequency1 = 5.0;              // Frequency of the first wave
    float waveAmplitude1 = 0.3;              // Amplitude of the first wave
    float waveSpeed1 = 1.0;                  // Speed of the first wave

    // Parameters for the second wave
    float waveFrequency2 = 3.0;              // Frequency of the second wave
    float waveAmplitude2 = 0.2;              // Amplitude of the second wave
    float waveSpeed2 = 0.8;                  // Speed of the second wave

    // Calculate the wave effects
    float wave1 = sin(in_Position.x * waveFrequency1 + u_Time * waveSpeed1) * waveAmplitude1;
    float wave2 = cos(in_Position.z * waveFrequency2 + u_Time * waveSpeed2) * waveAmplitude2;

    // Combine the waves and apply to the y-coordinate
    float combinedWave = wave1 + wave2;

    // Optional: Add slight displacement to the x and z coordinates for more dynamic effect
    float displacementZ = sin(in_Position.x * waveFrequency1 + u_Time * waveSpeed2) * waveAmplitude2 * 0.3;

    vec4 object_space_pos = vec4(in_Position.x, in_Position.y + combinedWave, in_Position.z + displacementZ, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
	fragCoord = in_Position.xy;
}
