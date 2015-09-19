--orbit 2.0
--planetoid.lua
local Vector2d = require 'vector2d'
local Planetoid = {}
Planetoid.__index = Planetoid
setmetatable(Planetoid, {
  __call = function (...)
    return Planetoid.new(...)
  end,
})
function Planetoid.new(garbage, name, mass, r, pos, vel, color)
	local self = setmetatable({name = name, parent = 0, rSoI = 0, mass=mass, r=r, pos = pos, vel = vel, color = color, trail = {}}, Planetoid)
	return self
end

function Planetoid:update(dt)
	self.pos.x = self.pos.x + self.vel.x * dt
	self.pos.y = self.pos.y + self.vel.y * dt
 	if SoI_Mode then
 		if self.parent ~= 0 then
 			local parent = planetoids[self.parent]
			if planetoids[self.parent].rSoI ~= 0 and (self.pos - parent.pos):dist() > planetoids[self.parent].rSoI then
				self.parent = 0
				self.rSoI = 0
			end
 			self.rSoI = (self.pos - parent.pos):dist() * (self.mass / parent.mass)^(2/5)
 		end
 	else
 		self.parent = 0
 		self.rSoI = 0
 	end
 	
	table.insert(self.trail, self.pos:copy())
 	
end

function Planetoid:draw()
	love.graphics.setColor(unpack(self.color))
	if #self.trail > 1 then
		local pOffset = (self.parent ~= 0) and planetoids[self.parent].pos or 0
		local pDist = (self.parent ~= 0) and planetoids[self.parent].trail or {}

		for i=1,#self.trail-1 do
			local x1, y1 = ((pOffset + self.trail[i] - (pDist[i] or 0)) * Scale):explode()
			local x2, y2 = ((pOffset + self.trail[i+1] - (pDist[i+1] or 0)) * Scale):explode()
			love.graphics.line(x1,y1, x2,y2)
		end
	end
	--love.graphics.line(self.pos.x*Scale, self.pos.y*Scale, planetoids[self.parent].pos.x*Scale,planetoids[self.parent].pos.y*Scale)
	love.graphics.circle("fill", self.pos.x*Scale, self.pos.y*Scale, self.r*Scale)
	love.graphics.print(self.name, self.pos.x*Scale + self.r*Scale + 4, self.pos.y*Scale)
end
return Planetoid