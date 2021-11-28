local Vector2 = require 'lib/vector2'
local Circle = require 'lib/circle'
local utils = require 'lib/utils'
local scale = require 'lib/scale'

local Bullet = {}

local BULLET_SPEED = 500
local BULLET_LIFETIME = 1.5 -- seconds
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
		self:kill()
	else
		self.pos:add(self.vel:product(dt))
		utils.wrapVector(
			self.pos,
			-BULLET_RADIUS, -BULLET_RADIUS,
			scale.ow + BULLET_RADIUS, scale.oh + BULLET_RADIUS
		)
	end
end

function Bullet:kill()
	self.alive = false
end

function Bullet:getColliders()
	return {self.collider}
end

function Bullet:draw()
	if not self.alive then return end

	love.graphics.circle('fill', scale:X(self.pos.x), scale:Y(self.pos.y), scale:n(BULLET_RADIUS))
end

return Bullet
