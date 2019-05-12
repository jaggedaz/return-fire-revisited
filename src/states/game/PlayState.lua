PlayState = Class{__includes = BaseState}

function PlayState:init()
  -- self.isZooming = false
  self.animations = {}

  gSounds['tank-hit']:setVolume(0.2)
  gSounds['tank-explosion']:setVolume(0.5)
end

function PlayState:enter(params)
  self.livesRemaining = params.livesRemaining

  -- Load the level
  if params.level then
    self.level = params.level
  else
    local levelDef = love.filesystem.load('levels/level1.lua')()
    self.level = Level(levelDef)
  end

  -- Start playing the music
  gSounds['music']:setLooping(true)
  gSounds['music']:setVolume(0.8)
  gSounds['music']:play()

  -- Load the player
  self.player = Player(self.level)

  -- Initialize the camera
  self.camera = Camera(0, 0)
end

function PlayState:update(dt)
  Timer.update(dt)

  self.level:update(dt)
  self.player:update(dt)
  
  -- If the player is within range of any turrets, aim the turret and fire
  if self.player.health > 0 then
    for k, turret in pairs(self.level.turrets) do
      if turret:isTargetInRange(
        self.player.x, self.player.y,
        self.player.tankBaseWidth, self.player.tankBaseHeight
      ) then
        turret:aimAt(self.player.x + self.player.tankBaseHOffset, self.player.y + self.player.tankBaseVOffset)
        if not self.player.flagFound then
          turret:fire()
        end
      end
    end
  end

  -- Check if rockets fired by a turret collided with the player
  if not self.player.flagFound then
    for k, turret in pairs(self.level.turrets) do
      for i = #turret.rockets, 1, -1 do
        local rocket = turret.rockets[i]
        if self.player.health > 0 and rocket:collidesWith(
          self.player.x - (self.player.tankBaseHeight - self.player.tankBaseWidth) / 2,
          self.player.y,
          self.player.tankBaseHeight,
          self.player.tankBaseHeight
        ) then
          table.remove(turret.rockets, i)
          self.player.health = math.max(0, self.player.health - 1)
          if self.player.health > 0 then
            gSounds['tank-hit']:clone():play()
            table.insert(self.animations, Animation(
              self.player.x - ((self.player.tankBaseHeight - self.player.tankBaseWidth) / 2) + ((self.player.tankBaseHeight - 32) / 2),
              self.player.y + ((self.player.tankBaseHeight - 32) / 2),
              'explosions',
              'hit',
              0.1
            ))
          else
            gSounds['tank-explosion']:play()
            table.insert(self.animations, Animation(
              self.player.x - ((self.player.tankBaseHeight - self.player.tankBaseWidth) / 2) + ((self.player.tankBaseHeight - 96) / 2),
              self.player.y + ((self.player.tankBaseHeight - 96) / 2),
              'explosions',
              'explosion-2',
              0.1
            ))
            if self.livesRemaining > 0 then
              Timer.after(5, function()
                -- Don't restart the play state if we happen to die just before the flag is found
                if not self.player.flagFound then
                  gStateMachine:change('play', { livesRemaining = self.livesRemaining - 1, level = self.level })
                end
              end)
            else
              Timer.every(1, function()
                if not gSounds['tank-explosion']:isPlaying() then
                  Timer.clear()

                  -- Don't go to the game over state if we happen to die just before the flag is found
                  if not self.player.flagFound then
                    gStateMachine:change('game-over')
                  end
                end
              end)
            end
          end
        end
      end
    end
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

  -- Position the camera over the player
  self.camera:lookAt(math.floor(self.player.x), math.floor(self.player.y))
  
  -- Timer.update(dt)
  -- if love.keyboard.wasPressed('up') then
  --   if not self.isZooming then
  --     self.isZooming = true
  --     Timer.tween(2, self.camera, { scale = 0.5 }, 'out-quad', function() self.isZooming = false end)
  --   end
  -- elseif love.keyboard.wasPressed('down') then
  --   if not self.isZooming then
  --     self.isZooming = true
  --     Timer.tween(2, self.camera, { scale = 0.75 }, 'out-quad', function() self.isZooming = false end)
  --   end
  -- end
end

function PlayState:render()
  self.camera:attach()

  self.level:render()
  self.player:render()

  local cameraX, cameraY = self.camera:position()

  -- Draw the life bar
  love.graphics.setColor(255, 0, 0, 100)
  love.graphics.rectangle(
    'line',
    cameraX - (love.graphics.getWidth() / 2) + 10,
    cameraY + (love.graphics.getHeight() / 2) - 30,
    love.graphics.getWidth() - 20,
    20
  )
  love.graphics.rectangle(
    'fill',
    cameraX - (love.graphics.getWidth() / 2) + 10,
    cameraY + (love.graphics.getHeight() / 2) - 30,
    (love.graphics.getWidth() - 20) * (self.player.health / self.player.startHealth),
    20
  )
  love.graphics.setColor(255, 255, 255)

  -- Draw remaining lives
  for i = 1, self.livesRemaining do
    love.graphics.draw(
      gTextures['ground-units'],
      gFrames['ground-units']['tank-base'],
      cameraX - (love.graphics.getWidth() / 2) + 10 + (60 * i) - 60,
      cameraY + (love.graphics.getHeight() / 2) - 110,
      0,
      1.5, 1.5
    )
    love.graphics.draw(
      gTextures['ground-units'],
      gFrames['ground-units']['tank-turret'],
      cameraX - (love.graphics.getWidth() / 2) + 10 + (60 * i) - 60 + 10,
      cameraY + (love.graphics.getHeight() / 2) - 110 - 10,
      0,
      1.5, 1.5
    )
  end
  
  -- Draw the animations
  for k, animation in pairs(self.animations) do
    animation:render()
  end

  self.camera:detach()
end