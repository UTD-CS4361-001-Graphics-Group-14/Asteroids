local utils = {}

local Vector2 = require 'lib/vector2'

function utils.randBetween(min, max)
	return math.random() * (max - min) + min
end

function utils.isWithinCircle(point, circlePos, circleRadius)
	local dist = point:distance(circlePos)
	return dist <= circleRadius
end

function utils.isWithinBox(point, boxTopLeft, boxBottomRight)
	return point.x >= boxTopLeft.x
		and point.x <= boxBottomRight.x
		and point.y >= boxTopLeft.y
		and point.y <= boxBottomRight.y
end

function utils.isColinear(point, lineStart, lineEnd, epsilon)
	epsilon = epsilon or 0.001

	m = (lineEnd.y - lineStart.y) / (lineEnd.x - lineStart.x)
	local y = m * (point.x - lineStart.x) + lineStart.y

	return math.abs(y - point.y) <= epsilon
end

-- adapted from https://love2d.org/wiki/PointWithinShape
function utils.isWithinBounds(point, shape)
	if #shape == 0 then
		return false
	elseif #shape == 1 then
		return point.x == shape[1].x and point.y == shape[1].y
	elseif #shape == 2 then
		return (utils.isWithinBox(point, shape[1], shape[2]) or utils.isWithinBox(point, shape[2], shape[1]))
			and utils.isColinear(point, shape[1], shape[2])
	else
		-- even-odd algorithm
		-- adapted from https://www.eecs.umich.edu/courses/eecs380/HANDOUTS/PROJ2/InsidePoly.html

		inside = false
		p1 = shape[1]
		for i = 1, #shape do
			p2 = shape[i % #shape + 1]
			if point.y > math.min(p1.y, p2.y) then
				if point.y <= math.max(p1.y, p2.y) then
					if point.x <= math.max(p1.x, p2.x) then
						if p1.y ~= p2.y then
							intersection = (point.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x
							if p1.x == p2.x or point.x <= intersection then
								inside = not inside
							end
						end
					end
				end
			end
			p1 = p2
		end

		return inside
	end
end

function utils.wrapVector(v, minX, minY, maxX, maxY)
	print(v)

	if v.x < minX then
		v.x = v.x + (maxX - minX)
	elseif v.x > maxX then
		v.x = v.x - (maxX - minX)
	end

	if v.y < minY then
		v.y = v.y + (maxY - minY)
	elseif v.y > maxY then
		v.y = v.y - (maxY - minY)
	end
end

return utils
