local Vector2 = require 'lib/vector2'

local Bullet = {}

local BULLET_SPEED = 400

function Bullet:new(pos, ang)
	local bullet = {
		pos = pos,
		vel = Vector2:newFromMagnitudeAndAngle(BULLET_SPEED, ang),
	}

	setmetatable(bullet, self)
	self.__index = self

	return bullet
end

function Bullet:update(dt)
	self.pos:add(self.vel:product(dt))
end

function Bullet:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.circle('fill', self.pos.x, self.pos.y, 5)
end

return Bullet
