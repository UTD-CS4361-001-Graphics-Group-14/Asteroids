local state = {}

local Asteroid = require 'entities/asteroid'
local Vector2 = require 'lib/vector2'
local utils = require 'lib/utils'
local score = require 'entities/score'
local lives = require 'entities/life_counter'

state.name = 'game'

local function spawnRandomAsteroid()
	return Asteroid:new(
		Vector2:new(
			utils.randBetween(0, love.graphics.getWidth()),
			utils.randBetween(0, love.graphics.getHeight())
		),
		Vector2:newFromMagnitudeAndAngle(
			utils.randBetween(20, 200),
			utils.randBetween(0, 360)
		)
	)
end

function state:init(data)
	self.textFont = love.graphics.newFont('assets/fonts/roboto.ttf', 48)
	self.asteroids = {
		spawnRandomAsteroid()
	}
	setScore(0)
	setLives(3)
end

function state:keypressed(key)
	if key == 'return' then
		self.newState = 'game_over'
		self.newStateData = { score = 200 }
	elseif key == 's' then
		self.asteroids[#self.asteroids + 1] = spawnRandomAsteroid()
	elseif key == 'space' then
		score = incrementScore()
	elseif key == 'd' then
		lives = decrementLives()
		if lives == 0 then
		self.newState = 'game_over'
		self.newStateData = { score = getScore()}
		end
	end
end

function state:keyreleased(key)

end

function state:update(dt)
	for _, asteroid in pairs(self.asteroids) do
		asteroid:update(dt)
	end
end

function state:draw(width, height)
	love.graphics.setFont(self.textFont)
	-- love.graphics.print('And here\'s where I\'d put my game...', 20, 20)
	-- love.graphics.print('IF I HAD ONE!!!', 20, 70)
	drawScore()
	drawLives()
	for _, asteroid in pairs(self.asteroids) do
		asteroid:draw()
	end
end

return state
