local Circle = {}

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
	love.graphics.circle('line', self.pos.x, self.pos.y, self.radius)
end

return Circle
