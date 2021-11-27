local Vector2 = require 'lib/vector2'
local Circle = require 'lib/circle'
local utils = require 'lib/utils'
local scale = require 'lib/scale'

local Asteroid = {}

local BASE_ASTEROID_SIZE = 15

function Asteroid:new(pos, vel, size)
	local asteroid = {
		pos = pos or Vector2:new(0, 0),
		vel = vel or Vector2:new(0, 0),
		size = size or 4,
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
	love.graphics.circle('fill', scale:X(self.pos.x), scale:Y(self.pos.y), scale:n(self:_radius()))
end

function Asteroid:update(dt)
	self.pos:add(self.vel:product(dt))
	utils.wrapVector(
		self.pos,
		-self:_radius(), -self:_radius(),
		scale.ow + self:_radius(), scale.oh + self:_radius()
	)
end

function Asteroid:getColliders()
	return {self.collider}
end

function Asteroid:kill()
	self.alive = false
	local newAsteroids = {}

	if self.size > 1 then
		local newSize = self.size / 2
		local newVel = self.vel:multiply(1.25)

		newAsteroids[1] = Asteroid:new(self.pos:clone(), newVel:rotated(math.pi / 2), newSize)
		newAsteroids[2] = Asteroid:new(self.pos:clone(), newVel:rotated(-math.pi / 2), newSize)
	end

	return newAsteroids
end

return Asteroid
