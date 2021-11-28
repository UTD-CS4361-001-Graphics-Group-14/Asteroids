local state = {}

local Asteroid = require 'entities/asteroid'
local Bullet = require 'entities/bullet'
local Vector2 = require 'lib/vector2'
local utils = require 'lib/utils'
local Score = require 'entities/score'
local Lives = require 'entities/life_counter'
local Ship = require 'entities/ship'
local UFO = require 'entities/ufo'
local resources = require 'assets/resources'
local scale = require 'lib/scale'

state.name = 'game'

local ASTEROID_TARGET_PADDING = 0.5
local ASTEROID_MIN_SPEED = 20
local ASTEROID_MAX_SPEED = 50

local MIN_NEXT_ASTEROID_DELAY = 3
local MAX_NEXT_ASTEROID_DELAY = 6

local MIN_UFO_SPAWN_TIME = 5
local MAX_UFO_SPAWN_TIME = 10

local HYPERSPACE_TARGET_PADDING = 0.05

local SHOT_DELAY = 0.175

local function spawnRandomAsteroid()
	local windowWidth, windowHeight = scale.ow, scale.oh

	local windowPerimeter = 2 * (windowWidth + windowHeight)
	local spawnPositionLinear = love.math.random(0, windowPerimeter)

	-- top edge
	local spawnX = spawnPositionLinear
	local spawnY = 0
	local offsetVec = Vector2:new(0, 1)

	if spawnPositionLinear >= windowWidth then
		-- right edge
		spawnPositionLinear = spawnPositionLinear - windowWidth
		spawnX = windowWidth
		spawnY = spawnPositionLinear
		offsetVec.x = -1
		offsetVec.y = 0

		if spawnPositionLinear >= windowHeight then
			-- bottom edge
			spawnPositionLinear = spawnPositionLinear - windowHeight
			spawnX = spawnPositionLinear
			spawnY = windowHeight
			offsetVec.x = 0
			offsetVec.y = -1

			if spawnPositionLinear >= windowWidth then
				-- left edge
				spawnPositionLinear = spawnPositionLinear - windowWidth
				spawnX = 0
				spawnY = spawnPositionLinear
				offsetVec.x = 1
				offsetVec.y = 0
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

	local asteroid = Asteroid:new(spawnPosition, spawnVelocity)
	asteroid.pos:sub(offsetVec:scaled(asteroid:_radius()))
	return asteroid
end

function state:init(data)
	self.background = resources.background.bg
	self.asteroids = {
		spawnRandomAsteroid()
	}
	self.bullets = {}
	self.lives = Lives:new()
	self.score = Score:new()
	self.ship = Ship:new(Vector2:new(scale.ow / 2, scale.oh / 2))
	self.debug = false
	self.nextAsteroidDelay = love.math.random(MIN_NEXT_ASTEROID_DELAY, MAX_NEXT_ASTEROID_DELAY)
	self.shotDelay = 0

	self.ufo = UFO:new()
	self.ufo.alive = false
	self.ufoSpawnDelay = love.math.random(MIN_UFO_SPAWN_TIME, MAX_UFO_SPAWN_TIME)
	self.ufoBullets = {}

	self.bgMusic = resources.audio.bgmusic
	self.bgMusic:setVolume(0.3)
	self.bgMusic:setLooping(true)
	love.audio.play(self.bgMusic)

	self.explosion = resources.audio.explosion
	self.explosion:setVolume(0.9)

	self.fire = resources.audio.firing
	self.fire:setVolume(0.8)

	self.impact = resources.audio.impact
	self.impact:setVolume(0.4)

	self.hyperspaceJump = resources.audio.hyperspace
	self.hyperspaceJump:setVolume(0.8)

	self.ufoSfx = resources.audio.ufo
	self.ufoSfx:setVolume(0.3)
	self.ufoSfx:setLooping(true)
end

function state:keypressed(key)
	if key == 's' then
		self.asteroids[#self.asteroids + 1] = spawnRandomAsteroid()
	elseif key == 'space' then
		if self.shotDelay <= 0 then
			love.audio.stop(self.fire)
			love.audio.play(self.fire)
			self.bullets[#self.bullets + 1] = self.ship:fire()
			self.shotDelay = SHOT_DELAY
		end
	elseif key == 'd' then
		self.ship:kill()
	elseif key == 'c' then
		self.debug = not self.debug
	elseif key == 'e' then
		if #self.asteroids == 0 then return end
		local randomAsteroid = self.asteroids[love.math.random(1, #self.asteroids)]
		local newAsteroids = randomAsteroid:kill()
		utils.extendTable(self.asteroids, newAsteroids)
	elseif key == 'lctrl' or key == 'rctrl' then
		if self.ship.hyperspaceTime > 0 then return end

		local minTargetX = scale.ow * HYPERSPACE_TARGET_PADDING / 2
		local maxTargetX = scale.ow - minTargetX
		local minTargetY = scale.oh * HYPERSPACE_TARGET_PADDING / 2
		local maxTargetY = scale.oh - minTargetY

		local newPos = Vector2:new(
			love.math.random(minTargetX, maxTargetX),
			love.math.random(minTargetY, maxTargetY)
		)

		love.audio.stop(self.hyperspaceJump)
		love.audio.play(self.hyperspaceJump)

		self.ship:hyperspaceJump(newPos)
	elseif key == 'u' then
		self.ufoSpawnDelay = 0
	end
end

function state:keyreleased(key)

end

function state:update(dt)
	if self.shotDelay > 0 then
		self.shotDelay = self.shotDelay - dt
	end

	if not self.ufo.alive and self.ufoSpawnDelay > 0 then
		self.ufoSpawnDelay = self.ufoSpawnDelay - dt
	end

	self.ship:update(dt)

	local newAsteroids = {}

	if not self.ship.alive then
		self.lives:decrement()
		if self.lives:get() == 0 then
			self.newState = 'game_over'
			self.newStateData = { score = self.score:get() }
			self.bgMusic:stop()
		end

		self.ship = Ship:new(Vector2:new(scale.ow / 2, scale.oh / 2))
		self.asteroids = {spawnRandomAsteroid()}
		self.bullets = {}

		self.ufoBullets = {}
		self.ufo.alive = false
		love.audio.stop(self.ufoSfx)

		return
	end

	for _, bullet in pairs(self.bullets) do
		bullet:update(dt)

		if self.ufo:shouldUpdate() then
			for _, cBullet in pairs(bullet:getColliders()) do
				for _, cUFO in pairs(self.ufo:getColliders()) do
					if utils.doCirclesOverlap(cBullet, cUFO) then
						love.audio.stop(self.impact)
						love.audio.play(self.impact)

						love.audio.stop(self.ufoSfx)

						self.ufo:kill()
						bullet:kill()
						self.ufoBullets = {}

						self.score:increment(100)

						break
					end
				end
			end
		end
	end

	for _, bullet in pairs(self.ufoBullets) do
		bullet:update(dt)

		for _, cBullet in pairs(bullet:getColliders()) do
			for _, playerBullet in pairs(self.bullets) do
				for _, cPlayerBullet in pairs(playerBullet:getColliders()) do
					if utils.doCirclesOverlap(cBullet, cPlayerBullet) then
						love.audio.stop(self.impact)
						love.audio.play(self.impact)

						bullet:kill()
						playerBullet:kill()

						break
					end
				end
			end

			for _, cShip in pairs(self.ship:getColliders()) do
				if utils.doCirclesOverlap(cBullet, cShip) then
					love.audio.play(self.explosion)

					bullet:kill()
					self.ship:kill()

					break
				end
			end
		end
	end

	for _, asteroid in pairs(self.asteroids) do
		asteroid:update(dt)

		for _, cAsteroid in pairs(asteroid:getColliders()) do
			for _, bullet in pairs(self.bullets) do
				for _, cBullet in pairs(bullet:getColliders()) do
					if utils.doCirclesOverlap(cAsteroid, cBullet) then
						utils.extendTable(newAsteroids, asteroid:kill())

						bullet:kill()

						love.audio.stop(self.impact)
						love.audio.play(self.impact)

						self.score:increment()

						break
					end
				end
			end

			for _, cShip in pairs(self.ship:getColliders()) do
				if utils.doCirclesOverlap(cAsteroid, cShip) then
					love.audio.play(self.explosion)

					self.ship:kill()

					break
				end
			end
		end
	end

	self.ufo:update(dt)

	local ufoBullet = self.ufo:maybeFire(self.ship.pos)
	if ufoBullet then
		love.audio.stop(self.fire)
		love.audio.play(self.fire)
		self.ufoBullets[#self.ufoBullets + 1] = ufoBullet
	end

	utils.filterTable(self.asteroids, function(asteroid) return asteroid.alive end)
	utils.filterTable(self.bullets, function(bullet) return bullet.alive end)
	utils.filterTable(self.ufoBullets, function(bullet) return bullet.alive end)

	self.nextAsteroidDelay = self.nextAsteroidDelay - dt

	if self.nextAsteroidDelay <= 0 then
		self.asteroids[#self.asteroids + 1] = spawnRandomAsteroid()
		self.nextAsteroidDelay = love.math.random(MIN_NEXT_ASTEROID_DELAY, MAX_NEXT_ASTEROID_DELAY)
	end

	if self.ufo.pos.x > scale.ow + self.ufo:_radius() then
		self.ufo:kill()
		love.audio.stop(self.ufoSfx)
	end

	if not self.ufo.alive and self.ufoSpawnDelay <= 0 then
		self.ufo:spawn(Vector2:new(-self.ufo:_radius(), scale.ow/2), Vector2:new(1, 0))
		self.ufoSpawnDelay = love.math.random(MIN_UFO_SPAWN_TIME, MAX_UFO_SPAWN_TIME)
		print('[UFO] Spawned. Next spawn in ' .. self.ufoSpawnDelay .. 's')
		love.audio.play(self.ufoSfx)
	end

	utils.extendTable(self.asteroids, newAsteroids)
end

function state:draw(width, height)
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(resources.fonts.default)
	love.graphics.draw(self.background, scale:X(0), scale:Y(0), 0, scale:n(1), scale:n(1))

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

	self.ufo:draw()

	if self.debug then
		love.graphics.setColor(0, 1, 0)
		for _, collider in pairs(self.ufo:getColliders()) do
			collider:draw()
		end
	end

	for _, bullet in pairs(self.bullets) do
		love.graphics.setColor(1, 0.5, 0)
		bullet:draw(width, height)

		if self.debug then
			love.graphics.setColor(0, 255, 0)
			for _, collider in pairs(bullet:getColliders()) do
				collider:draw()
			end
		end
	end

	for _, bullet in pairs(self.ufoBullets) do
		love.graphics.setColor(0, 1, 0.5)
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
