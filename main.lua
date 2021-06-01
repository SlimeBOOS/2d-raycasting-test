function Vector2(x, y)
  local self = {}
  self.x = x or 0
  self.y = y or 0

  self.__add = function(a, b)
    if type(b) == "number" then
      return Vector2(a.x+b, a.y+b)
    else
      return Vector2(a.x+b.x, a.y+b.y)
    end
  end

  self.__sub = function(a, b)
    if type(b) == "number" then
      return Vector2(a.x - b, a.y - b)
    else
      return Vector2(a.x-b.x, a.y-b.y)
    end
  end

  self.__mul = function(a, b)
    if type(b) == "number" then
      return Vector2(a.x * b, a.y * b)
    end
  end

  self.normalized = function(v)
    local mag = v:mag()
    if mag == 0 then return Vector2() end
    return Vector2(v.x/mag, v.y/mag)
  end

  self.angle = function(v)
    return math.atan2(v.y, v.x)
  end

  self.setAngle = function(v, angle)
    local mag = v:mag()
    return Vector2(mag * math.cos(angle), mag * math.sin(angle))
  end

  self.mag = function(v)
    return (v.x^2 + v.y^2)^0.5
  end

  self.__tostring = function(v)
    return string.format("Vector2(%.4f,%.4f)", v.x, v.y)
  end
  setmetatable(self, self)
  return self
end

function rgba(r, g, b, a)
  return r/255, g/255, b/255, a or 1
end

local rayEngine = require("RaycastEngine")
local rayOrigin = Vector2(20, 20)
local rayDir    = Vector2(0, 35)
local polygons  = {}
local distList = {}
local detail = love.graphics.getWidth()
local walkSpeed = 100
local turnSpeed = 2.25
local viewAngle = math.pi*0.45


function printTable(t,depth)
  depth = depth or 0
  for k,v in pairs(t) do
    if type(v) == "table" and not v.x then
      print(string.rep("  ", depth)..k, "table:")
      printTable(v,depth+1)
    else
      print(string.rep("  ", depth)..k, tostring(v))
    end
  end
end

function getPolygonsEdges(points)
  local edges = {}
  for i=1,#points-2, 2 do
    table.insert(edges, {Vector2(points[i], points[i+1]), Vector2(points[i+2], points[i+3])})
  end
  return edges
end

function raycast()
  for i=0, detail do
    local angle = rayDir:angle() + (i-detail/2) * (viewAngle/detail)
    local point = rayEngine(rayOrigin, rayDir:setAngle(angle), allEdges, true)
    if point then
      distList[i] = (rayOrigin - point):mag()
    else
      distList[i] = -1
    end
  end
end

function love.load()
  table.insert(polygons, {100, 100, 150, 100, 150, 150, 100, 150, 50, 50, 100, 100})

  allEdges = {}
  -- Get all edges
  for _, polygon in ipairs(polygons) do
    for _, edge in ipairs(getPolygonsEdges(polygon)) do
      table.insert(allEdges, edge)
    end
  end
  raycast()
end

function love.update(dt)
  local d = (love.keyboard.isDown("e") and 1 or 0) - (love.keyboard.isDown("q") and 1 or 0)
  local m = (love.keyboard.isDown("w") and 1 or 0) - (love.keyboard.isDown("s") and 1 or 0)
  rayDir = rayDir:setAngle(rayDir:angle()+d*turnSpeed*dt)
  local ray = rayEngine(rayOrigin, rayDir*m*dt*walkSpeed, allEdges, true)
  if m ~= 0 and (not ray or (rayOrigin-ray):mag() > 5) then
    rayOrigin = rayOrigin + rayDir:normalized() * dt * m * walkSpeed
  end
  raycast()
end


function love.draw()
  love.graphics.setColor(rgba(80,80,80))
  love.graphics.rectangle("fill", 0,love.graphics.getHeight()/2, love.graphics.getWidth(), love.graphics.getHeight()/2)
  
  -- Draw world point
  
  local h = love.graphics.getHeight()
  local step = love.graphics.getWidth()/detail
  for i, dist in pairs(distList) do
    if dist > 0 then
      love.graphics.setColor(rgba(200, 10, 10))
      local height = (1/dist)*5000
      love.graphics.rectangle("fill", i*step, (h-height)/2, step, height) 
     end
  end

  
  love.graphics.setScissor(0,0,200,200)
  love.graphics.clear()

  love.graphics.setColor(1,1,1)
  love.graphics.rectangle("line",0,0,200,200)
  love.graphics.circle("fill", rayOrigin.x, rayOrigin.y, 5)
  local n1 = rayDir:setAngle(rayDir:angle() - viewAngle/2)
  local n2 = rayDir:setAngle(rayDir:angle() + viewAngle/2)

  love.graphics.line(rayOrigin.x, rayOrigin.y, rayOrigin.x+n1.x, rayOrigin.y+n1.y)
  love.graphics.line(rayOrigin.x, rayOrigin.y, rayOrigin.x+n2.x, rayOrigin.y+n2.y)

  love.graphics.setColor(rgba(200, 10, 10))
  for _, poly in pairs(polygons) do
    love.graphics.line(poly)
  end

  love.graphics.setScissor()
end