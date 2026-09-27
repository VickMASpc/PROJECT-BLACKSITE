local Input = {}

function Input.init(State, Reina)
   local follow = keybinds:newKeybind("BLACKSITE — Follow / Wait", "key.keyboard.h", false)
   local come = keybinds:newKeybind("BLACKSITE — Come Here", "key.keyboard.g", false)
   local move = keybinds:newKeybind("BLACKSITE — Move There", "key.keyboard.j", false)
   local recover = keybinds:newKeybind("BLACKSITE — Recover Reina", "key.keyboard.r", false)
   local debug = keybinds:newKeybind("BLACKSITE — Toggle G1 HUD", "key.keyboard.k", false)

   follow.press = function()
      Reina.toggleFollow()
      return true
   end

   come.press = function()
      Reina.comeHere()
      return true
   end

   move.press = function()
      Reina.moveThereFromCrosshair()
      return true
   end

   recover.press = function()
      Reina.recover()
      return true
   end

   debug.press = function()
      State.debug = not State.debug
      return true
   end
end

return Input
