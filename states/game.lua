local state = {}

local Asteroid = require 'entities/asteroid'
local Vector2 = require 'lib/vector2'
local utils = require 'lib/utils'
local Score = require 'entities/score'
local Lives = require 'entities/life_counter'

state.name = 'game'

local ASTEROID_TARGET_PADDING = 0.5
local ASTEROID_MIN_SPEED = 50
local ASTEROID_MAX_SPEED = 250

local function spawnRandomAsteroid()
	local windowWidth, windowHeight = love.graphics.getDimensions()

	local windowPerimeter = 2 * (windowWidth + windowHeight)
	local spawnPositionLinear = love.math.random(0, windowPerimeter)

	-- top edge
	local spawnX = spawnPositionLinear
	local spawnY = 0

	if spawnPositionLinear >= windowWidth then
		-- right edge
		spawnPositionLinear = spawnPositionLinear - windowWidth
		spawnX = windowWidth
		spawnY = spawnPositionLinear

		if spawnPositionLinear >= windowHeight then
			-- bottom edge
			spawnPositionLinear = spawnPositionLinear - windowHeight
			spawnX = spawnPositionLinear
			spawnY = windowHeight

			if spawnPositionLinear >= windowWidth then
				-- left edge
				spawnPositionLinear = spawnPositionLinear - windowWidth
				spawnX = 0
				spawnY = spawnPositionLinear
			end
		end
	end

	local spawnPosition = Vector2:new(spawnX, spawnY)

	local minTargetX = windowWidth * ASTEROID_TARGET_PADDING / 2
	local maxTargetX = windowWidth - minTargetX
	local minTargetY = windowHeight * ASTEROID_TARGET_PADDING / 2
	local maxTargetY = windowHeight - minTargetY

	local targetPoint = Vector2:new(
		love.math.random(minTargetX, maxTargetX),
		love.math.random(minTargetY, maxTargetY)
	)
	local spawnVelocity = targetPoint:difference(spawnPosition)
	                                   :normalized()
	                                   :scaled(
	                                       love.math.random(
	                                           ASTEROID_MIN_SPEED,
	                                           ASTEROID_MAX_SPEED
	                                       )
	                                   )
	
	return Asteroid:new(spawnPosition, spawnVelocity)
end

function state:init(data)
	self.textFont = love.graphics.newFont('assets/fonts/roboto.ttf', 48)
	self.asteroids = {
		spawnRandomAsteroid()
	}
	self.lives = Lives:new()
	self.score = Score:new()
end

function state:keypressed(key)
	if key == 's' then
		self.asteroids[#self.asteroids + 1] = spawnRandomAsteroid()
	elseif key == 'space' then
		self.score:increment()
	elseif key == 'd' then
		self.lives:decrement()
		if self.lives:get() == 0 then
			self.newState = 'game_over'
			self.newStateData = { score = self.score:get() }
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
	for _, asteroid in pairs(self.asteroids) do
		asteroid:draw(width, height)
	end

	self.lives:draw(width, height)
	self.score:draw(width, height)
end

return state
