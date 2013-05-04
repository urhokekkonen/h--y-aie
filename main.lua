-- Initialization
function love.load()
	local f = love.graphics.newFont(30)
	love.graphics.setFont(f)

	feedback_file = io.open("feedback.glsl");
	shader = love.graphics.newPixelEffect(feedback_file:read("*a"));


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
