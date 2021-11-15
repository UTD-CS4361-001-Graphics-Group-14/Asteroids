local Vector2 = require 'lib/vector2'
local utils = require 'lib/utils'

local Bullet = {}

local BULLET_SPEED = 400
local BULLET_LIFETIME = 1.5 -- seconds

function Bullet:new(pos, ang)
	local bullet = {
		pos = pos,
		vel = Vector2:newFromMagnitudeAndAngle(BULLET_SPEED, ang),
		alive = true,
		aliveTime = 0,
	}

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
		utils.wrapVector(self.pos, 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	end
end

function Bullet:draw()
	if not self.alive then return end

	love.graphics.setColor(255, 255, 255)
	love.graphics.circle('fill', self.pos.x, self.pos.y, 5)
end

return Bullet
