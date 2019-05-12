Animation = Class{}

function Animation:init(x, y, texture, frames, interval)
  self.x = x
  self.y = y
  self.texture = texture
  self.frames = frames
  self.interval = interval
  self.timer = 0
  self.currentFrame = 1
end

function Animation:update(dt)
  self.timer = self.timer + dt

  if self.timer > self.interval then
    self.timer = self.timer % self.interval
    self.currentFrame = self.currentFrame + 1
  end
end

function Animation:render()
  if self.currentFrame <= #self.frames then
    love.graphics.draw(
      gTextures[self.texture],
      gFrames[self.texture][self.frames][self.currentFrame],
      self.x,
      self.y
    )
  end
end