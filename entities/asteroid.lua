local Vector2 = require 'util/vector2'

local Asteroid = {}

local BASE_ASTEROID_SIZE = 20

function Asteroid:new(pos, vel, size)
	local asteroid = {
		pos = pos or Vector2:new(0, 0),
		vel = vel or Vector2:new(0, 0),
		size = size or 2,
	}

	setmetatable(asteroid, self)
	self.__index = self

	return asteroid
end

function Asteroid:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.circle('fill', self.pos.x, self.pos.y, 20 * self.size)
end

function Asteroid:update(dt)
	self.pos:add(self.vel:product(dt))
end

return Asteroid