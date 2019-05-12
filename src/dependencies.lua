Class = require 'lib/class'
Camera = require 'lib/camera'
Timer = require 'lib/timer'

require 'src/constants'
require 'src/util'

require 'src/states/BaseState'
require 'src/states/game/StartState'
require 'src/states/game/PlayState'
require 'src/states/game/WinState'
require 'src/states/game/GameOverState'

require 'src/StateMachine'
require 'src/Level'
require 'src/Player'
require 'src/Rocket'
require 'src/Turret'
require 'src/Base'
require 'src/Animation'

gTextures = {
  ['water'] = love.graphics.newImage('graphics/water.png'),
  ['buildings'] = love.graphics.newImage('graphics/buildings.png'),
  -- ['decor'] = love.graphics.newImage('graphics/decor.png'),
  ['ground-units'] = love.graphics.newImage('graphics/ground_units.png'),
  ['ground'] = love.graphics.newImage('graphics/ground.png'),
  ['rocket'] = love.graphics.newImage('graphics/rocket.png'),
  ['explosions'] = love.graphics.newImage('graphics/explosions.png'),
  ['background'] = love.graphics.newImage('graphics/background.png'),
  ['win'] = love.graphics.newImage('graphics/win.png'),
  ['controls'] = love.graphics.newImage('graphics/controls.png')
}

gFrames = {
  ['water'] = {
    love.graphics.newQuad(0, 0, 128, 128, gTextures['water']:getDimensions())
  },
  ['buildings'] = {
    ['bunker-round-bottom'] = love.graphics.newQuad(284, 246, 100, 100, gTextures['buildings']:getDimensions()),
    ['bunker-round-top'] = love.graphics.newQuad(816, 422, 76, 76, gTextures['buildings']:getDimensions()),
    ['bunker-round-top-destroyed'] = love.graphics.newQuad(912, 418, 76, 76, gTextures['buildings']:getDimensions()),
    ['bunker-2x1'] = love.graphics.newQuad(602, 936, 192, 82, gTextures['buildings']:getDimensions()),
    ['platform'] = love.graphics.newQuad(814, 345, 58, 46, gTextures['buildings']:getDimensions()),
    ['platform-gun'] = love.graphics.newQuad(680, 560, 32, 54, gTextures['buildings']:getDimensions()),
    ['platform-gun-destroyed'] = love.graphics.newQuad(646, 560, 32, 54, gTextures['buildings']:getDimensions())
  },
  ['ground-units'] = {
    ['tank-base'] = love.graphics.newQuad(358, 352, 34, 48, gTextures['ground-units']:getDimensions()),
    ['tank-base-destroyed'] = love.graphics.newQuad(474, 346, 34, 48, gTextures['ground-units']:getDimensions()),
    ['tank-turret'] = love.graphics.newQuad(78, 254, 20, 40, gTextures['ground-units']:getDimensions()),
    ['tank-turret-destroyed'] = love.graphics.newQuad(418, 70, 20, 40, gTextures['ground-units']:getDimensions())
  },
  ['ground'] = {
    ['grass'] = love.graphics.newQuad(0, 128, 128, 128, gTextures['ground']:getDimensions()),
    ['beach-tl'] = love.graphics.newQuad(640, 0, 128, 128, gTextures['ground']:getDimensions()),
    ['beach-tm'] = love.graphics.newQuad(384, 0, 128, 128, gTextures['ground']:getDimensions()),
    ['beach-tr'] = love.graphics.newQuad(0, 256, 128, 128, gTextures['ground']:getDimensions()),
    ['beach-rm'] = love.graphics.newQuad(512, 128, 128, 128, gTextures['ground']:getDimensions()),
    ['beach-br'] = love.graphics.newQuad(768, 384, 128, 128, gTextures['ground']:getDimensions()),
    ['beach-bm'] = love.graphics.newQuad(640, 768, 128, 128, gTextures['ground']:getDimensions()),
    ['beach-bl'] = love.graphics.newQuad(768, 640, 128, 128, gTextures['ground']:getDimensions()),
    ['beach-lm'] = love.graphics.newQuad(384, 512, 128, 128, gTextures['ground']:getDimensions()),
    ['beach-dn'] = love.graphics.newQuad(256, 256, 128, 128, gTextures['ground']:getDimensions())
  },
  ['rocket'] = love.graphics.newQuad(0, 0, 9, 43, gTextures['rocket']:getDimensions()),
  ['explosions'] = {
    ['hit'] = {
      love.graphics.newQuad(694, 774, 32, 32, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(972, 608, 32, 32, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(972, 574, 32, 32, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(664, 838, 32, 32, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(630, 838, 32, 32, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(596, 838, 32, 32, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(562, 838, 32, 32, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(990, 540, 32, 32, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(728, 774, 32, 32, gTextures['explosions']:getDimensions())
    },
    ['explosion-1'] = {
      love.graphics.newQuad(958, 774, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(892, 766, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(958, 708, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(826, 760, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(892, 700, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(958, 642, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(826, 694, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(892, 634, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(826, 628, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(760, 708, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(760, 642, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(698, 808, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(694, 708, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(694, 642, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(906, 568, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(840, 562, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(774, 562, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(708, 562, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(642, 938, 64, 64, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(632, 872, 64, 64, gTextures['explosions']:getDimensions())
    },
    ['explosion-2'] = {
      love.graphics.newQuad(100, 398, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(100, 300, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(100, 202, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(100, 104, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(888, 2, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(790, 2, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(692, 2, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(594, 2, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(496, 2, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(398, 2, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(300, 2, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(202, 2, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(104, 2, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(2, 884, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(2, 786, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(2, 688, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(2, 590, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(2, 492, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(2, 394, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(2, 296, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(2, 198, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(2, 100, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(2, 2, 96, 96, gTextures['explosions']:getDimensions()),
      love.graphics.newQuad(100, 496, 96, 96, gTextures['explosions']:getDimensions())
    }
  },
  ['win'] = love.graphics.newQuad(0, 0, 100, 100, gTextures['win']:getDimensions())
}

gFonts = {
  ['small'] = love.graphics.newFont('fonts/RacingSansOne-Regular.ttf', 32),
  ['medium'] = love.graphics.newFont('fonts/RacingSansOne-Regular.ttf', 64),
  ['large'] = love.graphics.newFont('fonts/RacingSansOne-Regular.ttf', 128),
  ['extra-large'] = love.graphics.newFont('fonts/RacingSansOne-Regular.ttf', 256)
}

gSounds = {
  ['intro'] = love.audio.newSource('sounds/giuseppe_verdi_messada_requiem_dies_irae.mp3'),
  ['music'] = love.audio.newSource('sounds/gustav_holst_the_planets_mars.ogg'),
  ['flag-reveal'] = love.audio.newSource('sounds/george_frideric_handel_messiah_hallelujah.ogg'),
  ['engine'] = love.audio.newSource('sounds/engine_loop.wav'),
  ['fire-rocket'] = love.audio.newSource('sounds/fire_rocket.ogg'),
  ['hit'] = love.audio.newSource('sounds/hit.ogg'),
  ['explosion'] = love.audio.newSource('sounds/explosion.ogg'),
  ['tank-hit'] = love.audio.newSource('sounds/tank_hit.ogg'),
  ['tank-explosion'] = love.audio.newSource('sounds/tank_explosion.ogg')
}