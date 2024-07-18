//
// Simple passthrough fragment shader with toon shading and alpha cutoff
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vLightDir;
varying vec3 v_vCardCol;

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
    
    // Primo render target: colore toon
    gl_FragData[0] = vec4(toonColor, 1.0);
    
    // Secondo render target: colore della carta
    gl_FragData[1] = vec4(v_vCardCol.xyz, 1.0);
}
