require "functions"
require "levels"

function love.load()

  world = love.physics.newWorld(0, 0, true) -- 0 horizontal gravity, 0 vertical gravity

  player = Body:new(world, WINDOWWIDTH/2, WINDOWHEIGHT/2)
  player.speed, player.turning = SPEED, TURNING

  sheep = Body:new(world, 400, 400)
  sheep.body:setLinearDamping(10)


  fencePoly = LEVELS[1].FENCE
  buildFence(world, fencePoly)
  --panel = Wall:new(world, getPanelData(40 ,400, 400, 40))
  --otherPanel = Wall:new(world, getPanelData(40, 400, 400, 500))

  --initial graphics setup
  love.graphics.setBackgroundColor(100, 160, 100)
  love.window.setMode(WINDOWWIDTH, WINDOWHEIGHT)

end

function love.update(dt)
  world:update(dt)
  player:playerUpdate(dt)
  time = dt
end

function love.draw()

  love.graphics.setColor(0,0,0)
  love.graphics.circle("fill", player.body:getX(), player.body:getY(), player.shape:getRadius())
  love.graphics.print(time, 20, 20);
  love.graphics.print(sheep:getDirection(player), 20, 40)

  -- ground
  love.graphics.setColor(140,91,55)
  --love.graphics.polygon("fill", panel.body:getWorldPoints(panel.shape:getPoints()))
  --love.graphics.polygon("fill", otherPanel.body:getWorldPoints(otherPanel.shape:getPoints()))
  love.graphics.line(getDrawableFence(fencePoly))

  love.graphics.setColor(200, 200, 200)
  love.graphics.circle("fill", sheep.body:getX(), sheep.body:getY(), sheep.shape:getRadius())

end
