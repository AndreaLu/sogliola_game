//
// Simple passthrough fragment shader with toon shading and alpha cutoff
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vLightDir;
varying vec3 v_vCardCol;
varying float v_vAquarium;

void main()
{

    if( v_vAquarium < 0.5 ) {
       // Primo render target: colore toon
       gl_FragData[0] = vec4(0.0,0.0,0.0, 1.0);
    
       // Secondo render target: colore della carta
       gl_FragData[1] = vec4(v_vCardCol.xyz, 1.0);
    } else {
              // Primo render target: colore toon
       gl_FragData[0] = vec4(0.0,0.0,0.0, 1.0);
    
       // Secondo render target: colore della carta
       gl_FragData[1] = vec4(0.0,0.0, v_vTexcoord.y < 0.5 ? 0.5 : 1.0 , 1.0);
    }
}