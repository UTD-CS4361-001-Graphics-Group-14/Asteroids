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

local ASTEROID_POINT_VALUES = {
	100,
	50,
	20,
}

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

	self.shipThrustSfx = resources.audio.thrust
	self.shipThrustSfx:setVolume(0.4)
	self.shipThrustSfx:setLooping(true)
end

function state:keypressed(key)
	-- DEBUGGING KEYS

	if key == 'c' then
		self.debug = not self.debug
		print('[DEBUG] Debugging mode active = ' .. tostring(self.debug))
	end

	if self.debug then
		if key == 's' then
			self.asteroids[#self.asteroids + 1] = spawnRandomAsteroid()
			print('[DEBUG] Spawned asteroid at ' .. tostring(self.asteroids[#self.asteroids].pos))
		elseif key == 'd' then
			self.ship:kill()
			print('[DEBUG] Killed ship')
		elseif key == 'e' then
			if #self.asteroids == 0 then return end
			local randomAsteroid = self.asteroids[love.math.random(1, #self.asteroids)]
			local newAsteroids = randomAsteroid:kill()
			utils.extendTable(self.asteroids, newAsteroids)
			print('[DEBUG] Killed asteroid at ' .. tostring(randomAsteroid.pos))
		elseif key == 'u' then
			self.ufoSpawnDelay = 0
			print('[DEBUG] Spawned UFO')
		end
	end

	-- SHIP CONTROLS

	if not self.ship:shouldUpdate() then return end

	if key == 'space' then
		if self.shotDelay <= 0 then
			love.audio.stop(self.fire)
			love.audio.play(self.fire)
			self.bullets[#self.bullets + 1] = self.ship:fire()
			self.shotDelay = SHOT_DELAY
		end
	elseif key == 'lalt' or key == 'ralt' then
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

	if self.ship.burningForward then
		love.audio.play(self.shipThrustSfx)
	else
		love.audio.stop(self.shipThrustSfx)
	end

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
		self.ufoSpawnDelay = love.math.random(MIN_UFO_SPAWN_TIME, MAX_UFO_SPAWN_TIME)
		love.audio.stop(self.ufoSfx)

		return
	end

	for _, bullet in pairs(self.bullets) do
		bullet:update(dt)

		if self.ufo:shouldUpdate() then
			if utils.collidesWith(bullet, self.ufo) then
				love.audio.stop(self.impact)
				love.audio.play(self.impact)

				love.audio.stop(self.ufoSfx)

				self.ufo:kill()
				bullet:kill()
				self.ufoBullets = {}

				self.score:increment(1000)

				break
			end
		end
	end

	for _, bullet in pairs(self.ufoBullets) do
		bullet:update(dt)

		for _, playerBullet in pairs(self.bullets) do
			if utils.collidesWith(bullet, playerBullet) then
				love.audio.stop(self.impact)
				love.audio.play(self.impact)

				bullet:kill()
				playerBullet:kill()

				break
			end
		end

		if utils.collidesWith(bullet, self.ship) then
			love.audio.play(self.explosion)

			bullet:kill()
			self.ship:kill()

			break
		end
	end

	for _, asteroid in pairs(self.asteroids) do
		asteroid:update(dt)

		for _, bullet in pairs(self.bullets) do
			if utils.collidesWith(asteroid, bullet) then
				utils.extendTable(newAsteroids, asteroid:kill())

				bullet:kill()

				love.audio.stop(self.impact)
				love.audio.play(self.impact)

				self.score:increment(ASTEROID_POINT_VALUES[asteroid.size])

				break
			end
		end

		if utils.collidesWith(asteroid, self.ship) then
			love.audio.play(self.explosion)

			self.ship:kill()

			break
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

	for _, asteroid in pairs(self.asteroids) do
		asteroid:draw(width, height)
	end

	self.ufo:draw()

	for _, bullet in pairs(self.bullets) do
		love.graphics.setColor(1, 0.5, 0)
		bullet:draw(width, height)
	end

	for _, bullet in pairs(self.ufoBullets) do
		love.graphics.setColor(0, 1, 0.5)
		bullet:draw(width, height)
	end

	self.ship:drawExplosion()

	love.graphics.setColor(255, 255, 255)
	self.lives:draw(width, height)
	self.score:draw(width, height)

	if self.debug then
		utils.drawColliders(self.ship)
		utils.drawColliders(self.ufo)
		for _, asteroid in pairs(self.asteroids) do
			utils.drawColliders(asteroid)
		end
		for _, bullet in pairs(self.bullets) do
			utils.drawColliders(bullet)
		end
		for _, bullet in pairs(self.ufoBullets) do
			utils.drawColliders(bullet)
		end
	end
end

return state
