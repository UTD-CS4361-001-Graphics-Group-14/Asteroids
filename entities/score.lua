local Score = {}

local utils = require 'lib/utils'
local scale = require 'lib/scale'

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
	love.graphics.printf("Score: ".. utils.formatNumber(self.score), scale:X(20), scale:Y(10), scale:n(300), "left")
end

return Score
