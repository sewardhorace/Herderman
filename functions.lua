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
  local panel = {}
  local windowCenterX, windowcCenterY = WINDOWWIDTH/2, WINDOWHEIGHT/2
  panel.x1, panel.y1, panel.x2, panel.y2 = x1, y1, x2, y2
  local angle1 = math.atan2(panel.y1 - windowcCenterY, panel.x1 - windowCenterX)
  panel.x4 = x1 + PANELWIDTH * math.cos(angle1)
  panel.y4 = y1 + PANELWIDTH * math.sin(angle1)
  local angle2 = math.atan2(panel.y2 - windowcCenterY, panel.x2 - windowCenterX)
  panel.x3 = x2 + PANELWIDTH * math.cos(angle2)
  panel.y3 = y2 + PANELWIDTH * math.sin(angle2)
  return panel
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

  if love.keyboard.isDown(" ") then
    self.body:setPosition(650/2, 650/2)
    self.body:setLinearVelocity(0,0)
  end
end
