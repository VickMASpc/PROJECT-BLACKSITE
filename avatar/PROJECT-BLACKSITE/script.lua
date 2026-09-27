if not host:isHost() then return end

local State = require("g1.state")
local Reina = require("g1.reina")
local Input = require("g1.input")
local Hud = require("g1.hud")

local ready = false

local function boot()
   State.init()
   Reina.init(State)
   Input.init(State, Reina)
   Hud.init(State, Reina)
   ready = true
end

events.tick:register(function()
   if not player:isLoaded() then return end
   if not ready then boot() end

   State.tick()
   Reina.tick()
   Hud.tick()
end)

events.world_render:register(function(delta)
   if ready then Reina.render(delta) end
end)
