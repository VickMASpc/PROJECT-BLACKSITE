if not host:isHost() then
   return
end

local State = require("blacksite.state")
local Companion = require("blacksite.companion")
local Mission = require("blacksite.mission")
local UI = require("blacksite.ui")

local booted = false

local function boot()
   State.load()
   State.ensureOrigin()

   Companion.init(State)
   Mission.init(State, Companion)
   UI.init(State, Mission, Companion)

   State.message("BLACKSITE 0.1 online. Follow the objective distance and press G.", 160)
   booted = true
end

events.tick:register(function()
   if not player:isLoaded() then
      return
   end

   if not booted then
      boot()
   end

   State.tick()
   Companion.tick()
   Mission.tick()
   UI.tick()
end)

events.world_render:register(function(delta)
   if booted then
      Companion.render(delta)
   end
end)
