#if 0
#define extern uniform
#define Image Sampler2D
#endif

extern Image feedback;
extern vec2 r;
extern float t;

// Tuneable parameters
extern float dist_scale = 1.;
extern float dist_add = .1;
extern float sat_to_hue = .1;
extern float val_to_hue = .1;
extern float sat_to_sat = 0.;
extern float val_to_sat = 0.;
extern float sat_to_val = 0.;
extern float hue_to_val = 0.;
extern float blowup = 0.00;
extern float t_rotate = 10.;
extern float c_rotate = 0.;
extern float feed_param = 1.;
extern float orig_param = 1.;

vec4 rgbToHsv( vec4 rgba ) {
	vec4 return_value; 
	float v, x, f, i; 
	float R = rgba.r, G = rgba.g, B = rgba.b; 
	x = min(R, min( G, B ) ); 
	v = max(R, max( G, B ) ); 
	if(v == x) 
		return_value = vec4(0, 0, v, rgba.a); 
	else { 
		f = (R == x) ? G - B : ((G == x) ? B - R : R - G); 
		i = (R == x) ? 3.0 : ((G == x) ? 5.0 : 1.0); 
		return_value = vec4(i - f /(v - x), (v - x)/v, v, rgba.a); 
	} 
	return return_value; 
}

vec4 hsvToRgb( vec4 hsva ) { 
	vec4 return_value; 
	float h = hsva.x, s = hsva.y, v = hsva.z, m, n, f; 
	float i;   

	if( h == 0.0 ) 
		return_value = vec4(v, v, v, hsva.a); 
	else { 
		i = floor(h/6.28*6.0); 
		f = h - i; 
		float t = i / 2.0; 
		if( t - floor( t ) <  0.1 ) 
			f = 1.0 - f; // if i is even (odd?)
		m = v * (1.0 - s); 
		n = v * (1.0 - s * f); 
		if( i == 6.0 || i == 0.0 ) return_value = vec4(v, n, m, hsva.a); 
		else if( i == 1.0 ) return_value = vec4(n, v, m, hsva.a); 
		else if( i == 2.0 ) return_value = vec4(m, v, n, hsva.a); 
		else if( i == 3.0 ) return_value = vec4(m, n, v, hsva.a); 
		else if( i == 4.0 ) return_value = vec4(n, m, v, hsva.a); 
		else if( i == 5.0 ) return_value = vec4(v, m, n, hsva.a); 
		// should never happen 
		else return_value = vec4( 0, 0, 0, 1 ); 
	}
	return return_value; 
}


float pn(vec3 p) {
	p *= 1.5;
	vec3 i = floor(p);
	vec4 a = dot(i, vec3(1,57,21)) + vec4(0,57,21,78);
	vec3 f = cos((p-i)*acos(-1.))*(-.5) + .5;
	a = mix(sin(cos(a)*a), sin(cos(1+a)*(1+a)), f.x);
	a.xy = mix(a.xz, a.yw, f.y);
	return mix(a.x, a.y, f.z);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
	vec2 coords = texture_coords;
	vec4 c= texture2D(texture,texture_coords);
	c.a=1;

	coords=coords-.5;
	coords.xy = cos(c_rotate)*coords.xy + sin(c_rotate)*vec2(-1,1)*coords.yx;
	coords=coords+.5;

	// Look up value
	vec4 a=texture2D(feedback,coords);

	// transform to hsv
	a = rgbToHsv(a);

	// Blow up
	coords=(coords-.5)*(1.-blowup)+.5;

	// Look up a new one
	coords.x -= sin(a.x+t_rotate*t) / r.x * dist_scale * (a.z+dist_add);
	coords.y += cos(a.x+t_rotate*t) / r.y * dist_scale * (a.z+dist_add);
	vec4 b = texture2D(feedback,coords);
	// Also hsv
	b = rgbToHsv(b);
	b.x += sat_to_hue*a.y - val_to_hue*a.z; // Rotate color
	b.y += sat_to_sat*a.y - val_to_sat*a.z;
	b.z += sat_to_val*a.y - hue_to_val*a.x;
	b.a = 1;
	b = hsvToRgb(b);

	return orig_param*c+feed_param*b;
}
