local Ship = {}

function Ship:new(x, y, x2, y2, x3, y3)
    local ship = {
        x = x,
        y = y,
        x2 = x2,
        y2 = y2,
        x3 = x3,
        y3 = y3,
        speed = 200
    }

    setmetatable(ship, self)
	self.__index = self

	return ship
end

function Ship:update(dt)
    if love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
        self.x2 = self.x2 - self.speed * dt
        self.x3 = self.x3 - self.speed * dt
    elseif love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
        self.x2 = self.x2 + self.speed * dt
        self.x3 = self.x3 + self.speed * dt
    elseif love.keyboard.isDown("up") then
        self.y = self.y - self.speed * dt
        self.y2 = self.y2 - self.speed * dt
        self.y3 = self.y3 - self.speed * dt
    elseif love.keyboard.isDown("down") then
        self.y = self.y + self.speed * dt
        self.y2 = self.y2 + self.speed * dt
        self.y3 = self.y3 + self.speed * dt    
    end
end

function Ship:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.polygon('fill', self.x, self.y, self.x2, self.y2, self.x3, self.y3)
end

return Ship