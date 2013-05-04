-- Initialization
function love.load()
	-- Set graphics mode (change false to true for fullscreen)
	love.graphics.setMode(1280,720, false,0);
	-- Hide the mouse cursor
	love.mouse.setVisible(false);

	local f = love.graphics.newFont(30)
	love.graphics.setFont(f)
  
  bier = love.graphics.newImage( 'Rochfort8.JPG' )
  quad = love.graphics.newQuad( 2600, 1541 , 100, 100, 3648, 2736 )
  
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

-- Main draw code
function love.draw()
	love.graphics.setPixelEffect()
	bgcanvas:clear();
  
	time = love.timer.getMicroTime()-time_0;
	resolution = {bgcanvas:getWidth(), bgcanvas:getHeight()};
	
	-- Draw input stuff
	love.graphics.setCanvas(bgcanvas);
	love.graphics.setColor(255,127,0,255);

  local xx = 400+400*math.cos(love.timer.getMicroTime() - time_0)
  local yy = 400+400*math.sin(math.tan(love.timer.getMicroTime() - time_0))

  quad:setViewport( xx * 8 , yy * 8 , math.sin(xx)*200, math.sin(yy)*200 )

  love.graphics.drawq( bier, quad, xx, yy, xx*yy )   

	-- Draw the feedback effect
	love.graphics.setColor(255,255*yy,255*xx,255);
	love.graphics.setCanvas(feedback_canvas);
	love.graphics.setPixelEffect(feedback_shader);
	feedback_shader:send("feedback", feedback_canvas);
	feedback_shader:send("t",time);
	feedback_shader:send("r",resolution);
	love.graphics.draw(bgcanvas,0,0,0,1,1);
	
	-- Draw the result on the screen using the postproc shader
	love.graphics.setCanvas();
--	love.graphics.setPixelEffect(postproc_shader);
	love.graphics.setPixelEffect();
--	postproc_shader:send("t", time);
	love.graphics.draw(feedback_canvas,0,0,0,1,1);
	
	love.graphics.print("Hello World", 
			200+200*math.sin(love.timer.getMicroTime()-time_0), 
			150+150*math.cos(love.timer.getMicroTime()-time_0))
  
  
end
