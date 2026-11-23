float hash(float n){return fract(sin(n*127.1)*43758.5453);}
float hash2(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash2(i),hash2(i+vec2(1,0)),f.x),mix(hash2(i+vec2(0,1)),hash2(i+vec2(1,1)),f.x),f.y);}
float fbm(vec2 p){float v=0.0,a=0.5;for(int i=0;i<4;i++){v+=a*noise(p);p=p*2.03+vec2(1.7,9.2);a*=0.5;}return v;}
float bgMask(vec4 t){return 1.0-smoothstep(0.03,0.09,max(t.r,max(t.g,t.b)));}
vec4 finish(vec4 t,vec3 c,float a){return vec4(mix(t.rgb,c*t.a,clamp(a,0.0,1.0)*bgMask(t)),t.a);}
void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=fragCoord/iResolution.xy; vec4 term=texture(iChannel0,uv); float aspect=iResolution.x/iResolution.y;
  vec2 p=vec2(uv.x*aspect,1.0-uv.y); vec3 c=vec3(0.0);
  for(float i=0.0;i<28.0;i+=1.0){
    float y=1.05-fract(iTime*(0.018+0.03*hash(i+1.0))+hash(i+2.0))*1.15;
    float x=hash(i+3.0)*aspect+0.025*sin(iTime*(0.3+0.4*hash(i+4.0))+i);
    float r=0.0012+0.0022*hash(i+5.0); float d=length(p-vec2(x,y));
    float life=smoothstep(1.05,0.8,y)*smoothstep(-0.02,0.4,y);
    float flick=0.55+0.45*sin(iTime*(1.2+1.6*hash(i+6.0))+i*3.0);
    c+=(vec3(0.38,0.035,0.012)*smoothstep(r,0.0,d)+vec3(0.07,0.003,0.002)*smoothstep(r*5.0,0.0,d))*life*flick;
  }
  fragColor=vec4(term.rgb+c*term.a*bgMask(term),term.a);
}
