require "functions"
require "levels"

function love.load()
  --initial graphics setup
  love.graphics.setBackgroundColor(100, 160, 100)
  sheepImg = love.graphics.newImage('assets/sheep.png')
  playerImg = love.graphics.newImage('assets/farmer.png')

  world = love.physics.newWorld(0, 0, true)
  loadHighScores(LEVELS)

  level = 1

  time, fencePoly, player, allSheep = loadLevel(world, LEVELS[level], playerImg, sheepImg)
end

function love.update(dt)
  world:update(dt)
  updateTimer(time, allSheep, player, LEVELS[level])
  player:updatePlayer(dt)
  updateAllSheep(allSheep, player, fencePoly, dt)

  resetLevel(time, allSheep, player, LEVELS[level])

  if numberFreeSheep(allSheep) == 0 then
    if love.keyboard.isDown("n") then
      level = level + 1
      resetTime(time)
      player:resetPlayer(LEVELS[level].PLAYER_START)
      allSheep = loadSheep(world, LEVELS[level].SPAWN_COORDINATES, sheepImg)
      fencePoly = LEVELS[level].FENCE
      buildFence(world, fencePoly)
    end
  end

end

function love.draw()

  -- fence
  love.graphics.setColor(140,91,55)
  love.graphics.line(getDrawableFence(fencePoly))

  love.graphics.setColor(0,0,0)
  --display info
  love.graphics.print("Use 'w' or up to move forward, 'a' and 's' or left and right to turn, spacebar to catch the sheep", 20, 15)
  love.graphics.print(string.format("Highscore: %g seconds", LEVELS[level].highscore), 20, 60)
  love.graphics.print(string.format("Time remaining: %i", math.ceil(LEVELS[level].STARTING_TIME-time.timer)), 20, 80)
  love.graphics.print(string.format("Aries Libre: %i", numberFreeSheep(allSheep)), 20, 100)
  if not player.isAlive then
    love.graphics.print(string.format("Too slow! Caught %i", #LEVELS[level].SPAWN_COORDINATES-numberFreeSheep(allSheep)), love.graphics.getWidth()-150, 80)
    love.graphics.print("Press 'r' to restart", love.graphics.getWidth()-150, 100)
  end
  if numberFreeSheep(allSheep) == 0 then
    love.graphics.print(string.format("Caught %i sheep in %g seconds!", #allSheep, time.timer), love.graphics.getWidth()-250, 80)
    love.graphics.print("Press 'r' to restart", love.graphics.getWidth()-150, 120)
    love.graphics.print("Press 'n' to advance to the next level", love.graphics.getWidth()-250, 100)
  end

  --player
  love.graphics.draw(player.img, player.body:getX(), player.body:getY(), player.body:getAngle(),1, 1, player.img:getWidth()/ 2, player.img:getHeight() / 2)

  --sheep
  for i=1, #allSheep do
    if allSheep[i].isFree then
      love.graphics.setColor(200, 200, 200)
    else
      love.graphics.setColor(100, 200, 100)
    end
    love.graphics.draw(allSheep[i].img, allSheep[i].body:getX(), allSheep[i].body:getY(),allSheep[i].body:getAngle()+math.pi,1, 1, allSheep[i].img:getWidth()/ 2, allSheep[i].img:getHeight()/2)
  end
end

function love.keypressed(key)
  if key == " " then
    player:grabSheep(allSheep)
  end
end

function love.quit()
  love.event.quit()
  local scoreString = ""
  for i=1, #LEVELS do
    scoreString = scoreString .. tostring(LEVELS[i].highscore) .. "\n"
  end
  love.filesystem.write("scores.lua", scoreString)
end
