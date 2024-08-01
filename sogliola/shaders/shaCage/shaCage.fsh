//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying float vWorldX;
varying vec3 v_vLightDir;
varying vec3 v_vNormal;

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
    
    
   float alpha = (1.0-smoothstep(3.3,3.7,vWorldX));
   if( alpha == 0.0 ) discard;
   gl_FragColor = vec4(toonColor,alpha);
}
