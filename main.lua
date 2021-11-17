-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--widget = require( "widget" )
local composer = require("composer")

sfx = {
  crash = audio.loadSound("crash.wav")
}
font = native.systemFont

composer.loadScene("game")
composer.gotoScene("menu")

display.setStatusBar(display.HiddenStatusBar)
