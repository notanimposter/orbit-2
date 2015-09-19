--obit 2.0
--main.lua
local Vector2d = require 'vector2d'
local Planetoid = require 'planetoid'
_G.planetoids = {}
_G.Scale = 10^-6
_G.TimeScale = 1000000
_G.Time = 0
_G.G = 6.67*10^-11 * 10^-9
_G.Focus = 1
_G.SoI_Mode = true
_G.UpdatesPerTick = 1
function love.load()
	table.insert(planetoids, Planetoid("Sun", 1.988435*10^30, 695500, Vector2d(0,0), Vector2d(0,0), {255,245,237}))
	table.insert(planetoids, Planetoid("Mercury", 3.30104*10^23, 2439.7, Vector2d(0,-5.9133491*10^7), Vector2d(47.4,0), {153,147,147}))
	table.insert(planetoids, Planetoid("Venus", 4.86732*10^24, 6051.9, Vector2d(0,-1.0821141*10^8), Vector2d(35,0), {192,189,180}))
	table.insert(planetoids, Planetoid("Earth", 5.9721986*10^24, 6367.4447, Vector2d(0,-1.49618773*10^8), Vector2d(29.8,0), {96,100,123}))
	table.insert(planetoids, Planetoid("Moon", 7.3459*10^22, 1737.5, Vector2d(0,-1.49618773*10^8+385000), Vector2d(29.8-1.02,0), {149,136,132}))
	table.insert(planetoids, Planetoid("Mars", 6.41693*10^23, 3386, Vector2d(0,-2.28931109*10^8), Vector2d(24.1,0), {151,97,50}))
	table.insert(planetoids, Planetoid("Ceres", 9.47*10^20, 476.2, Vector2d(0,-4.15097364*10^8), Vector2d(17.9,0), {198,186,177}))
	table.insert(planetoids, Planetoid("Jupiter", 1.89813*10^27, 69173, Vector2d(0,-7.79323489*10^8), Vector2d(13,0), {193,178,170}))
	table.insert(planetoids, Planetoid("Saturn", 5.68319*10^26, 57316, Vector2d(0,-1.4288172*10^9), Vector2d(9.64,0), {196,178,144}))
	table.insert(planetoids, Planetoid("Uranus", 8.68103*10^25, 25266, Vector2d(0,-2.874165879*10^9), Vector2d(6.8,0), {146,192,211}))
	table.insert(planetoids, Planetoid("Neptune", 1.0241*10^26, 24553, Vector2d(0,-4.49841871*10^9), Vector2d(5.43,0), {142,191,225}))
	table.insert(planetoids, Planetoid("Pluto", 1.309*10^22, 1173, Vector2d(0,-6.08919413*10^9), Vector2d(4.67,0), {159,122,95}))
	
end
function love.keypressed(key)
	if key == '[' then
		_G.Focus = Focus - 1
		if Focus < 1 then
			_G.Focus = #planetoids
		end
	end
	if key == ']' then
		_G.Focus = Focus + 1
		if Focus > #planetoids then
			_G.Focus = 1
		end
	end
	if key == "s" then
		_G.SoI_Mode = not SoI_Mode
	end
	if key == "," then
		_G.TimeScale = TimeScale / 10
	end
	if key == "." then
		_G.TimeScale = TimeScale * 10
	end
	if key == ";" then
		_G.UpdatesPerTick = UpdatesPerTick - 1
	end
	if key == "\'" then
		_G.UpdatesPerTick = UpdatesPerTick + 1
	end
end
function love.mousepressed(x,y,btn)
	if btn == 'wu' then
		_G.Scale = Scale*2
	end
	if btn == 'wd' then
		_G.Scale = Scale/2
	end
end
function love.update(dt)
	for o=1,UpdatesPerTick do
		for i,v in ipairs(planetoids) do
			for j=i+1,#planetoids do
				local k = planetoids[j]
				local M = v.mass
				local m = k.mass
				local dist = (k.pos - v.pos)

				local F = G * M * m / dist:dSquared() * dt * TimeScale
				if SoI_Mode then
					if v.parent == 0 then
						v.parent = j
					end
					if k.parent == 0 then
						k.parent = i
					end
					if (k.pos - v.pos):dist() <= v.rSoI then
						k.parent = i
					end
					if (k.pos - v.pos):dist() <= k.rSoI then
						v.parent = j
					end
				end

				local forceVector = Vector2d(-F*math.cos(dist:angle()), F*math.sin(dist:angle()))
				v.vel = v.vel + forceVector / v.mass
				k.vel = k.vel + forceVector / k.mass

			end
			v:update(dt * TimeScale)
		end
		_G.Time = Time + dt * TimeScale
	end
end

function love.draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print(string.format("%.2f seconds", Time), 5, 5)
	love.graphics.print(string.format("%.2f days", Time/86400), 5, 20)
	love.graphics.print(string.format("%.2f years", Time*3.15569*10^-8), 5, 35)
	love.graphics.print(string.format("Time scale: %.0e", TimeScale), 5, 50)
	love.graphics.print(string.format("Scale: %.0e", Scale), 5, 65)
	love.graphics.print(string.format("Following: %s", planetoids[Focus].name), 5, 80)
	love.graphics.print(string.format("Parent: %s", planetoids[Focus].parent ~= 0 and planetoids[planetoids[Focus].parent].name or nil), 5, 95)
	love.graphics.print(string.format("UPT: %u", UpdatesPerTick), 5, 110)
	love.graphics.push()
	love.graphics.translate(.5*love.window.getWidth()-planetoids[Focus].pos.x*Scale, .5*love.window.getHeight()-planetoids[Focus].pos.y*Scale)
	for i,v in ipairs(planetoids) do
		v:draw()
	end
	love.graphics.pop()
end