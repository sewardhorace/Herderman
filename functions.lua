require "class"
require "constants"

Body = class:new()
Wall = class:new()

function Body:init(world, x, y)
  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newCircleShape(30)
  self.fixture = love.physics.newFixture(self.body, self.shape)
end

function Wall:init(world, panelData)
  self.shape = love.physics.newPolygonShape(panelData.x1, panelData.y1, panelData.x2, panelData.y2,panelData.x3, panelData.y3,panelData.x4, panelData.y4 )
  self.body = love.physics.newBody(world, 0, 0)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setFriction(0)
end

function Body:getDirection(otherBody)
  return math.atan2(otherBody.body:getY() - self.body:getY(), otherBody.body:getX() - self.body:getX())
end

--levels
function getPanelData(x1, y1, x2, y2)
  --returns a table with four coordinates, to turn a the given points of a line into a polygon
  local windowCenterX, windowcCenterY = WINDOWWIDTH/2, WINDOWHEIGHT/2
  local panel = {}
  panel.x1, panel.y1, panel.x2, panel.y2 = x1, y1, x2, y2
  local angle1 = math.atan2(panel.y1 - windowcCenterY, panel.x1 - windowCenterX)
  panel.x4 = x1 + PANELWIDTH * math.cos(angle1)
  panel.y4 = y1 + PANELWIDTH * math.sin(angle1)
  local angle2 = math.atan2(panel.y2 - windowcCenterY, panel.x2 - windowCenterX)
  panel.x3 = x2 + PANELWIDTH * math.cos(angle2)
  panel.y3 = y2 + PANELWIDTH * math.sin(angle2)
  return panel
end

function buildFence(world, polygon)
  --creates the fence panels given the coordinates of a polygon
  for i=1, #polygon-1 do
    local newPanel = Wall:new(world, getPanelData(polygon[i].x, polygon[i].y, polygon[i+1].x, polygon[i+1].y))
  end
  local newPanel = Wall:new(world, getPanelData(polygon[#polygon].x, polygon[#polygon].y, polygon[1].x, polygon[1].y))
end

function getDrawableFence(polygon)
  --returns a list of points from a polygon object that love.graphics.draw() can accept
  local fence = {}
  for i=1, #polygon do
      table.insert(fence, polygon[i].x)
      table.insert(fence, polygon[i].y)
  end
  table.insert(fence, polygon[1].x)
  table.insert(fence, polygon[1].y)
  return fence
end

--player
function Body:playerUpdate(dt)
  if love.keyboard.isDown("right", "left") then
    if love.keyboard.isDown("right") then
      self.body:setAngularVelocity(self.turning*dt)
    else
      self.body:setAngularVelocity(-self.turning*dt)
    end
  else
    self.body:setAngularVelocity(0)
  end

  if love.keyboard.isDown("up") then
    self.body:setLinearVelocity(math.cos(self.body:getAngle())*(self.speed*dt), math.sin(self.body:getAngle())*(self.speed*dt))
  else
    self.body:setLinearVelocity(0,0)
  end
end

function Body:grabSheep(allSheep)
  for i=1, #allSheep do
    if love.physics.getDistance(allSheep[i].fixture, self.fixture) < 50 then
      allSheep[i].body:setActive(false)
      break
    end
  end
end

--sheep
function Body:applyImpulseForward(dt)
  self.body:applyLinearImpulse(math.cos(self.body:getAngle())*(self.speed*dt), math.sin(self.body:getAngle())*(self.speed*dt))
end

function Body:flee(otherBody, dt)
  self.body:setAngle(math.atan2(self.body:getY() - otherBody.body:getY(), self.body:getX() - otherBody.body:getX()))
  self:applyImpulseForward(dt)
end

function doesIntersect(Ax, Ay, Bx, By, Ex, Ey, Fx, Fy)
  --returns true if two lines intersect (given coordinates of endpoints)
  local cross1_1 = (Fx-Ex)*(Ay-Fy)-(Fy-Ey)*(Ax-Fx)
  local cross1_2 = (Fx-Ex)*(By-Fy)-(Fy-Ey)*(Bx-Fx)
  local cross2_1 = (Bx-Ax)*(Ey-By)-(By-Ay)*(Ex-Bx)
  local cross2_2 = (Bx-Ax)*(Fy-By)-(By-Ay)*(Fx-Bx)
  if (cross1_1 > 0 and cross1_2 > 0) or (cross1_1 < 0 and cross1_2 < 0) or (cross2_1 > 0 and cross2_2 > 0) or (cross2_1 < 0 and cross2_2 < 0) then
    return false
  else
    return true
  end
end

function Body:pathBlocked(polygon)
  --returns true if a short distance (length of radius) in front of a body intersects the boundaries of a polygon
  local path = { Ax = self.body:getX(), Ay = self.body:getY() }
  local angle = self.body:getAngle()
  local reach = self.shape:getRadius()*2
  path.Bx = path.Ax + reach * math.cos(angle)
  path.By = path.Ay + reach * math.sin(angle)
  if doesIntersect(path.Ax, path.Ay, path.Bx, path.By, polygon[1].x, polygon[1].y, polygon[#polygon].x, polygon[#polygon].y) then
    return true
  end
  for i=1, #polygon - 1 do
    if doesIntersect(path.Ax, path.Ay, path.Bx, path.By, polygon[i].x, polygon[i].y, polygon[i+1].x, polygon[i+1].y) then
      return true
    end
  end
  return false
end

function Body:getBestAngle(otherBody, polygon, dt)
  self.body:setAngle(self:getDirection(otherBody)+math.pi/2)
  if self:pathBlocked(polygon) then
    self.body:setAngle(self.body:getAngle()+math.pi)
  end
end

function Body:sheepUpdate(player, fencePoly, dt)
  if love.physics.getDistance(self.fixture, player.fixture) < 100 then
    if self:pathBlocked(fencePoly) then
      self:getBestAngle(player, fencePoly, dt)
    else
      self:applyImpulseForward(dt)
    end
  elseif love.physics.getDistance(self.fixture, player.fixture) < 150 then
    self:flee(player, dt)
  end

  function ooops(key)
    if key == " " and love.physics.getDistance(self.fixture, player.fixture) < 50 then
      if self.body:isActive() then
        self.body:setActive(false)
      end
    end
  end
end

function sheepStart(world, spawnCoordinates)
  local allSheep = {}
  for i=1, #spawnCoordinates do
    newSheep = Body:new(world, spawnCoordinates[i].x, spawnCoordinates[i].y)
    newSheep.body:setLinearDamping(10)
    newSheep.body:setAngularDamping(10)
    newSheep.fixture:setRestitution(0.9)
    newSheep.speed = SPEED
    table.insert(allSheep, newSheep)
  end
  return allSheep
end

function updateAllSheep(allSheep, player, fencePoly, dt)
  for i=1, #allSheep do
    allSheep[i]:sheepUpdate(player, fencePoly, dt)
  end
end
