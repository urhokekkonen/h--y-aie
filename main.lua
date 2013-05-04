-- Initialization
function love.load()
	-- Set graphics mode (change false to true for fullscreen)
  wantedwidth = 1280
  wantedheight = 720
	love.graphics.setMode(wantedwidth,wantedheight, false,0);
	-- Hide the mouse cursor
	love.mouse.setVisible(false);

	local f = love.graphics.newFont(30)
	love.graphics.setFont(f)
  
  bier = love.graphics.newImage( 'Rochfort8.JPG' )
  r8w = 3648
  r8h = 2736
  quad = love.graphics.newQuad( 2600, 1541 , 100, 100, r8w, r8h )  
	resolution = {wantedwidth, wantedheight};
  halftw = resolution[1]/2
  halfth = resolution[2]/2
 
	-- Initialize shaders
	feedback_shader = love.graphics.newPixelEffect(love.filesystem.read("feedback.glsl"));

--	postproc_shader = love.graphics.newPixelEffect(love.filesystem.read("postproc.glsl"));

  bgcanvas = love.graphics.newCanvas();
	feedback_canvas = love.graphics.newCanvas();
	feedback_canvas2 = love.graphics.newCanvas();

	-- Load audio
	music = love.audio.newSource("music.ogg","stream");
	music:play();

	-- Set reference time
	time_0 = love.timer.getMicroTime();
end

-- Exit on esc.
function love.keypressed(key, unicode)
	if key == 'escape' then
		love.event.quit()
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


-- Set of feedback shader parameters
feedback_parameters = {
	colorful = {
		dist_scale = 1.,
		dist_add = .1,
		sat_to_hue = .1,
		val_to_hue = .1,
		blowup = 0.002,
		t_rotate = 10.,
	}
}

-- Set of postproc shader parameters
postproc_parameters = {
	default = {
		vignette_offset = 1.5*.5,
    vignette_exponent = 6.*.5,
		noise_amount = .7,
		saturation_value = .3,
		gamma = .5,
	},
}

-- Main draw code
function love.draw()
	love.graphics.setPixelEffect()
	bgcanvas:clear();
  
	local time = love.timer.getMicroTime()-time_0;
	
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
	for name,value in pairs(feedback_parameters["colorful"]) do
		feedback_shader:send(name, value)
	end
	love.graphics.draw(bgcanvas,0,0,0,1,1);
	
	-- Draw the result on the screen using the postproc shader
	love.graphics.setCanvas();
	--love.graphics.setPixelEffect(postproc_shader);
	love.graphics.setPixelEffect();
	--postproc_shader:send("t", time);
	--for name,value in pairs(postproc_parameters["default"]) do
	--	postproc_shader:send(name, value)
	--end
	love.graphics.draw(feedback_canvas,0,0,0,1,1);
	
	love.graphics.print("Hello World", 
			200+200*math.sin(love.timer.getMicroTime()-time_0), 
			150+150*math.cos(love.timer.getMicroTime()-time_0))
  
--  lameshit1(time/100)
  
end
