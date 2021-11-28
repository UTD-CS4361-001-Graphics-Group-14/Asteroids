local UFO = {}

local Bullet = require 'entities/bullet'
local Circle = require 'lib/circle'
local Vector2 = require 'lib/vector2'
local scale = require 'lib/scale'

local UFO_SPEED = 200
local UFO_WIDTH = 25

local MIN_SHOT_TIME = 1
local MAX_SHOT_TIME = 3

function UFO:new(spawnPos, spawnDirection)
	local ufo = {
		pos = spawnPos or Vector2:new(0, 0),
		direction = spawnDirection or Vector2:new(0, 0),
		alive = true,
		shotTimer = love.math.random(MIN_SHOT_TIME, MAX_SHOT_TIME),
	}

	setmetatable(ufo, self)
	self.__index = self

	return ufo
end

function UFO:shouldUpdate()
	return self.alive
end

function UFO:getColliders()
	return {
		Circle:new(self.pos, UFO_WIDTH/2),
	}
end

function UFO:update(dt)
	if not self:shouldUpdate() then return end
	self.pos = self.pos + self.direction * UFO_SPEED * dt

	if self.shotTimer > 0 then
		self.shotTimer = self.shotTimer - dt
	end
end

function UFO:maybeFire(playerPos)
	if not self:shouldUpdate() then return end
	if self.shotTimer > 0 then return end
	self.shotTimer = self.shotTimer + love.math.random(MIN_SHOT_TIME, MAX_SHOT_TIME)
	return Bullet:new(self.pos, (playerPos - self.pos):heading())
end

function UFO:draw()
	if not self:shouldUpdate() then return end
	love.graphics.setColor(0, 1, 0.1)
	love.graphics.circle('fill', scale:X(self.pos.x), scale:Y(self.pos.y), scale:n(UFO_WIDTH/2))
end

function UFO:spawn(spawnPos, spawnDirection)
	self.alive = true
	self.pos = spawnPos
	self.direction = spawnDirection
end

function UFO:kill()
	self.alive = false
end

function UFO:_radius()
	return UFO_WIDTH/2
end

return UFO
