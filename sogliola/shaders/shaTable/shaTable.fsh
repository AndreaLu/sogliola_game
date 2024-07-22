//
//
varying vec2 v_vTexcoord;
varying vec2 fragCoord;
varying vec4 v_vColour;
uniform float u_Time; 
uniform sampler2D t_Alpha;
uniform sampler2D t_Mask;

void main()
{

   // Create dynamic wave patterns based on time
   float wave = sin(u_Time*0.5) * 0.1;
   float shift = (u_Time*0.2) * 0.1;

   vec2 uvAlpha = v_vTexcoord + vec2(sin(fragCoord.y*3.0 + u_Time*2.0)*0.01,sin(fragCoord.x*3.0 + u_Time*2.0)*0.01);
   vec4 alpha_tex = texture2D(t_Alpha, uvAlpha);

   vec2 uv = uvAlpha + vec2(shift,wave);

   vec4 base_color = texture2D(gm_BaseTexture, fract(uv*1.5));
   vec4 base_color2 = texture2D(t_Mask, fract(uv*1.5));
   vec4 base_mask = texture2D(t_Mask, fract(v_vTexcoord*2.0)) * base_color2.x;

   gl_FragData[0] = vec4(base_color.xyz + base_mask.xyz + alpha_tex.r, 0.35 + base_mask.x + alpha_tex.r);
   gl_FragData[1] = vec4(0.0,0.0, v_vTexcoord.y < 0.5 ? 0.5 : 1.0 , 1.0);

}
