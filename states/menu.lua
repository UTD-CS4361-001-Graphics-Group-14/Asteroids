local state = {}

local resources = require 'assets/resources'

state.name = 'menu'

local SELECTED_COLOR = {0.2, 0.8, 1, 1}
local UNSELECTED_COLOR = {1, 1, 1, 1}

function state:init()
	self.titleFont = resources.fonts.title
	self.textFont = resources.fonts.default

	self.cursorPos = 1

	self.newState = nil
end

function state:keypressed(key)
	if key == 'up' then
		self.cursorPos = self.cursorPos - 1
		if self.cursorPos < 1 then
			self.cursorPos = 1
		end
	elseif key == 'down' then
		self.cursorPos = self.cursorPos + 1
		if self.cursorPos > 3 then
			self.cursorPos = 3
		end
	elseif key == 'return' then
		if self.cursorPos == 1 then
			self.newState = 'game'
		elseif self.cursorPos == 2 then
			self.newState = 'credits'
		elseif self.cursorPos == 3 then
			love.event.quit()
		end
	end
end

function state:keyreleased(key) end

function state:update(dt)

end

function state:draw(width, height)
	love.graphics.setColor(unpack(UNSELECTED_COLOR))

	love.graphics.setFont(self.titleFont)
	love.graphics.print('Asteroids', (width - self.titleFont:getWidth('Asteroids')) / 2, 0.1 * height)

	love.graphics.setFont(self.textFont)
	if self.cursorPos == 1 then
		love.graphics.setColor(unpack(SELECTED_COLOR))
	end
	love.graphics.print('New game', (width - self.textFont:getWidth('New game')) / 2, 0.5 * height)
	love.graphics.setColor(unpack(UNSELECTED_COLOR))
	if self.cursorPos == 2 then
		love.graphics.setColor(unpack(SELECTED_COLOR))
	end
	love.graphics.print('Credits', (width - self.textFont:getWidth('Credits')) / 2, 0.65 * height)
	love.graphics.setColor(unpack(UNSELECTED_COLOR))
	if self.cursorPos == 3 then
		love.graphics.setColor(unpack(SELECTED_COLOR))
	end
	love.graphics.print('Quit', (width - self.textFont:getWidth('Quit')) / 2, 0.8 * height)
end

return state
