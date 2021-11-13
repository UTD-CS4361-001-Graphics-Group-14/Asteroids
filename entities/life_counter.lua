local DEFAULT_LIVES = 3

local Lives = {}

function Lives:new(x, y, initialLives)
	local lives = {
		x = x,
		y = y,
		lives = initialLives or DEFAULT_LIVES,
	}

	setmetatable(lives, self)
	self.__index = self

	return lives
end

function Lives:increment()
	self.lives = self.lives + 1
end

function Lives:decrement()
	self.lives = self.lives - 1
end

function Lives:get()
	return self.lives
end

function Lives:set(lives)
	self.lives = lives
end

function Lives:draw(width, height)
    love.graphics.printf("Lives: ".. self.lives, width - 350, 10, 300, "right")
end

return Lives
