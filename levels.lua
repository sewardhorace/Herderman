LEVELS = {}

LEVEL1 = {
  STARTING_TIME = 10,
  PLAYER_START_X = 100,
  PLAYER_START_Y = 250,

  --sheep spawn coordinates
  SPAWN_COORDINATES = {
    {x = 400, y = 400}
  },

  --coordinates of the fence posts
  FENCE = {
    {x = 40, y = 200},
    {x = WINDOWWIDTH-40, y = 200},
    {x = WINDOWWIDTH-40, y = WINDOWHEIGHT-50},
    {x = 40, y = WINDOWHEIGHT-50}
  }
}
table.insert(LEVELS, LEVEL1)

LEVEL2 = {
  STARTING_TIME = 10,
  PLAYER_START_X = 200,
  PLAYER_START_Y = 200,

  --sheep spawn coordinates
  SPAWN_COORDINATES = {
    {x = 500, y = 505},
    {x = 400, y = 505},
    {x = 300, y = 505},
    {x = 500, y = 405},
    {x = 400, y = 405},
    {x = 300, y = 405}
  },

  --coordinates of the fence posts
  FENCE = {
    {x = 20, y = 300},
    {x = 300, y = 30},
    {x = WINDOWWIDTH-20, y = 300},
    {x = WINDOWWIDTH-20, y = WINDOWHEIGHT-50},
    {x = 300, y = WINDOWHEIGHT-20},
    {x = 20, y = 500}
  }
}
table.insert(LEVELS, LEVEL2)
