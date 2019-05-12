Player = Class{}

function Player:init(level)
  self.x = (level.startLocation.x * 128) - 80
  self.y = (level.startLocation.y * 128) - 90
  self.level = level
  self.tankBaseWidth = 34
  self.tankBaseHeight = 48
  self.tankBaseHOffset = 17
  self.tankBaseVOffset = 24
  self.turretWidth = 20
  self.turretHeight = 40
  self.turretTopHOffset = 10
  self.turretTopVOffset = 28
  self.rotation = 0
  self.turretRotation = 0
  self.movementSpeed = 150
  self.rotationSpeed = 1
  self.startHealth = 10
  self.health = self.startHealth
  self.cooldown = 0.5
  self.cooldownRemaining = 0
  self.rockets = {}
  self.animations = {}
  self.flagFound = false
  self.firingEnabled = false

  self.movementSound = gSounds['engine']
  self.movementSound:setLooping(true)
  self.movementSound:setPitch(0.25)
  self.movementSound:setVolume(0.1)
  self.turretRotationSound = self.movementSound:clone()

  gSounds['hit']:setVolume(0.5)
  gSounds['explosion']:setVolume(0.5)

  -- Disable firing when we first load so that we don't start
  -- firing if they hit space to start the game
  Timer.after(2, function() self.firingEnabled = true end)
end

function Player:update(dt)
  Timer.update(dt)

  if self.health <= 0 then
    self.movementSound:stop()
    self.turretRotationSound:stop()
  else
    if (love.keyboard.isDown('w') or love.keyboard.isDown('s')
    or love.keyboard.isDown('a') or love.keyboard.isDown('d'))
    and not self.flagFound then
      self.movementSound:play()
    else
      self.movementSound:stop()
    end

    if (love.keyboard.isDown('q') or love.keyboard.isDown('e')) and not self.flagFound then
      self.turretRotationSound:play()
    else
      self.turretRotationSound:stop()
    end

    if love.keyboard.isDown('w') or love.keyboard.isDown('s') then
      local toX, toY = self.x, self.y
  
      if love.keyboard.isDown('w') then
        toX = toX + math.sin(self.rotation) * self.movementSpeed * dt
        toY = toY + (-math.cos(self.rotation) * self.movementSpeed) * dt
      elseif love.keyboard.isDown('s') then
        toX = toX - math.sin(self.rotation) * self.movementSpeed * dt
        toY = toY - (-math.cos(self.rotation) * self.movementSpeed) * dt
      end
      
      if not self:checkMovementCollision(toX, toY) then
        self.x = toX
        self.y = toY
      end
    end
  
    if love.keyboard.isDown('a') then
      self.rotation = self.rotation - self.rotationSpeed * dt
      self.turretRotation = self.turretRotation - self.rotationSpeed * dt
    elseif love.keyboard.isDown('d') then
      self.rotation = self.rotation + self.rotationSpeed * dt
      self.turretRotation = self.turretRotation + self.rotationSpeed * dt
    end
  
    if love.keyboard.isDown('q') then
      self.turretRotation = self.turretRotation - self.rotationSpeed * dt
    elseif love.keyboard.isDown('e') then
      self.turretRotation = self.turretRotation + self.rotationSpeed * dt
    end
  
    if self.firingEnabled and love.keyboard.isDown('space') and self.cooldownRemaining <= 0 then
      table.insert(self.rockets, Rocket(
        self.x + (self.tankBaseWidth / 2) + math.sin(self.turretRotation) * 35,
        self.y + (-math.cos(self.turretRotation)) * 35,
        self.turretRotation
      ))

      local fireRocketSound = gSounds['fire-rocket']:clone()
      fireRocketSound:setPitch(0.25)
      fireRocketSound:setVolume(0.1)
      fireRocketSound:play()

      self.cooldownRemaining = self.cooldown
    end
  end

  for i = #self.rockets, 1, -1 do
    local rocket = self.rockets[i]

    -- Check if rocket collided with a turret
    for k, turret in pairs(self.level.turrets) do
      if turret.health > 0 and rocket:collidesWith(turret.x, turret.y, turret.topHeight, turret.topHeight) then
        table.remove(self.rockets, i)
        turret.health = math.max(0, turret.health - 1)
        if turret.health > 0 then
          gSounds['hit']:clone():play()
          table.insert(self.animations, Animation(
            turret.x + ((turret.topWidth - 32) / 2) + turret.turretTopHOffset,
            turret.y + ((turret.topHeight - 32) / 2) + turret.turretTopVOffset,
            'explosions',
            'hit',
            0.1
          ))
        else
          gSounds['explosion']:clone():play()
          table.insert(self.animations, Animation(
            turret.x + ((turret.topWidth - 64) / 2) + turret.turretTopHOffset,
            turret.y + ((turret.topHeight - 64) / 2) + turret.turretTopVOffset,
            'explosions',
            'explosion-1',
            0.1
          ))
        end
        goto continue
      end
    end

    -- Check if rocket collided with a base
    for k, base in pairs(self.level.bases) do
      if base.health > 0 and rocket:collidesWith(base.x, base.y, base.topWidth, base.topHeight) then
        table.remove(self.rockets, i)
        base.health = math.max(0, base.health - 1)
        if base.health > 0 then
          gSounds['hit']:clone():play()
          table.insert(self.animations, Animation(
            base.x + ((base.bottomWidth - 64) / 2),
            base.y + ((base.bottomHeight - 64) / 2),
            'explosions',
            'explosion-1',
            0.1
          ))
        else
          gSounds['explosion']:clone():play()
          table.insert(self.animations, Animation(
            base.x + ((base.bottomWidth - 96) / 2),
            base.y + ((base.bottomHeight - 96) / 2),
            'explosions',
            'explosion-2',
            0.1
          ))

          -- if the base contains the flag, change to the win state
          if base.hasFlag then
            self.flagFound = true
            gSounds['music']:stop()
            gSounds['flag-reveal']:play()
            Timer.after(12, function()
              gStateMachine:change('win')
            end)
          end
        end
        goto continue
      end
    end

    -- Remove rockets that have left the map
    if rocket.x < 0 or rocket.x > self.level.width * 128
    or rocket.y < 0 or rocket.y > self.level.height * 128 then
      table.remove(self.rockets, i)
      goto continue
    end
    
    -- Update any rockets that have not already been dealt with
    rocket:update(dt)

    ::continue::
  end

  -- Remove any completed animations and update the remaining ones
  for i = #self.animations, 1, -1 do
    local animation = self.animations[i]
    if animation.currentFrame > #animation.frames then
      table.remove(self.animations, i)
    else
      animation:update(dt)
    end
  end

  self.cooldownRemaining = math.max(0, self.cooldownRemaining - dt)
end

function Player:render()
  -- Draw the tank base
  love.graphics.draw(
    gTextures['ground-units'],
    gFrames['ground-units'][self.health > 0 and 'tank-base' or 'tank-base-destroyed'],
    self.x + self.tankBaseHOffset,
    self.y + self.tankBaseVOffset,
    self.rotation,
    1, 1,
    self.tankBaseHOffset, self.tankBaseVOffset
  )

  -- Draw the turret
  love.graphics.draw(
    gTextures['ground-units'],
    gFrames['ground-units'][self.health > 0 and 'tank-turret' or 'tank-turret-destroyed'],
    math.floor(self.x + (self.tankBaseWidth / 2) - (self.turretWidth / 2) + self.turretTopHOffset),
    math.floor(self.y + self.turretTopVOffset - 5),
    self.turretRotation,
    1, 1,
    self.turretTopHOffset, self.turretTopVOffset
  )

  -- Draw the rockets
  for k, rocket in pairs(self.rockets) do
    rocket:render()
  end

  -- Draw the animations
  for k, animation in pairs(self.animations) do
    animation:render()
  end

  if IS_DEBUG then
    love.graphics.circle('fill', self.x + self.tankBaseHOffset, self.y + self.tankBaseVOffset, 3)
    love.graphics.rectangle('line', self.x - (self.tankBaseHeight - self.tankBaseWidth) / 2, self.y, self.tankBaseHeight, self.tankBaseHeight)
  end
end

function Player:checkMovementCollision(toX, toY)
  local objectBuffer = 15
  local landBuffer = 50

  -- Check for collisions with walls
  for k, wall in pairs(self.level.walls) do
    if CheckCollision(
      toX - ((self.tankBaseHeight - self.tankBaseWidth) / 2) + objectBuffer,
      toY + objectBuffer,
      self.tankBaseHeight - (objectBuffer * 2),
      self.tankBaseHeight - (objectBuffer * 2),
      wall.x,
      wall.y,
      wall.rotation == 0 and 192 or 82,
      wall.rotation == 0 and 82 or 192
    ) then
      return true
    end
  end

  -- Check for collisions with bases
  for k, base in pairs(self.level.bases) do
    if CheckCollision(
      toX - ((self.tankBaseHeight - self.tankBaseWidth) / 2) + objectBuffer,
      toY + objectBuffer,
      self.tankBaseHeight - (objectBuffer * 2),
      self.tankBaseHeight - (objectBuffer * 2),
      base.x + base.topHOffset,
      base.y + base.topVOffset,
      base.topWidth,
      base.topHeight
    ) then
      return true
    end
  end

  -- Check for collisions with ground tiles other than land
  for y, row in pairs(self.level.groundTiles) do
    for x, tile in pairs(row) do
      if tile.texture ~= 'grass' and tile.texture ~= 'beach-dn' then
        if CheckCollision(
          toX - ((self.tankBaseHeight - self.tankBaseWidth) / 2) + landBuffer,
          toY + landBuffer,
          self.tankBaseHeight - (landBuffer * 2),
          self.tankBaseHeight - (landBuffer * 2),
          (x - 1) * 128,
          (y - 1) * 128,
          128,
          128
        ) then
          return true
        end
      end
    end
  end
end