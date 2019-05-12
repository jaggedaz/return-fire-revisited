Rocket = Class{}

function Rocket:init(x, y, rotation)
  self.x = x
  self.y = y
  self.rotation = rotation
  self.movementSpeed = 250
  self.width = 9
  self.height = 43
  self.hOffset = math.floor(self.width / 2)
  self.vOffset = math.floor(self.height / 2)
end

function Rocket:update(dt)
  self.x = self.x + math.sin(self.rotation) * self.movementSpeed * dt
  self.y = self.y + (-math.cos(self.rotation)) * self.movementSpeed * dt
end

function Rocket:render()
  love.graphics.draw(
    gTextures['rocket'],
    gFrames['rocket'],
    math.floor(self.x - (self.width / 2) + self.hOffset),
    math.floor(self.y + self.vOffset),
    self.rotation,
    1, 1,
    self.hOffset, self.vOffset
  )

  if IS_DEBUG then
    love.graphics.rectangle('line', self.x - self.height / 2, self.y, self.height, self.height)
  end
end

function Rocket:collidesWith(targetX, targetY, targetWidth, targetHeight)
  return CheckCollision(
    self.x - self.height / 2,
    self.y,
    self.height,
    self.height,
    targetX,
    targetY,
    targetWidth,
    targetHeight
  )
end