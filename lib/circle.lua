local Circle = {}

local scale = require 'lib/scale'

function Circle:new(pos, radius)
	local circle = {
		pos = pos,
		radius = radius
	}

	setmetatable(circle, self)
	self.__index = self

	return circle
end

function Circle:overlaps(circle)
	return self.pos:distance(circle.pos) < self.radius + circle.radius
end

function Circle:draw()
	love.graphics.circle('line', scale:X(self.pos.x), scale:Y(self.pos.y), scale:n(self.radius))
end

return Circle
