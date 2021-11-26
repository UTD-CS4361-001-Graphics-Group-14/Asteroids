local Vector2 = require 'lib/vector2'
local Circle = require 'lib/circle'
local utils = require 'lib/utils'

local Bullet = {}

local BULLET_SPEED = 800
local BULLET_LIFETIME = 0.5 -- seconds
local BULLET_RADIUS = 5

function Bullet:new(pos, ang)
	local bullet = {
		pos = pos,
		vel = Vector2:newFromMagnitudeAndAngle(BULLET_SPEED, ang),
		alive = true,
		aliveTime = 0,
	}

	bullet.collider = Circle:new(bullet.pos, BULLET_RADIUS)

	setmetatable(bullet, self)
	self.__index = self

	return bullet
end

function Bullet:update(dt)
	self.aliveTime = self.aliveTime + dt
	if self.aliveTime > BULLET_LIFETIME then
		self.alive = false
	else
		self.pos:add(self.vel:product(dt))
		utils.wrapVector(
			self.pos,
			-BULLET_RADIUS, -BULLET_RADIUS,
			love.graphics.getWidth() + BULLET_RADIUS, love.graphics.getHeight() + BULLET_RADIUS
		)
	end
end

function Bullet:getColliders()
	return {self.collider}
end

function Bullet:draw()
	if not self.alive then return end

	love.graphics.setColor(255, 255, 255)
	love.graphics.circle('fill', self.pos.x, self.pos.y, BULLET_RADIUS)
end

return Bullet
