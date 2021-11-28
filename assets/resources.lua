local resources = {}

local scale = require 'lib/scale'

local fonts = {
	default = {file = 'assets/fonts/roboto.ttf', size = 48},
	small = {file = 'assets/fonts/roboto.ttf', size = 24},
	title = {file = 'assets/fonts/major-mono-display.ttf', size = 96},
}

resources.background = {
	bg = love.graphics.newImage('assets/background/space.png'),
}

resources.audio = {
	bgmusic = love.audio.newSource('assets/audio/delay.mp3', 'stream'),
	explosion = love.audio.newSource('assets/audio/explosion5.mp3', 'stream'),
	firing = love.audio.newSource('assets/audio/sflaser15.mp3','stream'),
	-- impact = love.audio.newSource('/assets/audio/crushimpact.wav', 'stream'),
	impact = love.audio.newSource('assets/audio/shortexplosion.wav', 'stream'),
	hyperspace = love.audio.newSource('assets/audio/sfx_sounds_interaction12.wav', 'stream'),
	ufo = love.audio.newSource('assets/audio/sfx_alarm_loop4.wav', 'stream'),
}

resources.fonts = {}

function resources:_resize()
	for k, v in pairs(fonts) do
		self.fonts[k] = love.graphics.newFont(v.file, scale:n(v.size))
	end
end

return resources
