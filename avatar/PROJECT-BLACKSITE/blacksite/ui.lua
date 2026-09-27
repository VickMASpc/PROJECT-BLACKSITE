local UI = {}

local State = nil
local Mission = nil
local Companion = nil

local hud = models:newPart("BLACKSITE_HUD", "HUD")
local hudText = hud:newText("Status")
hudText:setPos(-6, -8, -10)
hudText:setScale(0.75)
hudText:setWidth(330)
hudText:setBackground(true)
hudText:setBackgroundColor(0, 0, 0, 0.58)
hudText:setShadow(true)

local interactKey = nil
local followKey = nil
local menuKey = nil
local resetKey = nil

local function getActions()
   local actions = Mission.getContextActions()

   table.insert(actions, {
      id = "TOGGLE_FOLLOW",
      label = State.data.reina.follow == "FOLLOW" and "WAIT here" or "FOLLOW me"
   })

   table.insert(actions, {
      id = "STATUS",
      label = "Report status"
   })

   return actions
end

local function closeMenu()
   State.data.ui.menuOpen = false
   State.data.ui.selected = 1
end

function UI.executeSelected()
   local actions = getActions()
   if #actions == 0 then
      closeMenu()
      return
   end

   local index = State.clamp(State.data.ui.selected, 1, #actions)
   local action = actions[index]

   if action.id == "TOGGLE_FOLLOW" then
      local mode = Companion.toggleFollow()
      State.message("Reina: " .. (mode == "FOLLOW" and "Following." or "Holding here."), 75)
      closeMenu()
      return
   end

   if action.id == "STATUS" then
      local r = State.data.reina
      State.message(
         string.format(
            "Status — END %d | STRAIN %d | DISCOMFORT %d | ALERT %d",
            r.endurance,
            r.strain,
            r.discomfort,
            State.data.mission.alert
         ),
         125
      )
      closeMenu()
      return
   end

   local handled = Mission.executeAction(action.id)
   if handled then
      closeMenu()
   end
end

function UI.init(state, mission, companion)
   State = state
   Mission = mission
   Companion = companion

   interactKey = keybinds:newKeybind("BLACKSITE: Interact / Confirm", "key.keyboard.g", false)
   followKey = keybinds:newKeybind("BLACKSITE: Follow / Wait", "key.keyboard.h", false)
   menuKey = keybinds:newKeybind("BLACKSITE: Command Menu / Cycle", "key.keyboard.j", false)
   resetKey = keybinds:newKeybind("BLACKSITE: Recovery / Reset", "key.keyboard.r", false)

   interactKey.press = function()
      if State.data.ui.menuOpen then
         UI.executeSelected()
      else
         Mission.interact()
      end
      return true
   end

   followKey.press = function()
      closeMenu()
      local mode = Companion.toggleFollow()
      State.message("Reina: " .. (mode == "FOLLOW" and "Following." or "Holding here."), 70)
      return true
   end

   menuKey.press = function(modifiers)
      -- Shift+J closes immediately.
      if modifiers and (modifiers % 2 == 1) then
         closeMenu()
         return true
      end

      local ui = State.data.ui
      local actions = getActions()

      if not ui.menuOpen then
         ui.menuOpen = true
         ui.selected = 1
      else
         ui.selected = ui.selected + 1
         if ui.selected > #actions then
            ui.selected = 1
         end
      end

      return true
   end

   resetKey.press = function(modifiers)
      if modifiers and (modifiers % 2 == 1) then
         State.resetMission()
         Companion.setDisguise("FIELD")
         Companion.resetBesidePlayer()
         State.message("Operation Glasshouse reset.", 100)
      else
         Companion.resetBesidePlayer()
         State.message("Reina recovered beside player. Mission state unchanged.", 100)
      end
      return true
   end
end

local function buildMenu()
   local actions = getActions()
   local selected = State.clamp(State.data.ui.selected, 1, math.max(#actions, 1))
   local lines = {
      "§d§lCOMMANDS §8[J cycle / G confirm / Shift+J close]"
   }

   for i, action in ipairs(actions) do
      local prefix = (i == selected) and "§f> " or "§8  "
      table.insert(lines, prefix .. action.label)
   end

   return table.concat(lines, "\n")
end

function UI.tick()
   if not State then
      return
   end

   local d = State.data
   local r = d.reina
   local mission = d.mission

   local distance = Mission.getObjectiveDistance()
   local status = Companion.statusLine()

   local lines = {
      "§5§lPROJECT BLACKSITE §8// §dGLASSHOUSE",
      "§7PHASE §f" .. Mission.getPhaseLabel(),
      string.format("§7OBJ   §f%s §8[%.1fm]", Mission.getObjectiveText(), distance),
      "§7REINA §f" .. status
   }

   if r.lost then
      table.insert(lines, "§cREINA LOST — press R to recover; no auto-teleport.")
   elseif r.blocked then
      table.insert(lines, "§6Reina is locally blocked. Reposition or use WAIT/FOLLOW.")
   end

   if r.compromised then
      table.insert(
         lines,
         string.format(
            "§8persistent state: concealment=%s / endurance=%d / strain=%d",
            r.concealment,
            r.endurance,
            r.strain
         )
      )
   end

   if d.ui.menuOpen then
      table.insert(lines, "")
      table.insert(lines, buildMenu())
   else
      table.insert(lines, "§8[G interact] [H follow/wait] [J commands]")
   end

   if d.ui.message ~= "" then
      table.insert(lines, "")
      table.insert(lines, "§f" .. d.ui.message)
   end

   hudText:setText(table.concat(lines, "\n"))
end

return UI
