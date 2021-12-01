local UFO = {}

local Bullet = require 'entities/bullet'
local Circle = require 'lib/circle'
local Vector2 = require 'lib/vector2'
local scale = require 'lib/scale'

local UFO_SPEED = 250
local UFO_WIDTH = 30

local MIN_SHOT_TIME = 1
local MAX_SHOT_TIME = 3

local UFO_CAP_POINTS = {
	Vector2:new(0, -1),
	Vector2:new(0.35, -1),
	Vector2:new(0.65, -0.666),
	Vector2:new(0.65, 0.1),
	Vector2:new(-0.65, 0.1),
	Vector2:new(-0.65, -0.666),
	Vector2:new(-0.35, -1),
}

local UFO_BASE_POINTS = {
	Vector2:new(0.65, 0.1),
	Vector2:new(1.25, 0.45),
	Vector2:new(0.65, 1),
	Vector2:new(-0.65, 1),
	Vector2:new(-1.25, 0.45),
	Vector2:new(-0.65, 0.1),
}

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

	local targetAng = (playerPos - self.pos):heading()
	local bulletPos = self.pos + Vector2:newFromMagnitudeAndAngle(self:_radius(), targetAng)

	return Bullet:new(bulletPos, targetAng)
end

function UFO:draw()
	if not self:shouldUpdate() then return end

	love.graphics.setColor(0, 1, 0.1)

	love.graphics.setLineWidth(1)

	local capPoly = {}
	for i, point in ipairs(UFO_CAP_POINTS) do
		local scaledPoint = point:product(self:_radius()):add(self.pos)
		capPoly[#capPoly + 1] = scale:X(scaledPoint.x)
		capPoly[#capPoly + 1] = scale:Y(scaledPoint.y)
	end
	love.graphics.polygon('line', capPoly)

	local basePoly = {}
	for i, point in ipairs(UFO_BASE_POINTS) do
		local scaledPoint = point:product(self:_radius()):add(self.pos)
		basePoly[#basePoly + 1] = scale:X(scaledPoint.x)
		basePoly[#basePoly + 1] = scale:Y(scaledPoint.y)
	end
	local tris = love.math.triangulate(basePoly)
	for _, tri in pairs(tris) do
		love.graphics.polygon('fill', tri)
	end
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
