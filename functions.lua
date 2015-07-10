require "class"

Body = class:new()

function Body:init(world, x, y)
  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newCircleShape(30)
  self.fixture = love.physics.newFixture(self.body, self.shape)
end

function Body:getDirection(otherBody)
  return math.atan2(otherBody.body:getY() - self.body:getY(), otherBody.body:getX() - self.body:getX())
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
