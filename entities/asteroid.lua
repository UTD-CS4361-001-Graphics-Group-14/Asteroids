local Vector2 = require 'lib/vector2'
local Circle = require 'lib/circle'
local utils = require 'lib/utils'

local Asteroid = {}

local BASE_ASTEROID_SIZE = 20

function Asteroid:new(pos, vel, size)
	local asteroid = {
		pos = pos or Vector2:new(0, 0),
		vel = vel or Vector2:new(0, 0),
		size = size or 3,
		alive = true,
	}

	setmetatable(asteroid, self)
	self.__index = self

	asteroid.collider = Circle:new(asteroid.pos, asteroid:_radius())

	return asteroid
end

function Asteroid:shouldUpdate()
	return self.alive
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

function Asteroid:kill()
	self.alive = false
	local newAsteroids = {}

	if self.size > 1 then
		local newSize = self.size - 1
		local newVel = self.vel:multiply(1.25)

		newAsteroids[1] = Asteroid:new(self.pos:clone(), newVel:rotated(math.pi / 2), newSize)
		newAsteroids[2] = Asteroid:new(self.pos:clone(), newVel:rotated(-math.pi / 2), newSize)
	end

	return newAsteroids
end

return Asteroid
