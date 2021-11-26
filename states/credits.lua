local state = {}

local resources = require 'assets/resources'

state.name = 'credits'

local names = {
	'Pavan Kumar Govu',
	'Eliot Partridge',
	'Diego Quiroga',
	'Pei-Yun Tseng',
}

local SELECTED_COLOR = {0.2, 0.8, 1, 1}

function state:init(data)
	self.titleFont = resources.fonts.title
	self.textFont = resources.fonts.default
	self.smallFont = resources.fonts.small

	self.newState = nil

	self.score = data and data.score or 0
end

function state:keypressed(key)
	if key == 'return' then
		self.newState = 'menu'
	end
end

function state:keyreleased(key) end

function state:update(dt) end

function state:draw(width, height)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(self.titleFont)
	love.graphics.print('Credits', (width - self.titleFont:getWidth('Credits')) / 2, 0.1 * height)

	love.graphics.setFont(self.smallFont)
	for i = 1, #names do
		love.graphics.print(names[i], (width - self.smallFont:getWidth(names[i])) / 2, 0.35 * height + i * self.smallFont:getHeight() * 1.2)
	end

	love.graphics.setFont(self.textFont)
	love.graphics.setColor(SELECTED_COLOR)
	love.graphics.print('Menu', (width - self.textFont:getWidth('Menu')) / 2, 0.8 * height)
end

return state
