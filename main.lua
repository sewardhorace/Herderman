require "functions"
require "levels"

function love.load()
  --initial graphics setup
  love.graphics.setBackgroundColor(100, 160, 100)
  sheepImg = love.graphics.newImage('assets/sheep.png')
  playerImg = love.graphics.newImage('assets/farmer.png')

  world = love.physics.newWorld(0, 0, true) -- 0 horizontal gravity, 0 vertical gravity

  level = 2
  fencePoly = LEVELS[level].FENCE

  player = loadPlayer(world, LEVELS[level].PLAYER_START)
  player.img = playerImg

  --level start
  --level start.  build the fence, position the player and sheep, reset the timer
  buildFence(world, fencePoly)
  timer = 0
  timeStart = false

  allSheep = sheepStart(world, LEVELS[level].SPAWN_COORDINATES)
  for i=1, #allSheep do
    allSheep[i].img = sheepImg
  end

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

function love.update(dt)
  world:update(dt)
  player:playerUpdate(dt)
  updateAllSheep(allSheep, player, fencePoly, dt)

  if timeStart == false then
    --timer starts when player starts moving
    if love.keyboard.isDown('up') then
      stime = love.timer.getTime()
      timeStart = true
    end
  elseif numberFreeSheep(allSheep) > 0 and player.isAlive then
    etime = love.timer.getTime()
    timer = etime - stime
  end

  if LEVELS[level].STARTING_TIME - timer < 0 then
    timer = LEVELS[level].STARTING_TIME
    player.isAlive = false
  end

  if numberFreeSheep(allSheep) == 0 then
    if tonumber(LEVELS[level].highscore) > timer then
      LEVELS[level].highscore = timer
    end
  end


  --reset all

end

function love.draw()

  love.graphics.setColor(0,0,0)
  love.graphics.print("Use 'w' or up to move forward, 'a' and 's' or left and right to turn, spacebar to catch the sheep", 20, 15)
  love.graphics.print(string.format("Highscore: %g seconds", LEVELS[level].highscore), 20, 60)
  love.graphics.print(string.format("Time remaining: %i", math.ceil(LEVELS[level].STARTING_TIME-timer)), 20, 80)
  love.graphics.print(string.format("Aries Libre: %i", numberFreeSheep(allSheep)), 20, 100)
  if not player.isAlive then
    love.graphics.print(string.format("Too slow! Caught %i", #LEVELS[level].SPAWN_COORDINATES-numberFreeSheep(allSheep)), love.graphics.getWidth()-150, 80)
    love.graphics.print("Press 'r' to restart", love.graphics.getWidth()-150, 100)
  end
  if numberFreeSheep(allSheep) == 0 then
    love.graphics.print(string.format("Caught %i sheep in %g seconds!", #allSheep, timer), love.graphics.getWidth()-250, 80)
    love.graphics.print("Press 'r' to restart", love.graphics.getWidth()-150, 100)
  end

  --player
  --love.graphics.circle("fill", player.body:getX(), player.body:getY(), player.shape:getRadius())
  love.graphics.draw(player.img, player.body:getX(), player.body:getY(), player.body:getAngle(),1, 1, player.img:getWidth()/ 2, player.img:getHeight() / 2)

  -- fence
  love.graphics.setColor(140,91,55)
  love.graphics.line(getDrawableFence(fencePoly))

  --sheep
  --love.graphics.circle("fill", sheep.body:getX(), sheep.body:getY(), sheep.shape:getRadius())
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
