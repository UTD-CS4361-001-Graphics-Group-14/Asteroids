local state = {}

state.name = 'game_over'

local SELECTED_COLOR = {0.2, 0.8, 1, 1}
local UNSELECTED_COLOR = {1, 1, 1, 1}

function state:init(data)
	self.titleFont = love.graphics.newFont('assets/fonts/major-mono-display.ttf', 96)
	self.textFont = love.graphics.newFont('assets/fonts/roboto.ttf', 48)

	self.cursorPos = 1

	self.newState = nil

	self.score = data and data.score or 0
end

function state:keypressed(key)
	if key == 'up' then
		self.cursorPos = self.cursorPos - 1
		if self.cursorPos < 1 then
			self.cursorPos = 1
		end
	elseif key == 'down' then
		self.cursorPos = self.cursorPos + 1
		if self.cursorPos > 2 then
			self.cursorPos = 2
		end
	elseif key == 'return' then
		if self.cursorPos == 1 then
			self.newState = 'menu'
		elseif self.cursorPos == 2 then
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
	love.graphics.print('Game over', (width - self.titleFont:getWidth('Game over')) / 2, 0.1 * height)

	love.graphics.setFont(self.textFont)
	local scoreText = 'Score: ' .. self.score
	love.graphics.print(scoreText, (width - self.textFont:getWidth(scoreText)) / 2, 0.3 * height)

	if self.cursorPos == 1 then
		love.graphics.setColor(unpack(SELECTED_COLOR))
	end
	love.graphics.print('Restart', (width - self.textFont:getWidth('Restart')) / 2, 0.65 * height)
	love.graphics.setColor(unpack(UNSELECTED_COLOR))
	if self.cursorPos == 2 then
		love.graphics.setColor(unpack(SELECTED_COLOR))
	end
	love.graphics.print('Quit', (width - self.textFont:getWidth('Quit')) / 2, 0.8 * height)
end

return state
