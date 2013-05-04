#extension GL_EXT_gpu_shader4 : enable

extern vec2 r;
extern float t;

extern float vignette_offset = 1.4*.5;
extern float vignette_exponent = 6.*.5;
extern float noise_amount = .7;
extern float saturation_value = .3;
extern float gamma = .5;
extern float gamma_pulse = .1;

int LFSR_Rand_Gen(in int n) {
   n = (n << 13) ^ n;
   return (n * (n*n*15731+789221) + 1376312589) & 0x7fffffff;
}

float noise3f(in vec3 p) {
   ivec3 ip = ivec3(floor(p));
   int n = ip.x + ip.y*57 + ip.z*113;
   return float(LFSR_Rand_Gen(n))/1073741824. - .5;
}


vec4 saturation(vec4 color, float amount) {
  float luma = 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
  return vec4(luma) + (color - vec4(luma))*amount;
}

float vignette(vec2 sc, float offset, float exponent) {
   sc -= .5;
   sc *= 2.;
   sc *= offset;
   sc = abs(sc);

   return 1.-pow(sc.x, exponent)-pow(sc.y,exponent);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
	vec4 o0;
  vec2 pos = texture_coords;
  vec4 col = texture2D(texture,pos);

  col = vignette(pos,vignette_offset, vignette_exponent)*col;
  col = saturation(col, 5*pow(saturation_value,1.7));

  o0 = pow(col, vec4(3-3.9*gamma-gamma_pulse*exp(-fract(t/6.*8.+.5)))) + .06*noise_amount*noise_amount*noise3f(7129.5*vec3(pos,t));

	return o0;
}
