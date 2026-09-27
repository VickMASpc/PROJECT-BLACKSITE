local Hud = {}

local State
local Reina

local layer = models:newPart("BLACKSITE_G1_HUD", "HUD")
local text = layer:newText("G1Status")
text:setPos(-7, -8, -10)
text:setScale(0.72)
text:setWidth(320)
text:setBackground(true)
text:setBackgroundColor(0,0,0,0.48)
text:setShadow(true)

function Hud.init(state, reina)
   State = state
   Reina = reina
end

function Hud.tick()
   if not State then return end
   text:setVisible(State.debug)

   if not State.debug then return end

   local r = State.reina
   local status = r.mode
   if r.lost then status = status .. " / LOST"
   elseif r.blocked then status = status .. " / BLOCKED" end

   local lines = {
      "§5§lBLACKSITE §8// §dG1 REINA",
      string.format("§7STATE §f%s §8• %.1fm", status, Reina.getDistance()),
      r.lookedAt and "§f> REINA" or "§8  Reina",
      "§8[H] follow/wait  [G] come  [J] move there  [R] recover  [K] HUD"
   }

   if State.message ~= "" then
      table.insert(lines, "")
      table.insert(lines, "§f" .. State.message)
   end

   text:setText(table.concat(lines, "\n"))
end

return Hud
