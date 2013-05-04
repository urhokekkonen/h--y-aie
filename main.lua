-- Initialization
function love.load()
   local f = love.graphics.newFont(30)
   love.graphics.setFont(f)

	 shader = love.graphics.newPixelEffect[[

		extern Image feedback;
		extern vec2 r;
		extern float t;

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
			//coords.x += .01*pn(vec3(10*coords,sin(t)));
			//coords.y += .01*pn(vec3(cos(t),12*coords));
			vec4 c= texture2D(texture,texture_coords);
			// Look up value
			vec4 a=texture2D(feedback,coords);

			// transform to hsv
      a = rgbToHsv(a);

			coords=(coords-.5)*.999+.5;
			// Look up a new one
			coords.x -= sin(a.x+t) * .001 * (a.z+.1);
			coords.y += cos(a.x+t) * .001 * (a.z+.1);
			vec4 b = texture2D(feedback,coords);
			// Also hsv
			b = rgbToHsv(b);
			b.x += .1*a.y - .1*a.z; // Rotate color
			b.a=1+.001*t;
			b = hsvToRgb(b);

			return c+b;
		}
		]]

	bgcanvas = love.graphics.newCanvas();
	feedback_canvas = love.graphics.newCanvas();
	feedback_canvas2 = love.graphics.newCanvas();
	time_0 = love.timer.getMicroTime();
end

-- Exit on esc.
function love.keypressed(key, unicode)
	if key == 'escape' then
		love.event.quit()
	end
end

-- Main draw code
function love.draw()
	love.graphics.setPixelEffect()
	bgcanvas:clear();
	
	-- Draw input stuff
	love.graphics.setCanvas(bgcanvas);
	love.graphics.setColor(255,127,0,255);
	love.graphics.print("Hello World", 
			200+200*math.sin(love.timer.getMicroTime()-time_0), 
			150+150*math.cos(love.timer.getMicroTime()-time_0))

	-- Draw the feedback effect
	love.graphics.setColor(255,255,255,255);
	love.graphics.setCanvas(feedback_canvas);
	love.graphics.setPixelEffect(shader);
	shader:send("feedback", feedback_canvas);
	shader:send("t",love.timer.getMicroTime()-time_0);
	love.graphics.draw(bgcanvas,0,0,0,1,1);
	

	-- Use the shader on it
	love.graphics.setCanvas();
	love.graphics.setPixelEffect();
	love.graphics.draw(feedback_canvas,0,0,0,1,1);
	
end
