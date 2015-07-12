require "functions"
require "levels"

function love.load()
  --initial graphics setup
  love.graphics.setBackgroundColor(100, 160, 100)
  sheepImg = love.graphics.newImage('assets/sheep.png')
  playerImg = love.graphics.newImage('assets/farmer.png')

  world = love.physics.newWorld(0, 0, true) -- 0 horizontal gravity, 0 vertical gravity

  player = Body:new(world, WINDOWWIDTH/2, WINDOWHEIGHT/2)
  player.speed, player.turning = SPEED, TURNING
  player.isAlive = true --unused
  player.img = playerImg

  level = 2

  fencePoly = LEVELS[level].FENCE
  buildFence(world, fencePoly)

  allSheep = sheepStart(world, LEVELS[level].SPAWN_COORDINATES)
  for i=1, #allSheep do
    allSheep[i].img = sheepImg
  end


end

function love.update(dt)
  world:update(dt)
  player:playerUpdate(dt)
  updateAllSheep(allSheep, player, fencePoly, dt)

end

function love.draw()

  love.graphics.setColor(0,0,0)
  --player
  --love.graphics.circle("fill", player.body:getX(), player.body:getY(), player.shape:getRadius())
  love.graphics.draw(player.img, player.body:getX(), player.body:getY(), player.body:getAngle(),1, 1, player.img:getWidth()/ 2, player.img:getHeight() / 2)

  -- fence
  love.graphics.setColor(140,91,55)
  love.graphics.line(getDrawableFence(fencePoly))

  --sheep
  love.graphics.setColor(200, 200, 200)
  --love.graphics.circle("fill", sheep.body:getX(), sheep.body:getY(), sheep.shape:getRadius())
  for i=1, #allSheep do
    love.graphics.draw(allSheep[i].img, allSheep[i].body:getX(), allSheep[i].body:getY(),allSheep[i].body:getAngle()+math.pi,1, 1, allSheep[i].img:getWidth()/ 2, allSheep[i].img:getHeight()/2)
  end

end

function love.keypressed(key)
  if key == " " then
    player:grabSheep(allSheep)
  end
end
