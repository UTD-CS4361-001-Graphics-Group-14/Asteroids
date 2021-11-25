local Vector2 = require 'lib/vector2'
local Circle = require 'lib/circle'
local utils = require 'lib/utils'

local Ship = {}

local SHIP_MAX_SPEED = 400
local SHIP_ROT_SPEED = math.pi
local SHIP_ACCELERATION = 400
local SHIP_DECELERATION = 100

local SHIP_RADIUS = 20

local TRIANGLE_POINTS = {
	Vector2:newFromMagnitudeAndAngle(SHIP_RADIUS, 0),
	Vector2:newFromMagnitudeAndAngle(SHIP_RADIUS, 4 * math.pi / 5),
	Vector2:newFromMagnitudeAndAngle(SHIP_RADIUS * 0.5, math.pi),
	Vector2:newFromMagnitudeAndAngle(SHIP_RADIUS, 6 * math.pi / 5),
}

local COLLIDER_CIRCLES = {
	Circle:new(Vector2:new(0, 0), SHIP_RADIUS * 0.35),
	Circle:new(Vector2:new(SHIP_RADIUS * 0.5, 0), SHIP_RADIUS * 0.2),
	Circle:new(Vector2:new(SHIP_RADIUS * 0.6, 0):rotated(4 * math.pi / 5), SHIP_RADIUS * 0.2),
	Circle:new(Vector2:new(SHIP_RADIUS * 0.6, 0):rotated(6 * math.pi / 5), SHIP_RADIUS * 0.2),
}

function Ship:new(pos, ang, vel)
	local ship = {
		pos = pos,
		ang = ang or 0,
		vel = vel or Vector2:new(0, 0),
	}

	setmetatable(ship, self)
	self.__index = self

	return ship
end

function Ship:update(dt)
	local accel = Vector2:new(0, 0)

	if self.vel:magnitude() > 0 then
		accel = self.vel:reversed():scaled(SHIP_DECELERATION)
	end

	if love.keyboard.isDown('left') then
		self.ang = self.ang - SHIP_ROT_SPEED * dt
	end
	if love.keyboard.isDown('right') then
		self.ang = self.ang + SHIP_ROT_SPEED * dt
	end
	if love.keyboard.isDown('up') then
		if self.vel:magnitude() <= SHIP_MAX_SPEED then
			accel:add(Vector2:newFromMagnitudeAndAngle(SHIP_ACCELERATION, self.ang))
		end
	end

	self.vel:add(accel * dt)
	self.pos:add(self.vel * dt)
	utils.wrapVector(
		self.pos,
		-SHIP_RADIUS, -SHIP_RADIUS,
		love.graphics.getWidth() + SHIP_RADIUS, love.graphics.getHeight() + SHIP_RADIUS
	)
end

function Ship:getNosePos()
	return self.pos:sum(Vector2:newFromMagnitudeAndAngle(SHIP_RADIUS, self.ang))
end

function Ship:getColliders()
	local colliders = {}

	for i, circle in ipairs(COLLIDER_CIRCLES) do
		colliders[i] = Circle:new(circle.pos:rotated(self.ang):sum(self.pos), circle.radius)
	end

	return colliders
end

function Ship:draw()
	local poly = {}
	for i = 1, #TRIANGLE_POINTS do
		local translated = self.pos:sum(TRIANGLE_POINTS[i]:rotated(self.ang))
		poly[#poly + 1] = translated.x
		poly[#poly + 1] = translated.y
	end
	love.graphics.setColor(0, 255, 255)
	local tris = love.math.triangulate(poly)
	for _, tri in pairs(tris) do
		love.graphics.polygon('fill', tri)
	end
	-- love.graphics.circle('fill', self.pos.x, self.pos.y, SHIP_RADIUS)
	love.graphics.setColor(255, 0, 0)
	local nosePos = self:getNosePos()
	love.graphics.line(self.pos.x, self.pos.y, nosePos.x, nosePos.y)
end

return Ship
