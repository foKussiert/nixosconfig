float hash(float n){return fract(sin(n*127.1)*43758.5453);}
float hash2(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash2(i),hash2(i+vec2(1,0)),f.x),mix(hash2(i+vec2(0,1)),hash2(i+vec2(1,1)),f.x),f.y);}
float fbm(vec2 p){float v=0.0,a=0.5;for(int i=0;i<4;i++){v+=a*noise(p);p=p*2.03+vec2(1.7,9.2);a*=0.5;}return v;}
float bgMask(vec4 t){return 1.0-smoothstep(0.03,0.09,max(t.r,max(t.g,t.b)));}
vec4 finish(vec4 t,vec3 c,float a){return vec4(mix(t.rgb,c*t.a,clamp(a,0.0,1.0)*bgMask(t)),t.a);}
void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=fragCoord/iResolution.xy; vec4 term=texture(iChannel0,uv); float aspect=iResolution.x/iResolution.y;
  vec2 p=vec2(uv.x*aspect,1.0-uv.y); vec3 col=vec3(0.0); float a=0.0;
  for(float i=0.0;i<16.0;i+=1.0){
    float y=fract(iTime*(0.012+0.016*hash(i+1.0))+hash(i+2.0))*1.2-0.1;
    float x=hash(i+3.0)*aspect+0.035*sin(iTime*(0.18+0.2*hash(i+4.0))+i*2.0);
    float ang=iTime*(0.12+0.2*hash(i+5.0))*(hash(i+6.0)>0.5?1.0:-1.0)+i;
    vec2 q=p-vec2(x,y); float c=cos(ang),s=sin(ang); q=mat2(c,-s,s,c)*q;
    float L=0.017+0.018*hash(i+7.0); q.y+=q.x*q.x*(10.0+14.0*hash(i+8.0));
    float u=q.x/L; if(abs(u)>1.0) continue;
    float W=L*0.24*(1.0-0.45*u)*smoothstep(1.0,0.35,abs(u));
    float m=smoothstep(W+0.0012,W-0.0012,abs(q.y)); float vein=smoothstep(W*0.22,0.0,abs(q.y));
    vec3 pc=mix(vec3(0.16,0.002,0.01),vec3(0.055,0.0008,0.004),(u+1.0)*0.5)+vec3(0.045,0.002,0.004)*vein;
    if(m>a){a=m;col=pc;}
  }
  fragColor=finish(term,col,a*0.82);
}
