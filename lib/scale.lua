local scale = {}

function scale:_init(w, h)
	self.ow = w
	self.oh = h

	self:_resize(w, h)
end

function scale:_resize(w, h)
	self.w = w
	self.h = h

	self.scale = math.min(w / self.ow, h / self.oh)
	if w > h then
		self.xPad = (w - self.ow * self.scale) / 2
		self.yPad = 0
	else
		self.xPad = 0
		self.yPad = (h - self.oh * self.scale) / 2
	end
end

function scale:n(n)
	return n * self.scale
end

function scale:X(x)
	return self:n(x) + self.xPad
end

function scale:Y(y)
	return self:n(y) + self.yPad
end

function scale:_padding()
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle('fill', 0, 0, self.xPad, self.h)
	love.graphics.rectangle('fill', self.w - self.xPad, 0, self.xPad, self.h)
	love.graphics.rectangle('fill', 0, 0, self.w, self.yPad)
	love.graphics.rectangle('fill', 0, self.h - self.yPad, self.w, self.yPad)
end

return scale
