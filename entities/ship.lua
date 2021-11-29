local Vector2 = require 'lib/vector2'
local Circle = require 'lib/circle'
local utils = require 'lib/utils'
local Bullet = require 'entities/bullet'
local scale = require 'lib/scale'

local Ship = {}

local SHIP_MAX_SPEED = 400
local SHIP_ROT_SPEED = 7 * math.pi / 6
local SHIP_ACCELERATION = 600
local SHIP_DECELERATION = 200

local SHIP_RADIUS = 20
local WHITE_CIRCLE_MAX_RADIUS = SHIP_RADIUS * 0.6
local YELLOW_CIRCLE_MAX_RADIUS = SHIP_RADIUS * 0.8
local ORANGE_CIRCLE_MAX_RADIUS = SHIP_RADIUS
local RED_CIRCLE_MAX_RADIUS = SHIP_RADIUS * 1.2

local ENGINE_EXHAUST_LENGTH = SHIP_RADIUS
local ENGINE_EXHAUST_LENGTH_MIN_RANDOM_OFFSET = -(ENGINE_EXHAUST_LENGTH * 0.1)
local ENGINE_EXHAUST_LENGTH_MAX_RANDOM_OFFSET = ENGINE_EXHAUST_LENGTH * 0.1

local EXPLOSION_TIME = 0.5
local HYPERSPACE_TIME = 0.5

local TRIANGLE_POINTS = {
	Vector2:newFromMagnitudeAndAngle(SHIP_RADIUS, 0),
	Vector2:newFromMagnitudeAndAngle(SHIP_RADIUS, 4 * math.pi / 5),
	Vector2:newFromMagnitudeAndAngle(SHIP_RADIUS * 0.5, math.pi),
	Vector2:newFromMagnitudeAndAngle(SHIP_RADIUS, 6 * math.pi / 5),
}

local COLLIDER_CIRCLES = {
	Circle:new(Vector2:new(0, 0), SHIP_RADIUS * 0.35),
	Circle:new(Vector2:new(SHIP_RADIUS * 0.5, 0), SHIP_RADIUS * 0.2),
	Circle:new(Vector2:new(SHIP_RADIUS * 0.6, 0):rotate(4 * math.pi / 5), SHIP_RADIUS * 0.2),
	Circle:new(Vector2:new(SHIP_RADIUS * 0.6, 0):rotate(6 * math.pi / 5), SHIP_RADIUS * 0.2),
}

function Ship:new(pos, ang, vel)
	local ship = {
		pos = pos,
		ang = ang or love.math.random(0, 2 * math.pi),
		vel = vel or Vector2:new(0, 0),
		dying = 0,
		alive = true,
		hyperspaceTime = 0,
		burningForward = false,
	}

	setmetatable(ship, self)
	self.__index = self

	return ship
end

function Ship:update(dt)
	self.burningForward = false

	if not self.alive then return end

	if self.hyperspaceTime > 0 then
		self.hyperspaceTime = self.hyperspaceTime - dt

		if self.hyperspaceTime <= HYPERSPACE_TIME / 2 and self.pos ~= self.hyperspacePos then
			self.pos = self.hyperspacePos
			self.vel:multiply(0)
		end

		return
	end

	if self.dying > 0 then
		self.ang = self.ang + dt * SHIP_ROT_SPEED * 5

		self.dying = self.dying - dt

		if self.dying <= 0 then
			self.alive = false
		end

		return
	end

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
		self.burningForward = true
		if self.vel:magnitude() <= SHIP_MAX_SPEED then
			accel:add(Vector2:newFromMagnitudeAndAngle(SHIP_ACCELERATION, self.ang))
		end
	end

	self.vel:add(accel * dt)
	self.pos:add(self.vel * dt)
	utils.wrapVector(
		self.pos,
		-SHIP_RADIUS, -SHIP_RADIUS,
		scale.ow + SHIP_RADIUS, scale.oh + SHIP_RADIUS
	)
end

function Ship:shouldUpdate()
	return self.alive and self.dying <= 0 and self.hyperspaceTime <= 0
end

function Ship:getNosePos()
	return self.pos:sum(Vector2:newFromMagnitudeAndAngle(SHIP_RADIUS, self.ang))
end

function Ship:fire()
	if not self:shouldUpdate() then return end
	return Bullet:new(self:getNosePos(), self.ang)
end

function Ship:getColliders()
	if self.hyperspaceTime > 0 then return {} end

	local colliders = {}

	for i, circle in ipairs(COLLIDER_CIRCLES) do
		colliders[i] = Circle:new(circle.pos:rotated(self.ang):add(self.pos), circle.radius)
	end

	return colliders
end

function Ship:kill()
	if not self:shouldUpdate() then return end
	self.dying = EXPLOSION_TIME
end

function Ship:draw()
	if not self.alive then return end

	if self.burningForward then
		local burnLengthOffset = love.math.random(ENGINE_EXHAUST_LENGTH_MIN_RANDOM_OFFSET, ENGINE_EXHAUST_LENGTH_MAX_RANDOM_OFFSET)

		love.graphics.setColor(0.5, 0.4, 1)
		love.graphics.setLineWidth(scale:n(6))

		local burnVec = Vector2:newFromMagnitudeAndAngle(
			ENGINE_EXHAUST_LENGTH + burnLengthOffset,
			self.ang - math.pi
		):add(self.pos)

		love.graphics.line(
			scale:X(self.pos.x), scale:Y(self.pos.y),
			scale:X(burnVec.x), scale:Y(burnVec.y)
		)
	end

	local shipScale = 1

	if self.hyperspaceTime > 0 then
		shipScale = math.abs(self.hyperspaceTime - HYPERSPACE_TIME / 2) / (HYPERSPACE_TIME / 2)
	end

	local poly = {}
	for i = 1, #TRIANGLE_POINTS do
		local translated = TRIANGLE_POINTS[i]:product(shipScale):rotate(self.ang):add(self.pos)
		poly[#poly + 1] = scale:X(translated.x)
		poly[#poly + 1] = scale:Y(translated.y)
	end
	love.graphics.setColor(0, 255, 255)
	local tris = love.math.triangulate(poly)
	for _, tri in pairs(tris) do
		love.graphics.polygon('fill', tri)
	end
end

function Ship:drawExplosion()
	if self.dying <= 0 then return end

	local r = (EXPLOSION_TIME - self.dying) / EXPLOSION_TIME
	love.graphics.setColor(255, 0, 0)
	love.graphics.circle('fill', scale:X(self.pos.x), scale:Y(self.pos.y), scale:n(r * (RED_CIRCLE_MAX_RADIUS + math.random() * RED_CIRCLE_MAX_RADIUS / 4)))
	love.graphics.setColor(255, 127, 0)
	love.graphics.circle('fill', scale:X(self.pos.x), scale:Y(self.pos.y), scale:n(r * (ORANGE_CIRCLE_MAX_RADIUS + math.random() * ORANGE_CIRCLE_MAX_RADIUS / 4)))
	love.graphics.setColor(255, 255, 0)
	love.graphics.circle('fill', scale:X(self.pos.x), scale:Y(self.pos.y), scale:n(r * (YELLOW_CIRCLE_MAX_RADIUS + math.random() * YELLOW_CIRCLE_MAX_RADIUS / 4)))
	love.graphics.setColor(255, 255, 255)
	love.graphics.circle('fill', scale:X(self.pos.x), scale:Y(self.pos.y), scale:n(r * (WHITE_CIRCLE_MAX_RADIUS + math.random() * WHITE_CIRCLE_MAX_RADIUS / 4)))
end

function Ship:hyperspaceJump(newPos)
	if not self:shouldUpdate() then return end
	self.hyperspaceTime = HYPERSPACE_TIME
	self.hyperspacePos = newPos
end

return Ship
