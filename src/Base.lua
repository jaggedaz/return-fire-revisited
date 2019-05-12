Base = Class{}

function Base:init(x, y, hasFlag)
  self.hasFlag = hasFlag
  self.x = x
  self.y = y
  self.bottomWidth = 100
  self.bottomHeight = 100
  self.topWidth = 76
  self.topHeight = 76
  self.topHOffset = 12
  self.topVOffset = 12
  self.health = 5
  self.isTweening = false
end

function Base:update(dt)

end

function Base:render()
  -- Draw the bottom
  love.graphics.draw(
    gTextures['buildings'],
    gFrames['buildings']['bunker-round-bottom'],
    self.x,
    self.y
  )

  -- Draw the top
  love.graphics.draw(
    gTextures['buildings'],
    gFrames['buildings'][self.health > 0 and 'bunker-round-top' or 'bunker-round-top-destroyed'],
    self.x + self.topHOffset,
    self.y + self.topVOffset
  )

  -- Draw the flag
  if self.hasFlag and self.health <= 0 then
    love.graphics.draw(gTextures['win'], gFrames['win'], self.x + 25, self.y + 25, 0, 0.5, 0.5)
  end
end