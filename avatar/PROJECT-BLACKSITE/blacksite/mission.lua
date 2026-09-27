local Mission = {}

local State = nil
local Companion = nil

local objectives = {
   INSERTION =          {x = 0,  z = 6,  label = "Reach perimeter breach"},
   SERVICE_WING =       {x = 0,  z = 15, label = "Reach service access"},
   DISGUISE =           {x = 4,  z = 23, label = "Search staff changing area"},
   CHECKPOINT_1 =       {x = 0,  z = 35, label = "Cross security intake"},
   RESEARCH_FLOOR =     {x = 0,  z = 48, label = "Reach research floor"},
   MAINTENANCE_SHAFT =  {x = -3, z = 60, label = "Enter maintenance shaft"},
   LAB =                {x = 1,  z = 74, label = "Search restricted laboratory"},
   CHECKPOINT_2 =       {x = 0,  z = 88, label = "Cross secondary scanner"},
   COMPLETE =           {x = 0,  z = 100,label = "Vertical slice complete"}
}

local function basis()
   local heading = math.rad(State.data.mission.heading)
   local forward = vec(-math.sin(heading), 0, math.cos(heading))
   local right = vec(math.cos(heading), 0, math.sin(heading))
   return forward, right
end

local function advance(phase)
   State.data.mission.phase = phase
   State.data.mission.step = 0
   State.data.ui.menuOpen = false
   State.data.ui.selected = 1
   State.save()
end

local function nearObjective()
   local target = Mission.getObjectiveWorldPos()
   if not target then
      return true, 0
   end

   local distance = (player:getPos() - target):length()
   return distance <= 3.25, distance
end

function Mission.init(state, companion)
   State = state
   Companion = companion
end

function Mission.tick()
   -- 0.1 deliberately keeps the mission deterministic.
   -- Future world scanners/cameras/guards will feed events into this layer.
end

function Mission.getObjective()
   local phase = State.data.mission.phase
   return objectives[phase]
end

function Mission.getObjectiveWorldPos()
   local mission = State.data.mission
   local objective = Mission.getObjective()

   if not mission.origin or not objective then
      return nil
   end

   local forward, right = basis()
   return mission.origin + right * objective.x + forward * objective.z
end

function Mission.getObjectiveDistance()
   local target = Mission.getObjectiveWorldPos()
   if not target then
      return 0
   end
   return (player:getPos() - target):length()
end

function Mission.getObjectiveText()
   local objective = Mission.getObjective()
   if not objective then
      return "No objective"
   end
   return objective.label
end

function Mission.getPhaseLabel()
   return State.data.mission.phase:gsub("_", " ")
end

function Mission.interact()
   local mission = State.data.mission
   local reina = State.data.reina

   if mission.phase == "COMPLETE" then
      State.message("Operation Glasshouse 0.1 complete. Shift+R restarts the slice.", 140)
      return
   end

   local closeEnough, distance = nearObjective()
   if not closeEnough then
      State.message(string.format("Objective is %.1fm away.", distance), 55)
      return
   end

   if mission.phase == "INSERTION" then
      State.message("Reina: Perimeter clear. Stay behind me until we reach service access.", 115)
      advance("SERVICE_WING")
      return
   end

   if mission.phase == "SERVICE_WING" then
      State.message("Reina bypasses the service latch. Staff route is open.", 100)
      advance("DISGUISE")
      return
   end

   if mission.phase == "DISGUISE" then
      Companion.setDisguise("STAFF")
      State.message("Reina: One believable uniform. Fine. I am apparently the employee.", 120)
      advance("CHECKPOINT_1")
      return
   end

   if mission.phase == "CHECKPOINT_1" then
      if mission.step == 0 then
         mission.flags.prototype_acquired = true
         mission.step = 1
         State.save()
         State.message("Restricted prototype acquired. Intake scanner indexes every external container.", 120)
         return
      elseif mission.step == 1 then
         mission.step = 2
         State.save()
         State.message("Reina checks the module. Then the scanner. Then you. \"No.\"", 120)
         return
      elseif mission.step == 2 then
         mission.flags.checkpoint_1_special = true
         mission.step = 3
         State.save()
         State.message("SPECIAL ORDER available. Press J, then G to confirm.", 150)
         return
      end

      State.message("The checkpoint is waiting on your special order. [J]", 70)
      return
   end

   if mission.phase == "RESEARCH_FLOOR" then
      if mission.step == 0 then
         mission.step = 1
         State.save()
         State.message("Reina: Commander. I am requesting—formally—that we do not sprint.", 130)
         return
      end

      State.message("The earlier solution is now a movement problem. Maintenance access is ahead.", 115)
      advance("MAINTENANCE_SHAFT")
      return
   end

   if mission.phase == "MAINTENANCE_SHAFT" then
      if mission.step == 0 then
         mission.step = 1
         State.save()
         State.message("Reina tries the crawlspace, stops, and backs out. \"No. Not like this.\"", 125)
         return
      elseif mission.step == 1 then
         mission.flags.shaft_choice = true
         mission.step = 2
         State.save()
         State.message("Reina: Your brilliant storage solution makes that maneuver impossible. [J]", 145)
         return
      end

      State.message("Choose how to solve the maintenance-shaft consequence. [J]", 80)
      return
   end

   if mission.phase == "LAB" then
      if mission.step == 0 then
         mission.step = 1
         State.save()
         State.message("The restricted lab is not funny. The records describe human endurance trials.", 125)
         return
      elseif mission.step == 1 then
         mission.flags.research_seen = true
         mission.step = 2
         State.save()
         State.message("Reina: Copy everything. Whatever this place is doing, this is the real objective now.", 135)
         return
      end

      advance("CHECKPOINT_2")
      State.message("Secondary security is the only clean route out.", 90)
      return
   end

   if mission.phase == "CHECKPOINT_2" then
      if mission.step == 0 then
         mission.step = 1
         State.save()
         State.message("Different scanner. Deeper profile. Reina reads the spec twice. \"...Commander.\"", 135)
         return
      elseif mission.step == 1 then
         mission.flags.checkpoint_2_choice = true
         mission.step = 2
         State.save()
         State.message("The old compromise is relevant again. Three routes are available. [J]", 145)
         return
      end

      State.message("Choose the secondary-checkpoint plan. [J]", 80)
      return
   end
end

function Mission.getContextActions()
   local mission = State.data.mission
   local actions = {}

   if mission.phase == "CHECKPOINT_1"
      and mission.flags.checkpoint_1_special
      and not State.data.reina.compromised then
      table.insert(actions, {
         id = "CONCEAL_PROTOTYPE",
         label = "SPECIAL ORDER — internal concealment"
      })
   end

   if mission.phase == "MAINTENANCE_SHAFT" and mission.flags.shaft_choice then
      table.insert(actions, {id = "SHAFT_ADJUST", label = "Let Reina fix the problem"})
      table.insert(actions, {id = "SHAFT_ASSIST", label = "Assist her"})
      table.insert(actions, {id = "SHAFT_ENDURE", label = "Order her to endure it"})
   end

   if mission.phase == "CHECKPOINT_2" and mission.flags.checkpoint_2_choice then
      table.insert(actions, {id = "CHECKPOINT_REMOVE", label = "Remove the prototype first"})
      table.insert(actions, {id = "CHECKPOINT_RISK", label = "Risk the scan as-is"})
      table.insert(actions, {id = "CHECKPOINT_DOUBLE", label = "Double down — take the second sample too"})
   end

   return actions
end

function Mission.executeAction(actionId)
   local mission = State.data.mission
   local reina = State.data.reina

   if actionId == "CONCEAL_PROTOTYPE" then
      reina.compromised = true
      reina.concealment = "INTERNAL"
      reina.discomfort = State.clamp(reina.discomfort + 18, 0, 100)
      reina.endurance = State.clamp(reina.endurance - 8, 0, 100)
      reina.annoyance = State.clamp(reina.annoyance + 12, 0, 100)
      reina.normalization = State.clamp(reina.normalization + 1, 0, 100)
      mission.flags.prototype_concealed = true
      State.save()
      advance("RESEARCH_FLOOR")
      State.message("Checkpoint cleared. The concealment state persists; Reina now moves carefully.", 150)
      return true
   end

   if actionId == "SHAFT_ADJUST" then
      reina.discomfort = State.clamp(reina.discomfort - 10, 0, 100)
      reina.endurance = State.clamp(reina.endurance + 4, 0, 100)
      reina.annoyance = State.clamp(reina.annoyance - 3, 0, 100)
      reina.normalization = State.clamp(reina.normalization + 1, 0, 100)
      mission.flags.shaft_solution = "ADJUST"
      State.save()
      advance("LAB")
      State.message("You give her the room. Thirty seconds later: \"We are never discussing that.\" Crawlspace clear.", 145)
      return true
   end

   if actionId == "SHAFT_ASSIST" then
      reina.discomfort = State.clamp(reina.discomfort - 14, 0, 100)
      reina.composure = State.clamp(reina.composure - 7, 0, 100)
      reina.annoyance = State.clamp(reina.annoyance + 4, 0, 100)
      reina.normalization = State.clamp(reina.normalization + 4, 0, 100)
      mission.flags.shaft_solution = "ASSIST"
      State.save()
      advance("LAB")
      State.message("The problem is solved faster. The silence afterward is significantly worse.", 130)
      return true
   end

   if actionId == "SHAFT_ENDURE" then
      if reina.endurance < 35 then
         State.message("Reina: Negative. I can endure stupid. I cannot endure physically impossible.", 125)
         return false
      end

      reina.endurance = State.clamp(reina.endurance - 22, 0, 100)
      reina.strain = State.clamp(reina.strain + 20, 0, 100)
      reina.discomfort = State.clamp(reina.discomfort + 16, 0, 100)
      reina.annoyance = State.clamp(reina.annoyance + 12, 0, 100)
      reina.normalization = State.clamp(reina.normalization + 6, 0, 100)
      mission.flags.shaft_solution = "ENDURE"
      State.save()
      advance("LAB")
      State.message("Reina: \"Fine.\" She gets through. The cost follows her into the lab.", 140)
      return true
   end

   if actionId == "CHECKPOINT_REMOVE" then
      reina.compromised = false
      reina.concealment = "NONE"
      reina.discomfort = State.clamp(reina.discomfort - 24, 0, 100)
      reina.endurance = State.clamp(reina.endurance + 8, 0, 100)
      mission.flags.checkpoint_2_solution = "REMOVE"
      State.save()
      advance("COMPLETE")
      State.message("Clean extraction. Reina: \"Look at that. A normal solution. I missed those.\"", 155)
      return true
   end

   if actionId == "CHECKPOINT_RISK" then
      mission.alert = mission.alert + 1
      mission.flags.checkpoint_2_solution = "RISK"
      mission.flags.scanner_anomaly = true
      reina.composure = State.clamp(reina.composure - 12, 0, 100)
      State.save()
      advance("COMPLETE")
      State.message("The scanner chirps once too many. You clear it, but BLACKSITE now has an anomaly logged.", 155)
      return true
   end

   if actionId == "CHECKPOINT_DOUBLE" then
      if reina.endurance < 40 then
         State.message("Reina: Absolutely not. Not at this endurance level.", 110)
         return false
      end

      mission.flags.secondary_sample = true
      mission.flags.checkpoint_2_solution = "DOUBLE"
      reina.endurance = State.clamp(reina.endurance - 25, 0, 100)
      reina.strain = State.clamp(reina.strain + 25, 0, 100)
      reina.discomfort = State.clamp(reina.discomfort + 22, 0, 100)
      reina.annoyance = State.clamp(reina.annoyance + 8, 0, 100)
      reina.normalization = State.clamp(reina.normalization + 8, 0, 100)
      State.save()
      advance("COMPLETE")
      State.message("You leave with both samples. Reina says nothing until the elevator doors close.", 160)
      return true
   end

   return false
end

return Mission
