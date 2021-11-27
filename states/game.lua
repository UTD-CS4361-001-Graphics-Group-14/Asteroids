local state = {}

local Asteroid = require 'entities/asteroid'
local Bullet = require 'entities/bullet'
local Vector2 = require 'lib/vector2'
local utils = require 'lib/utils'
local Score = require 'entities/score'
local Lives = require 'entities/life_counter'
local Ship = require 'entities/ship'
local resources = require 'assets/resources'

state.name = 'game'

local ASTEROID_TARGET_PADDING = 0.5
local ASTEROID_MIN_SPEED = 50
local ASTEROID_MAX_SPEED = 250

local MIN_NEXT_ASTEROID_DELAY = 3
local MAX_NEXT_ASTEROID_DELAY = 6

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
	                                   :normalize()
	                                   :scale(
	                                       love.math.random(
	                                           ASTEROID_MIN_SPEED,
	                                           ASTEROID_MAX_SPEED
	                                       )
	                                   )

	return Asteroid:new(spawnPosition, spawnVelocity)
end

function spawnRandomBullet()
	local angle = love.math.random() * 2 * math.pi

	local pos = Vector2:new(
		love.graphics.getWidth() / 2,
		love.graphics.getHeight() / 2
	)

	local bullet = Bullet:new(pos, angle)

	return bullet
end

function state:init(data)
	self.textFont = resources.fonts.default
	self.background = resources.background.bg
	self.asteroids = {
		spawnRandomAsteroid()
	}
	self.bullets = {}
	self.lives = Lives:new()
	self.score = Score:new()
	self.ship = Ship:new(Vector2:new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2))
	self.debug = false
	self.nextAsteroidDelay = love.math.random(MIN_NEXT_ASTEROID_DELAY, MAX_NEXT_ASTEROID_DELAY)
end

function state:keypressed(key)
	if key == 's' then
		self.asteroids[#self.asteroids + 1] = spawnRandomAsteroid()
	elseif key == 'space' then
		self.bullets[#self.bullets + 1] = self.ship:fire()
	elseif key == 'd' then
		self.ship:kill()
	elseif key == 'c' then
		self.debug = not self.debug
	elseif key == 'e' then
		if #self.asteroids == 0 then return end
		local randomAsteroid = self.asteroids[love.math.random(1, #self.asteroids)]
		local newAsteroids = randomAsteroid:kill()
		utils.extendTable(self.asteroids, newAsteroids)
	end
end

function state:keyreleased(key)

end

function state:update(dt)
	self.ship:update(dt)

	local newAsteroids = {}

	if not self.ship.alive then
		self.lives:decrement()
		if self.lives:get() == 0 then
			self.newState = 'game_over'
			self.newStateData = { score = self.score:get() }
		end

		self.ship = Ship:new(Vector2:new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2))
		self.asteroids = {spawnRandomAsteroid()}
		self.bullets = {}

		return
	end

	for _, asteroid in pairs(self.asteroids) do
		asteroid:update(dt)

		for _, cAsteroid in pairs(asteroid:getColliders()) do
			for _, bullet in pairs(self.bullets) do
				for _, cBullet in pairs(bullet:getColliders()) do
					if utils.doCirclesOverlap(cAsteroid, cBullet) then
						utils.extendTable(newAsteroids, asteroid:kill())
						bullet:kill()

						self.score:increment()

						break
					end
				end
			end

			for _, cShip in pairs(self.ship:getColliders()) do
				if utils.doCirclesOverlap(cAsteroid, cShip) then
					self.ship:kill()
					break
				end
			end
		end
	end

	local deadBullets = {}

	for i, bullet in pairs(self.bullets) do
		bullet:update(dt)
	end

	utils.filterTable(self.asteroids, function(asteroid) return asteroid.alive end)
	utils.filterTable(self.bullets, function(bullet) return bullet.alive end)

	self.nextAsteroidDelay = self.nextAsteroidDelay - dt

	if self.nextAsteroidDelay <= 0 then
		self.asteroids[#self.asteroids + 1] = spawnRandomAsteroid()
		self.nextAsteroidDelay = love.math.random(MIN_NEXT_ASTEROID_DELAY, MAX_NEXT_ASTEROID_DELAY)
	end

	utils.extendTable(self.asteroids, newAsteroids)
end

function state:draw(width, height)
	love.graphics.setFont(self.textFont)
	love.graphics.draw(self.background)

	self.ship:draw()

	if self.debug then
		love.graphics.setColor(0, 255, 0)
		for _, collider in pairs(self.ship:getColliders()) do
			collider:draw()
		end
	end

	for _, asteroid in pairs(self.asteroids) do
		asteroid:draw(width, height)

		if self.debug then
			love.graphics.setColor(0, 255, 0)
			for _, collider in pairs(asteroid:getColliders()) do
				collider:draw()
			end
		end
	end

	for _, bullet in pairs(self.bullets) do
		bullet:draw(width, height)

		if self.debug then
			love.graphics.setColor(0, 255, 0)
			for _, collider in pairs(bullet:getColliders()) do
				collider:draw()
			end
		end
	end

	self.ship:drawExplosion()

	love.graphics.setColor(255, 255, 255)
	self.lives:draw(width, height)
	self.score:draw(width, height)
end

return state
