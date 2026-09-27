local State = {}

State.tickCount = 0
State.message = ""
State.messageTicks = 0
State.debug = true

State.reina = {
   mode = "FOLLOW",
   pos = nil,
   prevPos = nil,
   yaw = 0,
   prevYaw = 0,
   target = nil,
   moving = false,
   blocked = false,
   lost = false,
   lookedAt = false,
   walkClock = 0,
   speed = 0
}

function State.init()
   State.tickCount = 0
end

function State.say(text, ticks)
   State.message = tostring(text or "")
   State.messageTicks = ticks or 70
end

function State.tick()
   State.tickCount = State.tickCount + 1
   if State.messageTicks > 0 then
      State.messageTicks = State.messageTicks - 1
      if State.messageTicks == 0 then State.message = "" end
   end
end

return State
