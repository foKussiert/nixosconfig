float hash(float n){return fract(sin(n*127.1)*43758.5453);}
float hash2(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash2(i),hash2(i+vec2(1,0)),f.x),mix(hash2(i+vec2(0,1)),hash2(i+vec2(1,1)),f.x),f.y);}
float fbm(vec2 p){float v=0.0,a=0.5;for(int i=0;i<4;i++){v+=a*noise(p);p=p*2.03+vec2(1.7,9.2);a*=0.5;}return v;}
float bgMask(vec4 t){return 1.0-smoothstep(0.03,0.09,max(t.r,max(t.g,t.b)));}
vec4 finish(vec4 t,vec3 c,float a){return vec4(mix(t.rgb,c*t.a,clamp(a,0.0,1.0)*bgMask(t)),t.a);}
void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=fragCoord/iResolution.xy; vec4 term=texture(iChannel0,uv); float aspect=iResolution.x/iResolution.y;
  vec2 p=vec2(uv.x*aspect,1.0-uv.y); float t=iTime*0.018;
  vec2 w=vec2(fbm(p*1.6+t),fbm(p*1.6-t+4.0)); float v=fbm(p*1.35+w*1.4+vec2(0.0,t*0.6));
  float ink=smoothstep(0.50,0.76,v);
  fragColor=finish(term,mix(vec3(0.012,0.0004,0.001),vec3(0.085,0.0015,0.006),ink),ink*0.75);
}
