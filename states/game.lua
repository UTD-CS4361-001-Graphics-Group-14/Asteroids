local state = {}

state.name = 'game'

function state:init(data)
	self.textFont = love.graphics.newFont('assets/fonts/roboto.ttf', 48)
end

function state:keypressed(key)
	self.newState = 'game_over'
	self.newStateData = { score = 200 }
end

function state:keyreleased(key)

end

function state:update(dt)
	
end

function state:draw(width, height)
	love.graphics.setFont(self.textFont)
	love.graphics.print('And here\'s where I\'d put my game...', 20, 20)
	love.graphics.print('IF I HAD ONE!!!', 20, 70)
end

return state
