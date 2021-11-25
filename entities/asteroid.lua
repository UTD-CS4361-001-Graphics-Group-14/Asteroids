local Vector2 = require 'lib/vector2'
local Circle = require 'lib/circle'
local utils = require 'lib/utils'

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

	self.collider = Circle:new(asteroid.pos, asteroid:_radius())

	return asteroid
end

function Asteroid:_radius()
	return BASE_ASTEROID_SIZE * self.size
end

function Asteroid:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.circle('fill', self.pos.x, self.pos.y, self:_radius())
end

function Asteroid:update(dt)
	self.pos:add(self.vel:product(dt))
	utils.wrapVector(
		self.pos,
		-self:_radius(), -self:_radius(),
		love.graphics.getWidth() + self:_radius(), love.graphics.getHeight() + self:_radius()
	)
end

function Asteroid:getColliders()
	return {self.collider}
end

return Asteroid
