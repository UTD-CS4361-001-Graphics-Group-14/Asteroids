local resources = {}

resources.fonts = {
	default = love.graphics.newFont('assets/fonts/roboto.ttf', 48),
	small = love.graphics.newFont('assets/fonts/roboto.ttf', 24),
	title = love.graphics.newFont('assets/fonts/major-mono-display.ttf', 96),
}

resources.background = {
	bg = love.graphics.newImage('assets/background/space.png')
}

return resources
