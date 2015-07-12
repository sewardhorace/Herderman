require "constants"

-- Configuration
function love.conf(t)
  t.title = "Herderman" -- the title of the window the game is in (string)
  t.identity = "herderman"
  t.version = "0.9.2"
  t.window.width = WINDOWWIDTH
  t.window.height = WINDOWHEIGHT

  t.modules.joystick = false

end
