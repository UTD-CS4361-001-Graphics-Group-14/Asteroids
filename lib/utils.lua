local utils = {}

local Vector2 = require 'lib/vector2'

function utils.randBetween(min, max)
	return math.random() * (max - min) + min
end

return utils
