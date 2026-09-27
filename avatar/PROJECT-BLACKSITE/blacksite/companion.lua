local Companion = {}

local State = nil

local worldRoot = models:newPart("BLACKSITE_WORLD", "WORLD")
local body = worldRoot:newPart("REINA_PROXY")

local visual = {}

local function addBlock(name, blockId, x, y, z, sx, sy, sz)
   local task = body:newBlock(name)
   task:setBlock(blockId)
   task:setPos(x, y, z)
   task:setScale(sx, sy, sz)
   visual[name] = task
   return task
end

-- A deliberately simple temporary body. It exists so follow/state/rendering can be
-- tested now instead of coupling the entire project to a final bbmodel.
addBlock("Head",      "minecraft:white_terracotta", -2.7, 20.5, -2.7, 0.34, 0.34, 0.34)
addBlock("HairCap",   "minecraft:black_concrete",   -2.9, 24.0, -2.9, 0.36, 0.15, 0.36)
addBlock("HairBack",  "minecraft:black_concrete",   -2.4, 17.2, -3.2, 0.30, 0.46, 0.10)

addBlock("Torso",     "minecraft:black_concrete",   -2.6, 11.8, -1.5, 0.32, 0.52, 0.19)
addBlock("Hips",      "minecraft:gray_concrete",    -3.0, 8.0,  -1.6, 0.38, 0.22, 0.20)

addBlock("LeftArm",   "minecraft:black_concrete",   -4.5, 11.9, -1.0, 0.11, 0.49, 0.12)
addBlock("RightArm",  "minecraft:black_concrete",    2.7, 11.9, -1.0, 0.11, 0.49, 0.12)

addBlock("LeftLeg",   "minecraft:black_concrete",   -2.5, 0.0,  -1.1, 0.14, 0.53, 0.14)
addBlock("RightLeg",  "minecraft:black_concrete",    0.3, 0.0,  -1.1, 0.14, 0.53, 0.14)

local function flatDirection(v)
   local flat = vec(v.x, 0, v.z)
   local length = flat:length()
   if length < 0.001 then
      return vec(0, 0, 1)
   end
   return flat / length
end

local function playerForward()
   return flatDirection(player:getLookDir())
end

local function playerRight()
   local forward = playerForward()
   return vec(-forward.z, 0, forward.x)
end

local function groundAt(pos)
   local ok, _, hit = pcall(function()
      return raycast:block(
         pos + vec(0, 2.0, 0),
         pos + vec(0, -3.0, 0),
         "COLLIDER",
         "NONE"
      )
   end)

   if ok and hit then
      return vec(pos.x, hit.y, pos.z)
   end

   return pos
end

local function segmentClear(fromPos, toPos)
   local ok, block = pcall(function()
      return raycast:block(
         fromPos + vec(0, 0.85, 0),
         toPos + vec(0, 0.85, 0),
         "COLLIDER",
         "NONE"
      )
   end)

   if not ok then
      return true
   end

   return block == nil
end

local function spawnPosition()
   local p = player:getPos()
   local right = playerRight()
   return groundAt(p + right * 1.5)
end

function Companion.applyAppearance()
   if not State then
      return
   end

   local disguise = State.data.reina.disguise

   if disguise == "STAFF" then
      visual.Torso:setBlock("minecraft:light_gray_concrete")
      visual.LeftArm:setBlock("minecraft:white_concrete")
      visual.RightArm:setBlock("minecraft:white_concrete")
      visual.Hips:setBlock("minecraft:gray_concrete")
   else
      visual.Torso:setBlock("minecraft:black_concrete")
      visual.LeftArm:setBlock("minecraft:black_concrete")
      visual.RightArm:setBlock("minecraft:black_concrete")
      visual.Hips:setBlock("minecraft:gray_concrete")
   end
end

function Companion.init(state)
   State = state
   local r = State.data.reina

   if r.pos == nil then
      r.pos = spawnPosition()
      r.prevPos = r.pos
   end

   Companion.applyAppearance()
end

function Companion.resetBesidePlayer()
   if not State then
      return
   end

   local r = State.data.reina
   r.pos = spawnPosition()
   r.prevPos = r.pos
   r.lost = false
   r.blocked = false
   r.follow = "FOLLOW"
   State.save()
end

function Companion.toggleFollow()
   local r = State.data.reina
   if r.follow == "FOLLOW" then
      r.follow = "WAIT"
   else
      r.follow = "FOLLOW"
      r.lost = false
   end
   State.save()
   return r.follow
end

function Companion.setDisguise(disguise)
   State.data.reina.disguise = disguise
   Companion.applyAppearance()
   State.save()
end

function Companion.tick()
   if not State then
      return
   end

   local r = State.data.reina
   if r.pos == nil then
      Companion.resetBesidePlayer()
      return
   end

   r.prevPos = r.pos
   r.moving = false
   r.blocked = false

   local playerPos = player:getPos()
   local separation = (playerPos - r.pos):length()

   -- Important inherited Cynthia lesson: no routine teleport-follow.
   -- If the companion is truly lost, stop pretending. Let the player recover with R.
   if separation > 30 then
      r.lost = true
      return
   end

   if r.follow ~= "FOLLOW" then
      return
   end

   local forward = playerForward()
   local target = playerPos - forward * 2.35
   target = groundAt(target)

   local delta = target - r.pos
   local horizontal = vec(delta.x, 0, delta.z)
   local distance = horizontal:length()

   if distance < 0.35 then
      return
   end

   local direction = horizontal / distance
   local speed = 0.145

   if r.compromised then
      speed = speed * 0.76
   end

   if r.endurance < 50 then
      speed = speed * (0.72 + (r.endurance / 180))
   end

   if r.strain > 60 then
      speed = speed * 0.78
   end

   local candidate = groundAt(r.pos + direction * math.min(speed, distance))

   if not segmentClear(r.pos, candidate) then
      local side = vec(-direction.z, 0, direction.x)
      local leftCandidate = groundAt(r.pos + side * speed)
      local rightCandidate = groundAt(r.pos - side * speed)

      if segmentClear(r.pos, leftCandidate) then
         candidate = leftCandidate
      elseif segmentClear(r.pos, rightCandidate) then
         candidate = rightCandidate
      else
         r.blocked = true
         return
      end
   end

   r.pos = candidate
   r.yaw = player:getBodyYaw()
   r.walkClock = r.walkClock + speed * 7.5
   r.moving = true
end

function Companion.render(delta)
   if not State then
      return
   end

   local r = State.data.reina
   if not r.pos or not r.prevPos then
      return
   end

   local renderPos = r.prevPos + (r.pos - r.prevPos) * delta
   local bob = 0

   if r.moving then
      bob = math.sin(r.walkClock) * 0.18
   end

   worldRoot:setPos(renderPos * 16)
   worldRoot:setRot(0, -r.yaw + 180, 0)
   body:setPos(0, bob, 0)
end

function Companion.statusLine()
   local r = State.data.reina
   local movement = r.compromised and "CAREFUL" or "NORMAL"

   if r.lost then
      movement = "LOST"
   elseif r.blocked then
      movement = "BLOCKED"
   end

   return string.format(
      "%s / %s / %s",
      r.follow,
      r.disguise,
      movement
   )
end

return Companion
