local Reina = {}

local State
local modelFile
local worldRoot
local root
local body
local head
local leftArm
local rightArm
local leftForearm
local rightForearm
local leftLeg
local rightLeg
local leftLowerLeg
local rightLowerLeg

local function clamp(v, a, b)
   return math.max(a, math.min(b, v))
end

local function flat(v)
   local out = vec(v.x, 0, v.z)
   local len = out:length()
   if len < 0.0001 then return vec(0,0,1) end
   return out / len
end

local function heading(v)
   return math.deg(math.atan2(-v.x, v.z))
end

local function angleDelta(a, b)
   return (b - a + 180) % 360 - 180
end

local function approachAngle(current, target, maxStep)
   return current + clamp(angleDelta(current, target), -maxStep, maxStep)
end

local function playerForward()
   return flat(player:getLookDir())
end

local function playerRight()
   local f = playerForward()
   return vec(-f.z, 0, f.x)
end

local function groundAt(p)
   local _, hit = raycast:block(
      p + vec(0, 1.8, 0),
      p + vec(0, -2.8, 0),
      "COLLIDER",
      "NONE"
   )
   if not hit then return nil end
   return vec(p.x, hit.y, p.z)
end

local function validStep(from, candidate)
   -- Ground probing is enough for local locomotion:
   -- * flat floor -> same Y, valid
   -- * slab/stair -> small Y change, valid
   -- * wall/fence -> probe hits its top, Y change is too high
   -- * hole -> probe lands too far below
   --
   -- The previous horizontal ray was the reason Reina reported WALL on open
   -- grass, so G1 no longer uses it.
   local grounded = groundAt(candidate)
   if not grounded then return nil, "NO_GROUND" end

   local dy = grounded.y - from.y
   if dy > 0.72 then return nil, "STEP_TOO_HIGH" end
   if dy < -1.25 then return nil, "DROP_TOO_FAR" end

   return grounded, nil
end

local function rotateFlat(dir, degrees)
   local a = math.rad(degrees)
   local c = math.cos(a)
   local s = math.sin(a)
   return vec(
      dir.x * c - dir.z * s,
      0,
      dir.x * s + dir.z * c
   )
end

local function spawnPoint()
   local p = player:getPos() + playerRight() * 1.35 - playerForward() * 0.35
   return groundAt(p) or p
end

local function followPoint()
   local p = player:getPos()
   return groundAt(p - playerForward() * 2.15 + playerRight() * 0.45)
      or (p - playerForward() * 2.15 + playerRight() * 0.45)
end

local function applyPalette()
   local skin = vec(0.72, 0.50, 0.39)
   local hairColor = vec(0.055, 0.045, 0.065)
   local eyeColor = vec(0.40, 0.26, 0.58)
   local suit = vec(0.095, 0.105, 0.13)
   local gearColor = vec(0.20, 0.16, 0.25)
   local boot = vec(0.045, 0.045, 0.055)

   head.Skin:setColor(skin)
   head.Hair:setColor(hairColor)
   head.Eyes:setColor(eyeColor)

   body.Suit:setColor(suit)
   body.Gear:setColor(gearColor)

   leftArm.Suit:setColor(suit)
   leftForearm.Suit:setColor(suit)
   leftForearm.Skin:setColor(skin)

   rightArm.Suit:setColor(suit)
   rightForearm.Suit:setColor(suit)
   rightForearm.Skin:setColor(skin)

   leftLeg.Suit:setColor(suit)
   leftLowerLeg.Suit:setColor(suit)
   leftLowerLeg.Boot:setColor(boot)

   rightLeg.Suit:setColor(suit)
   rightLowerLeg.Suit:setColor(suit)
   rightLowerLeg.Boot:setColor(boot)
end

function Reina.init(state)
   State = state

   modelFile = (models.models and models.models.reina) or models.reina
   worldRoot = modelFile.WorldRoot
   root = worldRoot.Root
   body = root.RigBody
   head = root.RigHead
   leftArm = root.RigLeftArm
   rightArm = root.RigRightArm
   leftForearm = leftArm.LeftForearm
   rightForearm = rightArm.RightForearm
   leftLeg = root.RigLeftLeg
   rightLeg = root.RigRightLeg
   leftLowerLeg = leftLeg.LeftLowerLeg
   rightLowerLeg = rightLeg.RightLowerLeg

   applyPalette()

   local r = State.reina
   r.pos = spawnPoint()
   r.prevPos = r.pos
   r.yaw = player:getBodyYaw()
   r.prevYaw = r.yaw
   r.target = nil

   State.say("Reina online. H follow/wait • G come • J move there • R recover", 150)
end

function Reina.recover()
   local r = State.reina
   r.pos = spawnPoint()
   r.prevPos = r.pos
   r.target = nil
   r.mode = "FOLLOW"
   r.lost = false
   r.blocked = false
   State.say("Reina recovered beside you. Navigation state reset.", 90)
end

function Reina.toggleFollow()
   local r = State.reina
   if r.mode == "FOLLOW" then
      r.mode = "WAIT"
      r.target = nil
      State.say("Reina: Holding here.", 55)
   else
      r.mode = "FOLLOW"
      r.target = nil
      r.lost = false
      State.say("Reina: Following.", 55)
   end
end

function Reina.comeHere()
   local p = player:getPos()
   r = State.reina
   r.target = groundAt(p + playerRight() * 1.15 - playerForward() * 0.15) or p
   r.mode = "MOVE"
   r.lost = false
   State.say("Reina: Coming.", 50)
end

function Reina.moveThereFromCrosshair()
   local eye = player:getPos() + vec(0, player:getEyeHeight(), 0)
   local look = player:getLookDir()
   local _, hit = raycast:block(eye, eye + look * 18, "COLLIDER", "NONE")

   if not hit then
      State.say("No walkable target under the crosshair.", 60)
      return
   end

   local candidate = hit - look * 0.55 + vec(0, 0.25, 0)
   local target = groundAt(candidate)
   if not target then
      State.say("That target has no usable ground.", 60)
      return
   end

   State.reina.target = target
   State.reina.mode = "MOVE"
   State.reina.lost = false
   State.say("Reina: Moving.", 45)
end

local function chooseTarget()
   local r = State.reina
   if r.mode == "FOLLOW" then
      return followPoint(), 0.55
   elseif r.mode == "MOVE" and r.target then
      return r.target, 0.35
   end
   return nil, 0
end

local function updateLookedAt()
   local r = State.reina
   local eye = player:getPos() + vec(0, player:getEyeHeight(), 0)
   local dir = player:getLookDir()
   local center = r.pos + vec(0, 1.5, 0)
   local to = center - eye
   local t = to.x * dir.x + to.y * dir.y + to.z * dir.z

   if t <= 0 or t > 7 then
      r.lookedAt = false
      return
   end

   local closest = eye + dir * t
   r.lookedAt = (center - closest):length() < 0.60
end

function Reina.tick()
   local r = State.reina
   if not r.pos then return end

   r.prevPos = r.pos
   r.prevYaw = r.yaw
   r.moving = false
   r.blocked = false
   r.speed = 0

   updateLookedAt()

   local playerDistance = (player:getPos() - r.pos):length()
   if r.mode == "FOLLOW" and playerDistance > 28 then
      r.lost = true
      return
   end

   local target, stopDistance = chooseTarget()

   if target then
      local delta = target - r.pos
      local horizontal = vec(delta.x, 0, delta.z)
      local dist = horizontal:length()

      if dist <= stopDistance then
         if r.mode == "MOVE" then
            r.mode = "WAIT"
            r.target = nil
            State.say("Reina: Here.", 45)
         end
      else
         local dir = horizontal / dist
         local step = math.min(0.155, dist)

         -- Try the direct route first, then progressively wider steering arcs.
         -- This is still local steering rather than a full pathfinder, but it
         -- lets Reina skirt ordinary corners and small holes instead of
         -- declaring herself blocked on the first failed sample.
         local steeringAngles = {0, 28, -28, 55, -55, 82, -82, 115, -115}
         local picked = nil
         local lastReason = "NO_VALID_STEP"

         for _, angle in ipairs(steeringAngles) do
            local candidate = r.pos + rotateFlat(dir, angle) * step
            local point, reason = validStep(r.pos, candidate)
            if point then
               picked = point
               break
            end
            lastReason = reason or lastReason
         end

         if picked then
            r.blockedReason = ""

            r.pos = picked
            r.speed = (r.pos - r.prevPos):length()
            r.walkClock = r.walkClock + r.speed * 8.2
            r.moving = true
            r.yaw = approachAngle(r.yaw, heading(r.pos - r.prevPos), 13)
         else
            r.blocked = true
            r.blockedReason = lastReason
         end
      end
   end

   -- Head-first turning:
   -- Reina does NOT rotate her whole body every time the player strafes.
   -- She lets her head track first. If the player stays beyond a comfortable
   -- neck angle for a short moment, her body turns to catch up.
   if not r.moving and playerDistance < 6.5 then
      local toPlayer = player:getPos() - r.pos
      local flatToPlayer = vec(toPlayer.x, 0, toPlayer.z)

      if flatToPlayer:length() > 0.2 then
         local targetYaw = heading(flatToPlayer)
         local neckDemand = math.abs(angleDelta(r.yaw, targetYaw))

         if neckDemand > 52 then
            r.turnIntentTicks = (r.turnIntentTicks or 0) + 1
         elseif neckDemand < 42 then
            r.turnIntentTicks = 0
         end

         if (r.turnIntentTicks or 0) >= 6 then
            r.bodyTurning = true
         end

         if r.bodyTurning then
            r.yaw = approachAngle(r.yaw, targetYaw, 4.2)

            if math.abs(angleDelta(r.yaw, targetYaw)) < 20 then
               r.bodyTurning = false
               r.turnIntentTicks = 0
            end
         end
      end
   else
      r.turnIntentTicks = 0
      if r.moving then r.bodyTurning = false end
   end
end

function Reina.render(delta)
   local r = State.reina
   if not r.pos or not r.prevPos then return end

   local pos = r.prevPos + (r.pos - r.prevPos) * delta
   local yaw = r.prevYaw + angleDelta(r.prevYaw, r.yaw) * delta

   worldRoot:setPos(pos * 16)

   -- Figura ModelPart Y rotation runs opposite Minecraft's logical yaw for
   -- this WORLD rig. Keep r.yaw in normal world/Minecraft coordinates and
   -- invert only at render time.
   worldRoot:setRot(0, -yaw, 0)

   local phase = r.walkClock
   local swing = r.moving and math.sin(phase) or 0
   local bob = r.moving and math.abs(math.sin(phase * 2)) * 0.16
      or math.sin((State.tickCount + delta) * 0.055) * 0.045

   root:setPos(0, bob, 0)

   leftLeg:setRot(swing * 30, 0, 0)
   rightLeg:setRot(-swing * 30, 0, 0)
   leftLowerLeg:setRot(math.max(0, -swing) * 11, 0, 0)
   rightLowerLeg:setRot(math.max(0, swing) * 11, 0, 0)

   leftArm:setRot(-swing * 18, 0, -2)
   rightArm:setRot(swing * 18, 0, 2)
   leftForearm:setRot(-7 + math.max(0, swing) * 7, 0, 0)
   rightForearm:setRot(-7 + math.max(0, -swing) * 7, 0, 0)

   body:setRot(r.moving and 1.5 or math.sin((State.tickCount + delta) * 0.045) * 0.7, 0, 0)

   local toPlayer = (player:getPos() + vec(0, player:getEyeHeight(), 0))
      - (pos + vec(0, 1.65, 0))
   local flatDist = vec(toPlayer.x,0,toPlayer.z):length()

   if toPlayer:length() < 8 and flatDist > 0.05 then
      local lookYaw = angleDelta(yaw, heading(toPlayer))
      local lookPitch = math.deg(math.atan2(toPlayer.y, flatDist))

      -- The body only starts catching up after this reaches the neck limit,
      -- so normal side-to-side player movement remains a head turn.
      head:setRot(
         clamp(lookPitch, -28, 24),
         clamp(lookYaw, -58, 58),
         0
      )
   else
      head:setRot(0,0,0)
   end
end

function Reina.getDistance()
   if not State.reina.pos then return 0 end
   return (player:getPos() - State.reina.pos):length()
end

return Reina
