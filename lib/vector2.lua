local Vector2 = {}

Vector2.__name = 'Vector2'

function Vector2:new(x, y)
	local v = { x = x or 0, y = y or 0 }

	setmetatable(v, self)
	self.__index = self

	return v
end

function Vector2:clone()
	return Vector2:new(self.x, self.y)
end

function Vector2:random(minLength, maxLength)
	if maxLength == nil then
		maxLength = minLength
		minLength = 0
	end

	local length = love.math.random(minLength, maxLength)
	local angle = love.math.random(2 * math.pi)

	return Vector2:newFromMagnitudeAndAngle(length, angle)
end

function Vector2:newFromMagnitudeAndAngle(magnitude, angle)
	return Vector2:new(magnitude * math.cos(angle), magnitude * math.sin(angle))
end

function Vector2:add(v)
	self.x = self.x + v.x
	self.y = self.y + v.y

	return self
end

function Vector2:sum(v)
	return Vector2:new(self.x + v.x, self.y + v.y)
end

-- shorten vec:sum(vec2) to vec + vec2
Vector2.__add = Vector2.sum

function Vector2:sub(v)
	self.x = self.x - v.x
	self.y = self.y - v.y

	return self
end

function Vector2:difference(v)
	return Vector2:new(self.x - v.x, self.y - v.y)
end

-- shorten vec:difference(vec2) to vec - vec2
Vector2.__sub = Vector2.difference

function Vector2:multiply(amt)
	self.x = self.x * amt
	self.y = self.y * amt

	return self
end

function Vector2:product(amt)
	return Vector2:new(self.x * amt, self.y * amt)
end

-- shorten vec:product(amt) to vec * amt
Vector2.__mul = Vector2.product

function Vector2:divide(amt)
	self.x = self.x / amt
	self.y = self.y / amt

	return self
end

function Vector2:quotient(amt)
	return Vector2:new(self.x / amt, self.y / amt)
end

-- shorten vec:quotient(amt) to vec / amt
Vector2.__div = Vector2.quotient

function Vector2:dot(v)
	return self.x * v.x + self.y * v.y
end

function Vector2:magnitude()
	return math.sqrt(self:dot(self))
end

function Vector2:angle(v)
	return math.acos(self:dot(v) / (self:magnitude() * v:magnitude()))
end

function Vector2:heading()
	return math.atan2(self.y, self.x)
end

function Vector2:distance(v)
	return math.sqrt((self.x - v.x) ^ 2 + (self.y - v.y) ^ 2)
end

function Vector2:normalize()
	local mag = self:magnitude()
	self.x = self.x / mag
	self.y = self.y / mag

	return self
end

function Vector2:normalized()
	local mag = self:magnitude()
	return Vector2:new(self.x / mag, self.y / mag)
end

-- shorten vec:normalized() to ~vec
Vector2.__bnot = Vector2.normalized

function Vector2:reverse()
	self.x = -self.x
	self.y = -self.y

	return self
end

function Vector2:reversed()
	return Vector2:new(-self.x, -self.y)
end

-- shorten vec:reversed() to -vec
Vector2.__unm = Vector2.reversed

function Vector2:rotate(angle)
	local x = self.x
	local y = self.y
	self.x = x * math.cos(angle) - y * math.sin(angle)
	self.y = x * math.sin(angle) + y * math.cos(angle)

	return self
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

	return self
end

function Vector2:scaled(magnitude)
	local mag = self:magnitude()
	return Vector2:new(self.x / mag * magnitude, self.y / mag * magnitude)
end

function Vector2:project(v)
	local mag = self:magnitude()
	local dot = self:dot(v)
	local proj = dot / (mag * mag)

	self.x = proj * v.x
	self.y = proj * v.y

	return self
end

function Vector2:projected(v)
	local mag = self:magnitude()
	local dot = self:dot(v)
	local proj = dot / (mag * mag)

	return Vector2:new(proj * v.x, proj * v.y)
end

Vector2.__bor = Vector2.projected

function Vector2:__tostring()
	return string.format("%s(%.4f, %.4f)", self.__name, self.x, self.y)
end

return Vector2
