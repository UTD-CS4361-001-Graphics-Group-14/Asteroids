local state = {}

local resources = require 'assets/resources'
local utils = require 'lib/utils'

state.name = 'game_over'

local SELECTED_COLOR = {0.2, 0.8, 1, 1}
local UNSELECTED_COLOR = {1, 1, 1, 1}

function state:init(data)
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

	love.graphics.setFont(resources.fonts.title)
	utils.centeredText('Game Over', 0.1 * height)

	love.graphics.setFont(resources.fonts.default)
	local scoreText = 'Score: ' .. self.score
	utils.centeredText(scoreText, 0.3 * height)

	if self.cursorPos == 1 then
		love.graphics.setColor(unpack(SELECTED_COLOR))
	end
	utils.centeredText('Restart', 0.65 * height)
	love.graphics.setColor(unpack(UNSELECTED_COLOR))
	if self.cursorPos == 2 then
		love.graphics.setColor(unpack(SELECTED_COLOR))
	end
	utils.centeredText('Quit', 0.8 * height)
end

return state
