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

    -- make sure ship remains in the boundary of the window
    if self.x < 0 then
        self.x = 0
        self.x2 = self.x + 50
        self.x3 = self.x + 25
    elseif self.y3 < 0 then
        self.y3 = 0
        self.y2 = self.y3 + 70
        self.y = self.y3 + 70
    elseif self.x2 > love.graphics.getWidth() then
        self.x2 = love.graphics.getWidth()
        self.x = love.graphics.getWidth() - 50
        self.x3 = love.graphics.getWidth() - 25
    elseif self.y2 > love.graphics.getHeight() then
        self.y2= love.graphics.getHeight()
        self.y = love.graphics.getHeight()
        self.y3 = love.graphics.getHeight() - 70
    end
end

function Ship:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.polygon('fill', self.x, self.y, self.x2, self.y2, self.x3, self.y3)
end


return Ship