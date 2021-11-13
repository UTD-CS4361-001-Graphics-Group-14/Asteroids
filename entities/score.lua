local Score = {}

function Score:new(x, y, initialScore)
	local score = {
		x = x,
		y = y,
		score = initialScore or 0,
	}

	setmetatable(score, self)
	self.__index = self

	return score
end

function Score:increment(amount)
	amount = amount or 20

	self.score = self.score + amount
end

function Score:get()
	return self.score
end

function Score:set(val)
	self.score = val
end

function Score:draw(width, height)
	love.graphics.printf("Score: ".. self.score, 20, 10, 300, "left")
end

return Score
