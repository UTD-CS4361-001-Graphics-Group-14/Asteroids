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
	bgmusic = love.audio.newSource('/assets/audio/delay.mp3', 'stream'),
	explosion = love.audio.newSource('/assets/audio/explosion5.mp3', 'stream'),
	firing = love.audio.newSource('/assets/audio/sflaser15.mp3','stream')
}

resources.fonts = {}

function resources:_resize()
	for k, v in pairs(fonts) do
		self.fonts[k] = love.graphics.newFont(v.file, scale:n(v.size))
	end
end

return resources
