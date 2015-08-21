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
function loadHighScores(LEVELS)
  if not love.filesystem.exists("scores.lua") then
    local startingScores = ""
    for i=1, #LEVELS do
      startingScores = startingScores .. tostring(LEVELS[i].STARTING_TIME) .. "\n"
    end
    love.filesystem.write("scores.lua", startingScores)
  end
  --populate highscores
  local highscores = {}
  for lines in love.filesystem.lines("scores.lua") do
    table.insert(highscores, lines)
  end
  for i=1, #LEVELS do
    LEVELS[i].highscore = tonumber(highscores[i])
  end
end

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

function resetTime(time)
  time.timer = 0
  time.timeStart = false
end

function loadLevel(world, level, playerImg, sheepImg)
  --set time
  local time = {}
  time.timer = 0
  time.timeStart = false

  --construct level
  local fencePoly = level.FENCE
  buildFence(world, fencePoly)

  player = loadPlayer(world, level.PLAYER_START, playerImg)

  allSheep = loadSheep(world, level.SPAWN_COORDINATES, sheepImg)

  return time, fencePoly, player, allSheep
end

function resetLevel(time, allSheep, player, level)
  if not player.isAlive or numberFreeSheep(allSheep) == 0 then
    if love.keyboard.isDown("r") then
      resetTime(time)
      player:resetPlayer(level.PLAYER_START)
      resetAllSheep(allSheep, level.SPAWN_COORDINATES)
    end
  end
end

function updateTimer(time, allSheep, player, level)
  if time.timeStart == false then
    --timer starts when player starts moving
    if love.keyboard.isDown('up') then
      time.stime = love.timer.getTime()
      time.timeStart = true
    end
  elseif numberFreeSheep(allSheep) > 0 and player.isAlive then
    time.etime = love.timer.getTime()
    time.timer = time.etime - time.stime
  end

  if level.STARTING_TIME - time.timer < 0 then
    time.timer = level.STARTING_TIME
    player.isAlive = false
  end

  if numberFreeSheep(allSheep) == 0 then
    if tonumber(level.highscore) > time.timer then
      level.highscore = time.timer
    end
  end
end

--player
function loadPlayer(world, spawnCoordinates, img)
  local player = Body:new(world, spawnCoordinates.X, spawnCoordinates.Y)
  player.speed, player.turning = SPEED, TURNING
  player.isAlive = true
  player.img = img
  return player
end

function Body:resetPlayer(spawnCoordinates)
  self.isAlive = true
  self.body:setAngle(0)
  self.body:setPosition(spawnCoordinates.X, spawnCoordinates.Y)
end

function Body:updatePlayer(dt)
  if player.isAlive then
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
end

function Body:grabSheep(allSheep)
  for i=1, #allSheep do
    if love.physics.getDistance(allSheep[i].fixture, self.fixture) < 50 and allSheep[i].isFree then
      --allSheep[i].body:setActive(false)
      allSheep[i].isFree = false
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

function Body:updateSheep(player, fencePoly, dt)
  if love.physics.getDistance(self.fixture, player.fixture) < 100 then
    if self:pathBlocked(fencePoly) then
      self:getBestAngle(player, fencePoly, dt)
    else
      self:applyImpulseForward(dt)
    end
  elseif love.physics.getDistance(self.fixture, player.fixture) < 150 then
    self:flee(player, dt)
  end
end

function loadSheep(world, spawnCoordinates, img)
  local allSheep = {}
  for i=1, #spawnCoordinates do
    newSheep = Body:new(world, spawnCoordinates[i].x, spawnCoordinates[i].y)
    newSheep.body:setLinearDamping(10)
    newSheep.body:setAngularDamping(10)
    newSheep.fixture:setRestitution(0.9)
    newSheep.speed = SPEED
    newSheep.isFree = true
    newSheep.img = img
    table.insert(allSheep, newSheep)
  end
  return allSheep
end

function Body:resetSheep(spawnCoordinates)
  self.isFree = true
  self.body:setAngle(0)
  self.body:setPosition(spawnCoordinates.x, spawnCoordinates.y)
end

function resetAllSheep(allSheep, spawnCoordinates)
  for i=1, #allSheep do
    allSheep[i]:resetSheep(spawnCoordinates[i])
  end
end

function updateAllSheep(allSheep, player, fencePoly, dt)
  for i=1, #allSheep do
    if allSheep[i].isFree then
      allSheep[i]:updateSheep(player, fencePoly, dt)
    end
  end
end

function numberFreeSheep(allSheep)
  local count = 0
  for i=1, #allSheep do
    if allSheep[i].isFree then
      count = count + 1
    end
  end
  return count
end
