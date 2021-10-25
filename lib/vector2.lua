local Vector2 = {}

function Vector2:new(x, y)
	local v = { x = x or 0, y = y or 0 }

	setmetatable(v, self)
	self.__index = self

	return v
end

function Vector2:newFromMagnitudeAndAngle(magnitude, angle)
	return Vector2:new(magnitude * math.cos(angle), magnitude * math.sin(angle))
end

function Vector2:add(v)
	self.x = self.x + v.x
	self.y = self.y + v.y
end

function Vector2:sum(v)
	return Vector2:new(self.x + v.x, self.y + v.y)
end

function Vector2:sub(v)
	self.x = self.x - v.x
	self.y = self.y - v.y
end

function Vector2:diff(v)
	return Vector2:new(self.x - v.x, self.y - v.y)
end

function Vector2:multiply(amt)
	self.x = self.x * amt
	self.y = self.y * amt
end

function Vector2:product(amt)
	return Vector2:new(self.x * amt, self.y * amt)
end

function Vector2:dot(v)
	return self.x * v.x + self.y * v.y
end

function Vector2:magnitude()
	return math.sqrt(self:dot(self))
end

function Vector2:angle(v)
	return math.acos(self:dot(v) / (self:magnitude() * v:magnitude()))
end

function Vector2:normalize()
	local mag = self:magnitude()
	self.x = self.x / mag
	self.y = self.y / mag
end

function Vector2:normalized()
	local mag = self:magnitude()
	return Vector2:new(self.x / mag, self.y / mag)
end

function Vector2:rotate(angle)
	local x = self.x
	local y = self.y
	self.x = x * math.cos(angle) - y * math.sin(angle)
	self.y = x * math.sin(angle) + y * math.cos(angle)
end

function Vector2:rotated(angle)
	local x = self.x
	local y = self.y
	return Vector2:new(x * math.cos(angle) - y * math.sin(angle), x * math.sin(angle) + y * math.cos(angle))
end

function Vector2:scale(magnitude)
	local mag = self:magnitude()
	self.x = self.x / mag * magnitude
	self.y = self.y / mag * magnitude
end

function Vector2:scaled(magnitude)
	local mag = self:magnitude()
	return Vector2:new(self.x / mag * magnitude, self.y / mag * magnitude)
end

return Vector2
