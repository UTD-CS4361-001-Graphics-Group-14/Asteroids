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
		size = size or 3,
		alive = true,
	}
	setmetatable(asteroid, self)
	self.__index = self

	asteroid.collider = Circle:new(asteroid.pos, asteroid:_radius())

	asteroid.ASTEROID_POINTS = {
		Vector2:newFromMagnitudeAndAngle(asteroid:_radius(), 0),
		Vector2:newFromMagnitudeAndAngle(asteroid:_radius() * 1.118, 1.107),
		Vector2:newFromMagnitudeAndAngle(asteroid:_radius() * 1.03, math.pi/2 + 0.245),
		Vector2:newFromMagnitudeAndAngle(asteroid:_radius() * 0.576, math.pi/2 + 0.862),
		Vector2:newFromMagnitudeAndAngle(asteroid:_radius(), math.pi),
		Vector2:newFromMagnitudeAndAngle(asteroid:_radius() * 0.976, math.pi + 0.876),
		Vector2:newFromMagnitudeAndAngle(asteroid:_radius() * 1.068, 3 * math.pi/2 + 0.359),
	}

	return asteroid
end

function Asteroid:shouldUpdate()
	return self.alive
end

function Asteroid:_radius()
	return BASE_ASTEROID_SIZE * (2 ^ (self.size - 1))
end

function Asteroid:draw()

	local poly = {}

	for i = 1, #self.ASTEROID_POINTS do
		local translated = self.ASTEROID_POINTS[i]:sum(self.pos)
		poly[#poly + 1] = scale:X(translated.x)
		poly[#poly + 1] = scale:Y(translated.y)
	end

	love.graphics.setColor(0.67, 0.67, 0.67)
	local tris = love.math.triangulate(poly)
	for _, tri in pairs(tris) do
		love.graphics.polygon('fill', tri)
	end
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
		local newSize = self.size - 1
		local newVel = self.vel:multiply(2.5)

		newAsteroids[1] = Asteroid:new(self.pos:clone(), newVel:rotated(math.pi / 2), newSize)
		newAsteroids[2] = Asteroid:new(self.pos:clone(), newVel:rotated(-math.pi / 2), newSize)
	end

	return newAsteroids
end

return Asteroid
