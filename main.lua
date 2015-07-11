require "functions"

function love.load()

  world = love.physics.newWorld(0, 0, true) -- 0 horizontal gravity, 0 vertical gravity

  player = Body:new(world, 40, 40)
  player.speed, player.turning = SPEED, TURNING

  sheep = Body:new(world, 400, 400)
  sheep.body:setLinearDamping(10)

  p = getPanelData(40 ,400, 400, 40)

  panel = {}
  panel.body = love.physics.newBody(world, 0, 0)
  panel.shape = love.physics.newPolygonShape(p.x1, p.y1, p.x2, p.y2, p.x3, p.y3, p.x4, p.y4) --  screen width, 50 height
  panel.fixture = love.physics.newFixture(panel.body, panel.shape)

  otherPanel = Wall:new(world, getPanelData(40, 400, 400, 500))

  --ground
  ground = {}
  ground.body = love.physics.newBody(world, WINDOWWIDTH/2, WINDOWHEIGHT-50/2)
  ground.shape = love.physics.newRectangleShape(WINDOWWIDTH, 50) --  screen width, 50 height
  ground.fixture = love.physics.newFixture(ground.body, ground.shape) -- attach shape to body
  ground.fixture:setFriction(0)


  --initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248)
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
  love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))
  love.graphics.polygon("fill", panel.body:getWorldPoints(panel.shape:getPoints()))
  love.graphics.polygon("fill", otherPanel.body:getWorldPoints(otherPanel.shape:getPoints()))

  love.graphics.setColor(200, 200, 200)
  love.graphics.circle("fill", sheep.body:getX(), sheep.body:getY(), sheep.shape:getRadius())
  love.graphics.circle("fill", WINDOWWIDTH/2, WINDOWHEIGHT/2, 5)

end
