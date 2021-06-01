local function lineIntersect(a, r, c, d, isInfite)
  local s = (d - c)
  local D = r.x * s.y - r.y * s.x
  local u = ((c.x - a.x) * r.y - (c.y - a.y) * r.x) / D
  local t = ((c.x - a.x) * s.y - (c.y - a.y) * s.x) / D
  if not isInfite then
    return (0 <= u and u <= 1 and 0 <= t and t <= 1) and a + r * t
  else
    return (0 <= u and u <= 1 and 0 <= t) and a + r * t
  end
end

local function dist(A, B)
  return ((A.x-B.x)^2 + (A.y-B.y)^2)^0.5
end

return function(origin, dir, edges, isInfite)
  local intersectPoint = nil
  for _, edge in ipairs(edges) do
    local point = lineIntersect(origin, dir, edge[1], edge[2], isInfite)
    if  point
    and (not intersectPoint or dist(intersectPoint, origin) > dist(point, origin)) then
      intersectPoint = point
    end
  end

  return intersectPoint
end
