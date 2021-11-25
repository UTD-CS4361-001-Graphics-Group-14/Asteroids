local Vector2 = require 'lib/vector2'
local utils = require 'lib/utils'

local Ship = {}

local SHIP_MAX_SPEED = 400
local SHIP_ROT_SPEED = math.pi
local SHIP_ACCELERATION = 400
local SHIP_DECELERATION = 100

local SHIP_RADIUS = 30
local arenaHeight = 600
local arenaWidth = 800
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

function Ship:draw()

	love.graphics.setColor(0, 0, 1)
	love.graphics.circle('fill', self.pos.x, self.pos.y, SHIP_RADIUS)
	love.graphics.setColor(255, 0, 0)
	local nosePos = self.pos:sum(Vector2:newFromMagnitudeAndAngle(SHIP_RADIUS, self.ang))
	love.graphics.line(self.pos.x, self.pos.y, nosePos.x, nosePos.y)
end
return Ship
