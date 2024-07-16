//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_Time;                        // Uniform for time

void main()
{
    // Apply a sine wave to the y-coordinate based on the x-position and time
    float waveFrequency = 5.0;               // Adjust for more or less waves
    float waveAmplitude = 0.2;               // Adjust for wave height
    float waveSpeed = 2.0;                   // Adjust for wave speed

    float wave = sin(in_Position.x * waveFrequency + u_Time * waveSpeed) * waveAmplitude;
	float waveX = cos(in_Position.y * waveFrequency + u_Time * waveSpeed) * waveAmplitude;


    vec4 object_space_pos = vec4(in_Position.x, in_Position.y+waveX, in_Position.z + wave, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    v_vTexcoord = in_TextureCoord;
    v_vColour = in_Colour;
}
