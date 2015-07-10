require "functions"

function love.load()
  world = love.physics.newWorld(0, 0, true) -- 0 horizontal gravity, 0 vertical gravity

  SPEED = 20000
  TURNING = 700

  player = Body:new(world, 40, 40)
  player.speed, player.turning = SPEED, TURNING

  sheep = Body:new(world, 400, 400)
  sheep.body:setLinearDamping(10)


  objects = {}

  --ground
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, 650/2, 650-50/2)
  objects.ground.shape = love.physics.newRectangleShape(650, 50) -- 650 wide, 50 height
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) -- attach shape to body
  objects.ground.fixture:setFriction(0)

  --initial graphics setup
  love.graphics.setBackgroundColor(104, 136, 248)
  love.window.setMode(650, 650)

end

function love.update(dt)
  world:update(dt)
  player:playerUpdate(dt)
  time = dt
end

function love.draw()

  love.graphics.print(time, 20, 20);
  love.graphics.print(sheep:getDirection(player), 20, 40)

  -- ground
  love.graphics.setColor(72,160,14)
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))

  love.graphics.setColor(0,0,0)
  love.graphics.circle("fill", player.body:getX(), player.body:getY(), player.shape:getRadius())

  love.graphics.setColor(193, 47, 14)
  love.graphics.circle("fill", sheep.body:getX(), sheep.body:getY(), sheep.shape:getRadius())

end
