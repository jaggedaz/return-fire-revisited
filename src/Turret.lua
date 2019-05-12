Turret = Class{}

function Turret:init(x, y, rotation, level)
  self.x = x
  self.y = y
  self.bottomRotation = rotation
  self.topRotation = math.rad(rotation)
  self.level = level
  self.health = 3
  self.rotationSpeed = 0.25
  self.targetingRange = 800
  self.bottomWidth = 58
  self.bottomHeight = 46
  self.topWidth = 32
  self.topHeight = 54
  self.turretTopHOffset = 13
  self.turretTopVOffset = -4
  self.targetRotation = math.rad(rotation)
  self.cooldown = 2
  self.cooldownRemaining = 0
  self.rockets = {}
end

function Turret:update(dt)
  if self.health > 0 then
    -- Rotate top towards target rotation value
    local angleDifference = (self.targetRotation - self.topRotation + math.pi) % (2 * math.pi) - math.pi
    self.topRotation = self.topRotation + dt * angleDifference

    -- Update cooldown
    self.cooldownRemaining = math.max(0, self.cooldownRemaining - dt)
  end

  -- Remove rockets that have left the map and update the remaining ones
  for i = #self.rockets, 1, -1 do
    local rocket = self.rockets[i]
    if rocket.x < 0 or rocket.x > self.level.width * 128
    or rocket.y < 0 or rocket.y > self.level.height * 128 then
      table.remove(self.rockets, i)
    else
      rocket:update(dt)
    end
  end
end

function Turret:render()
  -- Draw the turret base
  love.graphics.draw(
    gTextures['buildings'],
    gFrames['buildings']['platform'],
    math.floor(self.x + (self.bottomWidth / 2)),
    math.floor(self.y + (self.bottomHeight / 2)),
    math.rad(self.bottomRotation),
    1, 1,
    math.floor(self.bottomWidth / 2), math.floor(self.bottomHeight / 2)
  )

  -- Draw the turret top
  love.graphics.draw(
    gTextures['buildings'],
    gFrames['buildings'][self.health > 0 and 'platform-gun' or 'platform-gun-destroyed'],
    math.floor(self.x + (self.topWidth / 2) + self.turretTopHOffset),
    math.floor(self.y + (self.topHeight / 2) + self.turretTopVOffset),
    self.topRotation,
    1, 1,
    math.floor(self.topWidth / 2), math.floor(self.topHeight / 2)
  )

  -- Draw the rockets
  for k, rocket in pairs(self.rockets) do
    rocket:render()
  end

  if IS_DEBUG then
    love.graphics.setColor(255, 0, 0)
    love.graphics.circle(
      'fill',
      self.x + (self.topWidth / 2) + self.turretTopHOffset,
      self.y + (self.topHeight / 2) + self.turretTopVOffset,
      3
    )
    love.graphics.rectangle(
      'line',
      self.x - (self.targetingRange / 2) + (self.topWidth / 2) + self.turretTopHOffset,
      self.y - (self.targetingRange / 2) + (self.topHeight / 2) + self.turretTopVOffset,
      self.targetingRange,
      self.targetingRange
    )
    love.graphics.setColor(255, 255, 255)
  end
end

function Turret:isTargetInRange(targetX, targetY, targetWidth, targetHeight)
  return CheckCollision(
    self.x - (self.targetingRange / 2) + (self.topWidth / 2) + self.turretTopHOffset,
    self.y - (self.targetingRange / 2) + (self.topHeight / 2) + self.turretTopVOffset,
    self.targetingRange,
    self.targetingRange,
    targetX,
    targetY,
    targetWidth,
    targetHeight
  )
end

function Turret:aimAt(targetX, targetY)
  self.targetRotation = math.atan2(targetY - (self.y + 27 + self.turretTopVOffset), targetX - (self.x + 16 + self.turretTopHOffset)) - math.rad(90)
end

function Turret:fire()
  if self.cooldownRemaining <= 0 and self.health > 0 then
    -- Don't fire unless the turret is pretty close to being pointed at the target
    local angleDifferenceAbs = math.abs((self.targetRotation - self.topRotation + math.pi) % (2 * math.pi) - math.pi)
    if angleDifferenceAbs <= 0.15 then
      table.insert(self.rockets, Rocket(
        self.x + (self.topWidth / 2) + self.turretTopHOffset + (-math.sin(self.topRotation) * 35),
        self.y + math.cos(self.topRotation) * 35,
        self.topRotation + math.rad(180)
      ))

      local fireRocketSound = gSounds['fire-rocket']:clone()
      fireRocketSound:setPitch(0.35)
      fireRocketSound:setVolume(0.05)
      fireRocketSound:play()

      self.cooldownRemaining = self.cooldown
    end
  end
end