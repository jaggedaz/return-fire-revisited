StartState = Class{__includes = BaseState}

function StartState:enter(params)
  love.audio.stop()
  gSounds['intro']:setVolume(0.5)
  gSounds['intro']:play()
end

function StartState:update(dt)
  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  elseif love.keyboard.anyKeyPressed then
    gSounds['intro']:stop()
    gStateMachine:change('play', { livesRemaining = 3 })
  end
end

function StartState:render()
  love.graphics.draw(
    gTextures['background'],
    0, 0,
    0,
    love.graphics.getWidth() / gTextures['background']:getWidth(),
    love.graphics.getHeight() / gTextures['background']:getHeight()
  )

  local bannerHeight = 500
  local vOffset = (love.graphics.getHeight() - bannerHeight) / 2

  love.graphics.setColor(0, 0, 0, 150)
  love.graphics.rectangle('fill', 0, vOffset, love.graphics.getWidth(), bannerHeight)

  love.graphics.setFont(gFonts['medium'])
  love.graphics.setColor(253, 355, 0, 255)
  love.graphics.printf('RETURN', -125, vOffset + 10, love.graphics.getWidth(), 'center')

  love.graphics.setFont(gFonts['extra-large'])
  love.graphics.setColor(197, 29, 6, 255)
  love.graphics.printf('FIRE', 0, vOffset, love.graphics.getWidth(), 'center')

  love.graphics.setFont(gFonts['small'])
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.printf('REVISITED', 180, vOffset + 270, love.graphics.getWidth(), 'center')

  love.graphics.setFont(gFonts['small'])
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.printf('Controls', 0, vOffset + 325, love.graphics.getWidth(), 'center')
  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.draw(
    gTextures['controls'],
    (love.graphics.getWidth() / 2) - (gTextures['controls']:getWidth() * 1.5 / 2),
    vOffset + 375,
    0,
    1.5, 1.5
  )

  love.graphics.setColor(255, 255, 255, 255)
end