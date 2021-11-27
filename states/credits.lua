local state = {}

local resources = require 'assets/resources'
local utils = require 'lib/utils'

state.name = 'credits'

local names = {
	'CS 4361.001 F21 Group 14',
	'',
	'Pavan Kumar Govu',
	'Eliot Partridge',
	'Diego Quiroga',
	'Pei-Yun Tseng',
}

local SELECTED_COLOR = {0.2, 0.8, 1, 1}

function state:init(data)
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
	love.graphics.setFont(resources.fonts.title)
	utils.centeredText('Credits', 0.1 * height)

	love.graphics.setFont(resources.fonts.small)
	for i = 1, #names do
		utils.centeredText(names[i], 0.3 * height + i * resources.fonts.small:getHeight() * 1.2)
	end

	love.graphics.setFont(resources.fonts.default)
	love.graphics.setColor(SELECTED_COLOR)
	utils.centeredText('Menu', 0.8 * height)
end

return state
