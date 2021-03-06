local utils = {}

local Vector2 = require 'lib/vector2'
local scale = require 'lib/scale'

-- adapted from https://stackoverflow.com/a/10992898
function utils.formatNumber(number)
	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

	-- reverse the int-string and append a comma to all blocks of 3 digits
	int = int:reverse():gsub("(%d%d%d)", "%1,")

	-- reverse the int-string back remove an optional comma and put the
	-- optional minus and fractional part back
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

function utils.drawColliders(ent)
	if not ent.getColliders then return end

	love.graphics.setLineWidth(1)
	love.graphics.setColor(0, 1, 0)
	for _, c in pairs(ent:getColliders()) do
		love.graphics.circle('line', scale:X(c.pos.x), scale:Y(c.pos.y), scale:n(c.radius))
	end
end

function utils.collidesWith(ent1, ent2)
	if not ent1.getColliders or not ent2.getColliders then return false end

	for _, c1 in pairs(ent1:getColliders()) do
		for _, c2 in pairs(ent2:getColliders()) do
			if c1:overlaps(c2) then
				return true
			end
		end
	end

	return false
end

function utils.centeredText(str, y)
	love.graphics.print(str, scale:X(scale.ow / 2) - love.graphics.getFont():getWidth(str) / 2, scale:Y(y))
end

function utils.randBetween(min, max)
	return math.random() * (max - min) + min
end

function utils.extendTable(t, other)
	for _, v in pairs(other) do
		t[#t + 1] = v
	end
end

function utils.pointsToBoundingBox(points)
	local minX, minY, maxX, maxY = points[1].x, points[1].y, points[1].x, points[1].y

	for i = 2, #points do
		local point = points[i]
		if point.x < minX then
			minX = point.x
		elseif point.x > maxX then
			maxX = point.x
		end
		if point.y < minY then
			minY = point.y
		elseif point.y > maxY then
			maxY = point.y
		end
	end

	return Vector2:new(minX, minY), Vector2:new(maxX, maxY)
end

function utils.doCirclesOverlap(circle1, circle2)
	return circle1:overlaps(circle2)
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

-- adapted from https://stackoverflow.com/a/53038524
function utils.filterTable(table, fnKeep)
	local j, n = 1, #table

	for i = 1, n do
		if fnKeep(table[i], i, j) then
			if i ~= j then
				table[j] = table[i]
				table[i] = nil
			end
			j = j + 1
		else
			table[i] = nil
		end
	end
end

return utils
