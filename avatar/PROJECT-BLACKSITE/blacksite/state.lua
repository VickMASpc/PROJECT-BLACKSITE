local State = {}

State.version = "0.1.0"

State.phaseOrder = {
   "INSERTION",
   "SERVICE_WING",
   "DISGUISE",
   "CHECKPOINT_1",
   "RESEARCH_FLOOR",
   "MAINTENANCE_SHAFT",
   "LAB",
   "CHECKPOINT_2",
   "COMPLETE"
}

State.data = {
   loaded = false,

   mission = {
      id = "GLASSHOUSE",
      phase = "INSERTION",
      step = 0,
      origin = nil,
      heading = 0,
      alert = 0,
      flags = {}
   },

   reina = {
      follow = "FOLLOW",
      disguise = "FIELD",
      compromised = false,
      concealment = "NONE",

      endurance = 100,
      strain = 0,
      discomfort = 0,
      composure = 100,
      annoyance = 0,

      -- Deliberately not shown as a normal HUD stat.
      normalization = 0,

      machine = {
         active = false,
         profile = "NONE",
         intensity = 0,
         load = 0,
         duration = 0,
         recoveryDebt = 0
      },

      lost = false,
      blocked = false,
      pos = nil,
      prevPos = nil,
      yaw = 0,
      walkClock = 0,
      moving = false
   },

   ui = {
      menuOpen = false,
      selected = 1,
      message = "",
      messageTicks = 0
   }
}

local function numberOr(value, fallback)
   if type(value) == "number" then
      return value
   end
   return fallback
end

function State.clamp(value, minValue, maxValue)
   return math.max(minValue, math.min(maxValue, value))
end

function State.bump(field, amount)
   local reina = State.data.reina
   reina[field] = State.clamp((reina[field] or 0) + amount, 0, 100)
end

function State.message(text, ticks)
   State.data.ui.message = tostring(text or "")
   State.data.ui.messageTicks = ticks or 100
end

function State.tick()
   local ui = State.data.ui
   if ui.messageTicks > 0 then
      ui.messageTicks = ui.messageTicks - 1
      if ui.messageTicks <= 0 then
         ui.message = ""
      end
   end
end

function State.ensureOrigin()
   local mission = State.data.mission
   if mission.origin ~= nil then
      return
   end

   local pos = player:getPos()
   mission.origin = vec(pos.x, pos.y, pos.z)
   mission.heading = player:getBodyYaw()
   State.save()
end

function State.save()
   local d = State.data
   local mission = d.mission
   local reina = d.reina

   config:save("mission_phase", mission.phase)
   config:save("mission_step", mission.step)
   config:save("mission_alert", mission.alert)
   config:save("mission_heading", mission.heading)
   config:save("mission_flags", mission.flags)

   if mission.origin then
      config:save("origin_x", mission.origin.x)
      config:save("origin_y", mission.origin.y)
      config:save("origin_z", mission.origin.z)
   end

   config:save("reina_follow", reina.follow)
   config:save("reina_disguise", reina.disguise)
   config:save("reina_compromised", reina.compromised)
   config:save("reina_concealment", reina.concealment)

   config:save("reina_endurance", reina.endurance)
   config:save("reina_strain", reina.strain)
   config:save("reina_discomfort", reina.discomfort)
   config:save("reina_composure", reina.composure)
   config:save("reina_annoyance", reina.annoyance)
   config:save("reina_normalization", reina.normalization)

   config:save("machine_active", reina.machine.active)
   config:save("machine_profile", reina.machine.profile)
   config:save("machine_intensity", reina.machine.intensity)
   config:save("machine_load", reina.machine.load)
   config:save("machine_duration", reina.machine.duration)
   config:save("machine_recovery_debt", reina.machine.recoveryDebt)
end

function State.load()
   config:setName("project_blacksite_v01")

   local d = State.data
   local mission = d.mission
   local reina = d.reina

   mission.phase = config:load("mission_phase") or mission.phase
   mission.step = numberOr(config:load("mission_step"), mission.step)
   mission.alert = numberOr(config:load("mission_alert"), mission.alert)
   mission.heading = numberOr(config:load("mission_heading"), mission.heading)
   mission.flags = config:load("mission_flags") or {}

   local ox = config:load("origin_x")
   local oy = config:load("origin_y")
   local oz = config:load("origin_z")
   if type(ox) == "number" and type(oy) == "number" and type(oz) == "number" then
      mission.origin = vec(ox, oy, oz)
   end

   reina.follow = config:load("reina_follow") or reina.follow
   reina.disguise = config:load("reina_disguise") or reina.disguise

   local compromised = config:load("reina_compromised")
   if compromised ~= nil then
      reina.compromised = compromised
   end

   reina.concealment = config:load("reina_concealment") or reina.concealment

   reina.endurance = numberOr(config:load("reina_endurance"), reina.endurance)
   reina.strain = numberOr(config:load("reina_strain"), reina.strain)
   reina.discomfort = numberOr(config:load("reina_discomfort"), reina.discomfort)
   reina.composure = numberOr(config:load("reina_composure"), reina.composure)
   reina.annoyance = numberOr(config:load("reina_annoyance"), reina.annoyance)
   reina.normalization = numberOr(config:load("reina_normalization"), reina.normalization)

   local machineActive = config:load("machine_active")
   if machineActive ~= nil then
      reina.machine.active = machineActive
   end
   reina.machine.profile = config:load("machine_profile") or reina.machine.profile
   reina.machine.intensity = numberOr(config:load("machine_intensity"), reina.machine.intensity)
   reina.machine.load = numberOr(config:load("machine_load"), reina.machine.load)
   reina.machine.duration = numberOr(config:load("machine_duration"), reina.machine.duration)
   reina.machine.recoveryDebt = numberOr(config:load("machine_recovery_debt"), reina.machine.recoveryDebt)

   d.loaded = true
end

function State.resetMission()
   local d = State.data
   local mission = d.mission
   local reina = d.reina

   mission.phase = "INSERTION"
   mission.step = 0
   mission.origin = nil
   mission.heading = 0
   mission.alert = 0
   mission.flags = {}

   reina.follow = "FOLLOW"
   reina.disguise = "FIELD"
   reina.compromised = false
   reina.concealment = "NONE"
   reina.endurance = 100
   reina.strain = 0
   reina.discomfort = 0
   reina.composure = 100
   reina.annoyance = 0
   reina.normalization = 0

   reina.machine.active = false
   reina.machine.profile = "NONE"
   reina.machine.intensity = 0
   reina.machine.load = 0
   reina.machine.duration = 0
   reina.machine.recoveryDebt = 0

   config:save("origin_x", nil)
   config:save("origin_y", nil)
   config:save("origin_z", nil)

   State.ensureOrigin()
   State.save()
end

return State
