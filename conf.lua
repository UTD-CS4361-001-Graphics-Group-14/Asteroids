function love.conf(t)
	t.version = '11.3'
	t.identity = 'cs4361.001f21-g14-asteroids'

	t.console = true -- TODO: change to false for release!

	t.window.title = 'Asteroids!'

	t.window.highdpi = true

	t.window.width = 800
	t.window.height = 800

	t.window.vsync = 1
end
