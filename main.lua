--[[
  Return Fire Revisited

  Author: Josh Grauer
  jaggedaz@gmail.com

  Music Credit:

  George Frideric Handel - Messiah - Hallelujah
  https://imslp.org/wiki/Messiah,_HWV_56_(Handel,_George_Frideric)

  Gustav Holst - The Planets - Mars
  https://opengameart.org/content/holst-the-planets-suite

  Giuseppe Verdi - Messada Requiem - Dies Irae
  https://imslp.org/wiki/Requiem_(Verdi,_Giuseppe)

  Engine
  https://freesound.org/people/qubodup/sounds/143658/

  Graphics Credit:

  Explosions
  https://opengameart.org/content/explosions-0

  Ground and Water Tiles
  https://opengameart.org/content/ground-tileset-grass-sand

  Tank
  https://opengameart.org/content/tanks-and-trucks

  Buildings
  https://opengameart.org/content/buildings-bunkers-weapon-platforms

  Win Icon
  https://opengameart.org/content/game-icons-0

  Keyboard Keys
  https://opengameart.org/content/keyboard-keys-1
]]

require 'src/dependencies'

function love.load()
  math.randomseed(os.time())

  love.graphics.setDefaultFilter('nearest', 'nearest')
  
  love.window.setTitle('Return Fire Revisited')
  love.window.setMode(1280, 768, { fullscreen = true })
  -- love.window.setMode(1280, 768)
  love.mouse.setVisible(false)

  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['play'] = function() return PlayState() end,
    ['win'] = function() return WinState() end,
    ['game-over'] = function() return GameOverState() end
  }
  gStateMachine:change('start')

  love.keyboard.keysPressed = {}
  love.keyboard.anyKeyPressed = false
end

function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
  love.keyboard.anyKeyPressed = true
end

function love.keyboard.wasPressed(key)
  return love.keyboard.keysPressed[key]
end

function love.update(dt)
  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end

  gStateMachine:update(dt)

  love.keyboard.keysPressed = {}
  love.keyboard.anyKeyPressed = false
end

function love.draw()
  gStateMachine:render()
end