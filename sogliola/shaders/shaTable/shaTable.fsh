//
//
varying vec2 v_vTexcoord;
varying vec2 fragCoord;
varying vec4 v_vColour;
uniform float u_Time; 
uniform sampler2D t_Alpha;
uniform sampler2D t_Mask;
uniform float plAqSel; // 1.0 shows highlight on player aquarium
uniform float opAqSel; // 1.0 shows highlight on opponent aquarium


//float smooth(in float e0,in float e1,in float v,out float val) {
//_t * _t * (3.0 - 2.0 * _t);
float smooth(in float e0,in float e1,in float v) {
   float _t = clamp( (v - e0) / (e1 - e0), 0.0, 1.0);
   return( _t * _t * (3.0 - 2.0 * _t));
}

void main()
{

   // Create dynamic wave patterns based on time
   float wave = sin(u_Time*0.5) * 0.1;
   float shift = (u_Time*0.2) * 0.1;

   vec2 u_v = v_vTexcoord;
   vec2 uvAlpha = v_vTexcoord + vec2(sin(fragCoord.y*3.0 + u_Time*2.0)*0.01,sin(fragCoord.x*3.0 + u_Time*2.0)*0.01);
   vec4 alpha_tex = texture2D(t_Alpha, uvAlpha);

   vec2 uv = uvAlpha + vec2(shift,wave);

   vec4 base_color = texture2D(gm_BaseTexture, fract(uv*1.5));
   vec4 base_color2 = texture2D(t_Mask, fract(uv*1.5));
   vec4 base_mask = texture2D(t_Mask, fract(v_vTexcoord*2.0)) * base_color2.x;
   float aa = 2.0-smooth(0.0,0.1,u_v.x)+smooth(0.9,1.0,u_v.x);
   aa = aa-smooth(0.0,0.2,u_v.y)+smooth(0.3,0.5,u_v.y)+smooth(0.8,1.0,u_v.y)-smooth(0.5,0.7,u_v.y);
   aa *= 0.5*(sin(u_Time*6.0)+1.0);
   aa *= smooth(0.5,0.5,u_v.y)*plAqSel + (1.0-smooth(0.5,0.5,u_v.y))*opAqSel;

   gl_FragData[0] = vec4(
      base_color.xyz + base_mask.xyz + alpha_tex.r, 
      0.35 + base_mask.x + alpha_tex.r + aa
   );
   gl_FragData[1] = vec4(0.0,0.0, v_vTexcoord.y < 0.5 ? 0.5 : 1.0 , 1.0);

}
