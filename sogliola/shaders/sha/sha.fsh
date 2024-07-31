// GLSL
// Simple passthrough fragment shader with toon shading and alpha cutoff
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vLightDir;
uniform float uSel;
uniform float u_Time; 

float smooth(in float e0,in float e1,in float v) {
   float _t = clamp( (v - e0) / (e1 - e0), 0.0, 1.0);
   return( _t * _t * (3.0 - 2.0 * _t));
}

void main()
{
    // Ottieni il colore di base dalla texture e dal colore del vertice
    vec4 baseColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    
    // Imposta una soglia per il cutoff dell'alpha
    float alphaThreshold = 0.5;
    
    // Se l'alpha è inferiore alla soglia, scarta il pixel
    if (baseColor.a < alphaThreshold) {
        discard;
    }
    
    // Calcola il coefficiente di illuminazione
    float coeff = abs(dot(v_vLightDir, v_vNormal));
    
    // Quantizza il coefficiente per ottenere l'effetto toon
    if (coeff > 0.8) {
        coeff = 1.0;  // Luce piena
    } else if (coeff > 0.5) {
        coeff = 0.8;  // Luce alta
    } else if (coeff > 0.3) {
        coeff = 0.7;  // Luce media
    } else {
        coeff = 0.6;  // Luce minima
    }
    
    // Colore base moltiplicato per il coefficiente quantizzato
    vec3 toonColor = coeff * baseColor.rgb;
    
    // Colore di selezione
    vec2 uv = v_vTexcoord;
    float aa = uSel;//smooth(0.0,0.1,uv.x)*uSel;
    aa *= 0.5*(sin(u_Time*6.0)+1.0)*0.2;
    // Primo render target: colore toon
    //gl_FragColor= vec4(toonColor, 1.0 );
    gl_FragData[0] = vec4(toonColor + vec3(aa), 1.0 );
    gl_FragData[1] = vec4(0.0,0.0,0.0,0.0);
}
