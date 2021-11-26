-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--widget = require( "widget" )
local composer = require("composer")

sfx = {
  bg = audio.loadSound("background.wav"),
  death = audio.loadSound("explosion.mp3")
}
font = native.systemFont

composer.loadScene("game")
composer.gotoScene("menu")

display.setStatusBar(display.HiddenStatusBar)
