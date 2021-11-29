-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--widget = require( "widget" )
local composer = require("composer")

sfx = {
  bg = audio.loadSound("background.wav"),
  death = audio.loadSound("explosion.mp3"),
  collect = audio.loadSound("collectPowerUp.wav"),
  levelup = audio.loadSound("levelUp.wav"),
  usepower = audio.loadSound("usePowerUp.wav")
}
font = native.systemFont

composer.loadScene("game")
composer.gotoScene("menu")

display.setStatusBar(display.HiddenStatusBar)
