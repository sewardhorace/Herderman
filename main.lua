require "functions"
require "levels"

function love.load()
  --initial graphics setup
  love.graphics.setBackgroundColor(100, 160, 100)
  love.window.setMode(WINDOWWIDTH, WINDOWHEIGHT)

  world = love.physics.newWorld(0, 0, true) -- 0 horizontal gravity, 0 vertical gravity

  fencePoly = LEVELS[1].FENCE
  buildFence(world, fencePoly)

  player = Body:new(world, WINDOWWIDTH/2, WINDOWHEIGHT/2)
  player.speed, player.turning = SPEED, TURNING

  sheep = Body:new(world, 400, 400)
  sheep.body:setLinearDamping(10)
  sheep.body:setAngularDamping(10)
  sheep.fixture:setRestitution(0.9)
  sheep.speed = SPEED

  player.img = love.graphics.newImage('assets/farmer.png')
  sheep.img = love.graphics.newImage('assets/sheep.png')
end

function love.update(dt)
  world:update(dt)
  player:playerUpdate(dt)

  if love.physics.getDistance(sheep.fixture, player.fixture) < 100 then
    if sheep:pathBlocked(fencePoly) then
      sheep:getBestAngle(player, fencePoly, dt)
    else
      sheep:applyImpulseForward(dt)
    end
  elseif love.physics.getDistance(sheep.fixture, player.fixture) < 150 then
    sheep:flee(player, dt)
  end

end

function love.draw()

  love.graphics.setColor(0,0,0)
  love.graphics.print(sheep.speed, 20, 20)
  --player
  --love.graphics.circle("fill", player.body:getX(), player.body:getY(), player.shape:getRadius())
  love.graphics.draw(player.img, player.body:getX(), player.body:getY(), player.body:getAngle(),1, 1, player.img:getWidth()/ 2, player.img:getHeight() / 2)

  -- fence
  love.graphics.setColor(140,91,55)
  love.graphics.line(getDrawableFence(fencePoly))

  --sheep
  love.graphics.setColor(200, 200, 200)
  --love.graphics.circle("fill", sheep.body:getX(), sheep.body:getY(), sheep.shape:getRadius())
  love.graphics.draw(sheep.img, sheep.body:getX(), sheep.body:getY(),sheep.body:getAngle()+math.pi,1, 1, sheep.img:getWidth()/ 2, sheep.img:getHeight()/2)


end
