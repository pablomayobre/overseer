local windowWidth = 1000
local windowHeight = 800
love.window.setMode(windowWidth, windowHeight, { resizable=true })
love.graphics.setDefaultFilter('nearest', 'nearest')

local inspect = require('libs.inspect')
limits = love.graphics.getSystemLimits( )
print(inspect(limits))

DEBUG = false
local PROFILER = false

local Concord = require("libs.concord")

ECS = {}
ECS.Component = Concord.component
ECS.c = Concord.components
ECS.System = Concord.system
ECS.Systems = Concord.systems
ECS.World = Concord.world
ECS.Entity = Concord.entity

Concord.loadComponents("components")
Concord.loadSystems("systems")

local Gamestate = require("libs.hump.gamestate")

local gameStates = {
  inGame = require("states.inGame"),
  mainMenu = require("states.mainMenu")
}

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(gameStates.mainMenu)
end

