Level = Class{}

function Level:init(level)
  self.width = level.width
  self.height = level.height
  self.startLocation = level.startLocation
  self.groundTiles = level.ground

  -- Load the walls
  self.walls = {}
  for k, wall in pairs(level.walls) do
    table.insert(self.walls, wall)
  end

  -- Load the turrets
  self.turrets = {}
  for k, turret in pairs(level.turrets) do
    table.insert(self.turrets, Turret(turret.x, turret.y, turret.rotation, level))
  end

  -- Load the bases and randomly pick which one will have the flag
  self.bases = {}
  local baseWithFlag = math.random(#level.bases)
  for k, base in pairs(level.bases) do
    table.insert(self.bases, Base(base.x, base.y, k == baseWithFlag))
  end
end

function Level:update(dt)
  -- Update the turrets
  for k, turret in pairs(self.turrets) do
    turret:update(dt)
  end

  -- Update the bases
  for k, base in pairs(self.bases) do
    base:update(dt)
  end
end

function Level:render()
  -- Draw the water background first
  for y = -10, self.height + 10 do
    for x = -10, self.width + 10 do
      love.graphics.draw(gTextures['water'], gFrames['water'][1], (x - 1) * 128, (y - 1) * 128)
    end
  end

  -- Draw the ground tiles
  for y, row in pairs(self.groundTiles) do
    for x, tile in pairs(row) do
      love.graphics.draw(
        gTextures['ground'],
        gFrames['ground'][tile.texture],
        (x - 1) * 128 + 64,
        (y - 1) * 128 + 64,
        math.rad(tile.rotation),
        1, 1,
        64, 64
      )

      if IS_DEBUG then
        love.graphics.rectangle('line', (x - 1) * 128, (y - 1) * 128, 128, 128)
      end
    end
  end

  -- Draw the walls
  for k, wall in pairs(self.walls) do
    love.graphics.draw(
      gTextures['buildings'],
      gFrames['buildings']['bunker-2x1'],
      wall.rotation == 0 and wall.x or wall.x + 82,
      wall.y,
      math.rad(wall.rotation)
    )
  end

  -- Draw the turrets
  for k, turret in pairs(self.turrets) do
    turret:render()
  end

  -- Draw the bases
  for k, base in pairs(self.bases) do
    base:render()
  end
end