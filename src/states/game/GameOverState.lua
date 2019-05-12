GameOverState = Class{__includes = BaseState}

function GameOverState:init()
  
end

function GameOverState:enter(params)
  love.audio.stop()
  Timer.after(5, function() gStateMachine:change('start') end)
end

function GameOverState:update(dt)
  Timer.update(dt);

  if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('space') then
    Timer.clear()
    gStateMachine:change('start')
  end
end

function GameOverState:render()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(
    gTextures['background'],
    0,
    0, 0,
    love.graphics.getWidth() / gTextures['background']:getWidth(),
    love.graphics.getHeight() / gTextures['background']:getHeight()
  )

  love.graphics.setColor(0, 0, 0, 150)
  love.graphics.rectangle('fill', 0, (love.graphics.getHeight() / 2) - (250 / 2), love.graphics.getWidth(), 250)
  
  love.graphics.setFont(gFonts['large'])
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.printf('GAME OVER', 0, love.graphics.getHeight() / 2 - 85, love.graphics.getWidth(), 'center')
end