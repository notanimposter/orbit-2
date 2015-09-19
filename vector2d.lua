--vector2d.lua
local Vector2d = {}
Vector2d.__index = Vector2d
setmetatable(Vector2d, {
  __call = function (...)
    return Vector2d.new(...)
  end,
})
function Vector2d.new(garbage, x, y)
	if (type(x) ~= "number" or type(y) ~= "number") then
		return assert(nil, "expected numbers")
	end
	local self = setmetatable({x=x, y=y, x, y}, Vector2d)
	return self
end

--IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII--

function Vector2d:addVec(v)
	return Vector2d(self.x+v.x, self.y+v.y)
end
function Vector2d:addScalar(n)
	return Vector2d(self.x+n, self.y+n)
end
function Vector2d:subtractVec(v)
	return Vector2d(self.x-v.x, self.y-v.y)
end
function Vector2d:subtractScalar(n)
	return Vector2d(self.x-n, self.y-n)
end
function Vector2d:tcartbusScalar(n)
	return Vector2d(n-self.x, n-self.y)
end
function Vector2d:dot(v)
	return self.x * v.x + self.y*v.y
end
function Vector2d:multiplyScalar(n)
	return Vector2d(self.x*n, self.y*n)
end
function Vector2d:cross(v)
	return self.x*v.y-self.y*v.x
end
function Vector2d:divide(n)
	return Vector2d(self.x/n, self.y/n)
end
function Vector2d:edivid(n)
	return Vector2d(n/self.x, n/self.y)
end
function Vector2d:dist()
	return math.sqrt(self:dot(self))
end
function Vector2d:dSquared()
	return self:dot(self)
end
function Vector2d:norm()
	return Vector2d(self.x/self:dist(), self.y/self:dist())
end
function Vector2d:angle(v)
	if v == nil then v = Vector2d(1,0) end
	return math.atan2(self:cross(v), self:dot(v))
end
function Vector2d:stringify()
	return "<"..self.x..","..self.y..">"
end
function Vector2d:explode()
	return unpack(self)
end
function Vector2d:copy()
	return Vector2d(self.x, self.y)
end
--IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII--

function whichIsWhich(operand1, operand2)
	local type1, type2
	type1 = (getmetatable(operand1)==Vector2d) and "vec" or nil
	type2 = (getmetatable(operand2)==Vector2d) and "vec" or nil
	type1 = (type(operand1) == "number") and "scalar" or type1
	type2 = (type(operand2) == "number") and "scalar" or type2
	type1 = (type(operand1) == "string") and "string" or type1
	type2 = (type(operand2) == "string") and "string" or type2

	return type1, type2
end
function Vector2d.opHandler(op, operand1, operand2)
	if op == "unm" then
		op = "mul"
		operand2 = -1
	end
	local type1, type2 = whichIsWhich(operand1,operand2)
	if type1 == nil or type2 == nil then
		return assert(nil, "expected two arguments")
	end
	if op == "concat" then
		if type1 == type2 then
			operand1:dot(operand2)
		end
		if type1 == "vec" then
			return operand1:stringify()..operand2
		end
		return operand1..operand2:stringify()
	end
	if type1 == "string" or type2 == "string" then
		return assert(nil, "unexpected string")
	end
	if op == "add" then
		if type1 == type2 then
			return operand1:addVec(operand2)
		end
		if type1 == "vec" then
			return operand1:addScalar(operand2)
		end
		return operand2:addScalar(operand1)
	elseif op == "sub" then
		if type1 == type2 then
			return operand1:subtractVec(operand2)
		end
		if type1 == "vec" then
			return operand1:subtractScalar(operand2)
		end
		return operand2:tcartbusScalar(operand1)
	elseif op == "mul" then
		if type1 == type2 then
			return operand1:cross(operand2)
		end
		if type1 == "vec" then
			return operand1:multiplyScalar(operand2)
		end
		return operand2:multiplyScalar(operand1)
	elseif op == "div" then
		if type1 == type2 then
			return assert(nil, "expected scalar; got vector")
		end
		if type1 == "vec" then
			return operand1:divide(operand2)
		end
		return operand2:edivid(operand1)
	elseif op == "mod" then
		return assert(nil, "ain't nobody got time for that")
	elseif op == "pow" then
		return assert(nil, "ain't nobody got time for that")
	elseif op == "eq" then
		return (type1 == type2 and operand1.x == operand2.x and operand1.y == operand2.y)
	end
end
function Vector2d.unm(...)
	return Vector2d.opHandler("unm", ...)
end
function Vector2d.add(...)
	return Vector2d.opHandler("add", ...)
end
function Vector2d.sub(...)
	return Vector2d.opHandler("sub", ...)
end
function Vector2d.mul(...)
	return Vector2d.opHandler("mul", ...)
end
function Vector2d.div(...)
	return Vector2d.opHandler("div", ...)
end
function Vector2d.mod(...)
	return Vector2d.opHandler("mod", ...)
end
function Vector2d.pow(...)
	return Vector2d.opHandler("pow", ...)
end
function Vector2d.concat(...)
	return Vector2d.opHandler("concat", ...)
end
function Vector2d.eq(...)
	return Vector2d.opHandler("eq", ...)
end
Vector2d.__unm = Vector2d.unm
Vector2d.__add = Vector2d.add
Vector2d.__sub = Vector2d.sub
Vector2d.__mul = Vector2d.mul
Vector2d.__div = Vector2d.div
Vector2d.__mod = Vector2d.mod
Vector2d.__pow = Vector2d.pow
Vector2d.__concat = Vector2d.concat
Vector2d.__eq = Vector2d.eq

return Vector2d