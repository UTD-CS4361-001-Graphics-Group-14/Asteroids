-- Called once, at initialization time; set up game state and variables
function love.load()
	GAME_STATES = {
		menu = require 'states/menu',
		gameover = require 'states/gameover',
	}

	screenWidth, screenHeight = love.graphics.getDimensions()

	gameState = GAME_STATES['menu']
	gameState:init()
end

-- Called every frame, just before draw. Do physics calculations, etc.
function love.update(dt)
	screenWidth, screenHeight = love.graphics.getDimensions()

	local newState, data = gameState:update(dt)
	if newState then
		print('[GameState] Switching to: ' .. newState)
		if GAME_STATES[newState] then
			gameState = GAME_STATES[newState]
			gameState:init(data)
		else
			print('[GameState] ERROR: No such state: ' .. newState)
		end
	end
end

function love.keypressed(key)
	gameState:keypressed(key)
end

function love.keyreleased(key)
	gameState:keyreleased(key)
end

-- Called every frame. Draw things here.
function love.draw()
	gameState:draw(screenWidth, screenHeight)
end
