-- Called once, at initialization time; set up game state and variables
function love.load()
	GAME_STATES = {
		menu = require 'states/menu',
		game = require 'states/game',
		game_over = require 'states/game_over',
		credits = require 'states/credits',
	}

	screenWidth, screenHeight = love.graphics.getDimensions()

	gameState = GAME_STATES['menu']
	gameState:init()
end

local FPS_SAMPLE_INTERVAL = 3 -- seconds
local timeSinceLastFPSSample = 0

-- Called every frame, just before draw. Do physics calculations, etc.
function love.update(dt)
	screenWidth, screenHeight = love.graphics.getDimensions()

	gameState:update(dt)
	if gameState.newState then
		local newState = gameState.newState
		local data = gameState.newStateData
		gameState.newState = nil
		gameState.newStateData = nil

		print('[GameState] Switching to: ' .. newState)
		if GAME_STATES[newState] then
			gameState = GAME_STATES[newState]
			gameState:init(data)
		else
			print('[GameState] ERROR: No such state: ' .. newState)
		end
	end

	timeSinceLastFPSSample = timeSinceLastFPSSample + dt
	if timeSinceLastFPSSample >= FPS_SAMPLE_INTERVAL then
		timeSinceLastFPSSample = timeSinceLastFPSSample - FPS_SAMPLE_INTERVAL
		local fps = love.timer.getFPS()
		print('[DEBUG] FPS: ' .. fps)
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
