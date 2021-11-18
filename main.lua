-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--widget = require( "widget" )
local composer = require("composer")

sfx = {
  crash = audio.loadSound("death.wav")
}
font = native.systemFont

composer.loadScene("game")
composer.gotoScene("menu")

display.setStatusBar(display.HiddenStatusBar)
