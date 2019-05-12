WinState = Class{__includes = BaseState}

function WinState:init()
  
end

function WinState:enter(params)
  Timer.after(5, function() gStateMachine:change('start') end)
end

function WinState:update(dt)
  Timer.update(dt);

  if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('space') then
    Timer.clear()
    gStateMachine:change('start')
  end
end

function WinState:render()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(
    gTextures['background'],
    0,
    0, 0,
    love.graphics.getWidth() / gTextures['background']:getWidth(),
    love.graphics.getHeight() / gTextures['background']:getHeight()
  )

  love.graphics.setColor(255, 255, 255, 255)
  local winWidth, winHeight = gFrames['win']:getTextureDimensions()
  love.graphics.draw(
    gTextures['win'],
    gFrames['win'],
    (love.graphics.getWidth() / 2) - (winWidth * 3 / 2),
    (love.graphics.getHeight() / 2) - (winHeight * 3 / 2),
    0,
    3, 3
  )

  love.graphics.setColor(0, 0, 0, 150)
  love.graphics.rectangle('fill', 0, (love.graphics.getHeight() / 2) - (250 / 2), love.graphics.getWidth(), 250)
  
  love.graphics.setFont(gFonts['large'])
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.printf('YOU WON!', 0, love.graphics.getHeight() / 2 - 85, love.graphics.getWidth(), 'center')
end