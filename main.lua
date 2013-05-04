-- Initialization
function love.load()
	-- Set graphics mode (change false to true for fullscreen)
  wantedwidth = 1280
  wantedheight = 720
	love.graphics.setMode(wantedwidth,wantedheight, false,0);
	-- Hide the mouse cursor
--	love.mouse.setVisible(false);

	f = love.graphics.newFont("EPIDEMIA.otf", 50)
	titlefont = love.graphics.newFont("EPIDEMIA.otf", 350)
	love.graphics.setFont(f)
	--love.graphics.setNewFont("EPIDEMIA.otf", 50)
  
  bier = love.graphics.newImage( 'Rochfort8.JPG' )
  r8w = 3648
  r8w2 = r8w/2
  r8h = 2736
  r8h2 = r8h/2
  
  inttime = 0
  
  quad = love.graphics.newQuad( 2600, 1541 , 100, 100, r8w, r8h )  
	resolution = {wantedwidth, wantedheight};
  halftw = resolution[1]/2
  halfth = resolution[2]/2
 
	-- Initialize shaders
	feedback_shader = love.graphics.newPixelEffect(love.filesystem.read("feedback.glsl"));

	postproc_shader = love.graphics.newPixelEffect(love.filesystem.read("postproc.glsl"));

  bgcanvas = love.graphics.newCanvas();
	feedback_canvas = love.graphics.newCanvas();
	feedback_canvas2 = love.graphics.newCanvas();

	-- Load audio
	music = love.audio.newSource("music.ogg","stream");
	--music:play();

	-- Set reference time
	time_0 = love.timer.getMicroTime();

	-- Font and scrolltable
	font_table = {

		{
			x = 600,
			y = 400,
			text = "",
			font = f,
			r=255, g=255, b=255,
		},
		{
			x = 600,
			y = 400,
			text = "Demoklubi Breakfast Club",
			font = f,
			r=255, g=255, b=255,
		},
		{
			x = 600,
			y = 450,
			text = "Presents",
			font = f,
			r=255, g=255, b=255,
		},
		{
			x = 600,
			y = 500,
			text = "for the wedding democompo",
			font = f,
			r=255, g=255, b=255,
		},
		{
			x = 600,
			y = 550,
			text = "",
			font = f,
			r=0, g=0, b=0,
		},
		{
			x = 400,
			y = 350,
			text = "",
			font = f,
			r=0, g=0, b=0,
		},
		{
			x = 400,
			y = 300,
			text = "Hääyöaie",
			font = titlefont,
			r=127, g=127, b=127,
		},
		{
			x = 400,
			y = 350,
			text = "",
			font = f,
			r=0, g=0, b=0,
		},


	}

end

current_param = 1;

-- Exit on esc, choose new param on space
function love.keypressed(key, unicode)
	if key == 'escape' then
		love.event.quit()
	elseif key == ' ' then
		current_param = current_param +1;
	elseif key == 'b' then
		current_param = current_param -1;
	end
end
-- Lame Shit! W007.

function lameshit1(time)
  local bierx = r8w/2
  local biery = r8h/2
  local ct = math.cos(time)
  local cs = math.sin(time)
  local ctan = math.tan(time)
--  local xx = halftw + halftw * math.cos(time)
--  local yy = halfth + halfth * math.sin(math.tan(time))
  quad:setViewport( bierx + bierx * ct*cs , biery + biery * cs*ctan , resolution[1],resolution[2]  )
  love.graphics.drawq( bier, quad, 1, 1, 0 )
end

function lameshit2(time)
  local pct = time/33
  local dw = pct * r8w
  local dh = pct * r8h
  local ox = (wantedwidth/2) - (dw/2)
  local oy = (wantedheight/2) - (dh/2)
  
  quad:setViewport(0,0,r8w,r8h)
  love.graphics.drawq(bier,quad,ox,oy,0, pct, pct)
end

ls3x = 1
ls3y = 1

function lameshit3(time,increment)
  local st = r8w2 + math.sin(math.sin(time)) * (r8w2-128)
  local ct = r8h2 + (math.cos(time)*math.sin(time)) * (r8h2-128)
  
  quad:setViewport(st,ct,128,128)
  love.graphics.drawq(bier,quad,ls3x,ls3y)
  if increment then
    ls3x = ls3x + 128
    if ls3x > 11*128 then
      ls3x = 1
      ls3y = ls3y+128
      if ls3y > 6*128 then
        ls3x = 1
        ls3y =1
      end
    end
  end
end

-- Set of feedback shader parameters
feedback_parameters = {
	{
		dist_scale = 0.1,
		dist_add = .0,
		sat_to_hue = .0,
		val_to_hue = .0,
		sat_to_sat = .01;
		val_to_sat = .01;
		sat_to_val = -.001;
		hue_to_val = .0;
		blowup = 0.02,
		t_rotate = 1.,
		c_rotate = -.001,
		feed_param = 1.,
		orig_param = 0.1,
	},
	{ -- solarized stuff
		dist_scale = 1.,
		dist_add = .1,
		sat_to_hue = .1,
		val_to_hue = .1,
		blowup = 0.002,
		t_rotate = 10.,
	},
	--{ -- boring blurriness
	--	dist_scale = .5,
	--	dist_add = .1,
	--	sat_to_hue = 0.05,
	--	val_to_hue = .0,
	--	blowup = 0.000,
	--	t_rotate = 10.,
	--	feed_param = .97,
	--},
	{
		dist_scale = 1.,
		dist_add = .1,
		sat_to_hue = .1,
		val_to_hue = .1,
		blowup = 0.002,
		t_rotate = 1.,
		orig_param = 0.,
		feed_param = 1.001;
	},
	{ -- In-place noise islands
		dist_scale = .000528,
		dist_add	= -0.000551,
		sat_to_hue = .00056,
		val_to_hue = .000056,
		blowup = .0008582,
		t_rotate = .000005206,
	},
	{
		dist_scale = .2,
		dist_add = .1,
		sat_to_hue = .2,
		val_to_hue = .2,
		blowup = -0.004,
		t_rotate = -2.,
		feed_param = 1.,
		orig_param = 1.,
	},
	{ -- Burning clouds. Phew
		dist_scale = 10.,
		dist_add = .1,
		sat_to_hue = .4,
		val_to_hue = .4,
		sat_to_sat = .1;
		val_to_sat = .1;
		sat_to_val = .1;
		hue_to_val = 0;
		blowup = 0.01,
		t_rotate = .0,
		feed_param = 1.,
		orig_param = 0.1,
	},
	{ -- Noisy contract
		dist_scale = 0.1,
		dist_add = .1,
		sat_to_hue = .1,
		val_to_hue = .2,
		sat_to_sat = .0;
		val_to_sat = .2;
		sat_to_val = .00004;
		hue_to_val = .0;
		blowup = -0.002,
		t_rotate = .0,
		feed_param = 1.,
		orig_param = 0.1,
	},
	{ -- Color explosion
		dist_scale = 0.01,
		dist_add = .0,
		sat_to_hue = .1,
		val_to_hue = .0,
		sat_to_sat = .1;
		val_to_sat = .0;
		sat_to_val = .0;
		hue_to_val = .0;
		blowup = 0.001,
		t_rotate = 1.,
		c_rotate = -.001,
		feed_param = 1.,
		orig_param = 0.1,
	},
	{
		dist_scale = 0.1,
		dist_add = .0,
		sat_to_hue = .1,
		val_to_hue = .0,
		sat_to_sat = .1;
		val_to_sat = .1;
		sat_to_val = -.001;
		hue_to_val = .0;
		blowup = 0.02,
		t_rotate = 1.,
		c_rotate = -.001,
		feed_param = 1.,
		orig_param = 0.1,
	},
	{ -- In-place noise islands
		dist_scale = .000528,
		dist_add	= -0.000551,
		sat_to_hue = .00056,
		val_to_hue = .000056,
		blowup = .0008582,
		t_rotate = .000005206,
	},
	{ -- Passthrough
		orig_param = 1.;
		feed_param = 0.7;
	},

}

-- Set of postproc shader parameters
postproc_parameters = {
	default = {
		vignette_offset = 1.5*.5,
    vignette_exponent = 6.*.5,
		noise_amount = .7,
		saturation_value = .3,
		gamma = .5,
		gamma_pulse = 0.;
	},
	pulsed = {
		vignette_offset = 1.5*.5,
    vignette_exponent = 6.*.5,
		noise_amount = .7,
		saturation_value = .7,
		gamma = .5,
		gamma_pulse = 1.;
	},
}

-- Main draw code
function love.draw()
	love.graphics.setPixelEffect()
	bgcanvas:clear();
  
	local time = love.timer.getMicroTime()-time_0;

	current_param = math.floor(time / 6)+1;

	if current_param == 17 then
		love.event.quit()
	end

	-- Draw input stuff
	love.graphics.setCanvas(bgcanvas);
	love.graphics.setColor(255,255,255,30);

  lameshit1(time)

	-- Draw the feedback effect
	love.graphics.setColor(255,255,255,255);
	love.graphics.setCanvas(feedback_canvas);
	love.graphics.setPixelEffect(feedback_shader);
	feedback_shader:send("feedback", feedback_canvas);
	feedback_shader:send("t",time);
	feedback_shader:send("r",resolution);
	for name,value in pairs(feedback_parameters[current_param]) do
		feedback_shader:send(name, value)
	end
	love.graphics.draw(bgcanvas,0,0,0,1,1);
	

	-- Render the font-table thingy into the intermediate buffer
	love.graphics.setPixelEffect();
	local textparam = font_table[current_param];
	love.graphics.setFont(textparam.font);
	love.graphics.setColor(textparam.r, textparam.g, textparam.b, 255);
	love.graphics.print(textparam.text, textparam.x, textparam.y);

	-- Draw the result on the screen using the postproc shader
	love.graphics.setCanvas();
	love.graphics.setPixelEffect(postproc_shader);
	--love.graphics.setPixelEffect();
	postproc_shader:send("t", time);
	if(current_param < 3) then
		postproc = "default"
	else
		postproc = "pulsed"
	end
	for name,value in pairs(postproc_parameters[postproc]) do
		postproc_shader:send(name, value)
	end

  love.graphics.draw(feedback_canvas,0,0,0,1,1);
	
	-- Render font there
	love.graphics.setPixelEffect();

  local strstr = love.timer.getFPS() .. " - " .. time
  

--	love.graphics.setFont(f);
--	love.graphics.print(strstr, 
--			200+200*math.sin(love.timer.getMicroTime()-time_0), 
--			150+150*math.cos(love.timer.getMicroTime()-time_0))
  
  
end
