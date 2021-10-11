local time = 0.0

function love.update(dt)
	time = time + dt
end

function love.draw()
	love.graphics.print(time, 0, 0)
end
