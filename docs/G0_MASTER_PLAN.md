# G0 — Master Planning Gate

## Why G0 exists

The first BLACKSITE implementation attempt spread across too many incomplete ideas at once. That proved some Figura concepts, but it did **not** produce a game worth using.

The current code is **v0.0.1 — technical spike**.

G0 exists to design the actual experience before implementation resumes.

---

# Development gates

## G0 — Design Bible

Goal: know what BLACKSITE is before building it.

Must lock:

- player taste/desire priorities
- player role
- Reina/player history and authority relationship
- Reina personality and behavioral boundaries
- core interaction grammar
- companion autonomy
- scene escalation grammar
- device/prop logic
- humiliation logic
- persistent aftermath
- restraint/control logic
- facility premise
- Operation Glasshouse plot
- first mission pacing
- technical boundaries imposed by Figura
- exact acceptance criteria for G1

No gameplay feature is considered implemented during G0.

---

## G1 — Reina Companion Prototype

Goal: Reina alone is pleasant to use in a normal Minecraft world.

Required:

- actual Reina model
- stable WORLD-parented rendering
- clean first-person behavior
- believable idle/walk/turning/gaze
- FOLLOW
- WAIT
- COME HERE
- MOVE THERE
- sensible stopping distance
- basic stairs/slopes/doorway behavior
- local obstacle handling
- manual recovery
- no routine snap-teleporting
- interaction targeting
- development/debug state readout
- clean animation transitions

Exit test:

Spend ten minutes walking around a normal world with Reina without story content. If she still feels like a floating prop, G1 is not done.

---

## G2 — Interaction and Character Presence

Goal: interacting with Reina feels intentional rather than menu-driven.

Required:

- context targeting
- compact command UI
- dialogue presentation
- response states
- gaze/proximity reactions
- simple autonomous reactions
- persistent local relationship/state facts
- clear division between automatic behavior and ordered behavior

---

## G3 — Environment Context

Goal: the world can create situations rather than merely trigger scripts.

Required:

- tagged locations
- trigger volumes
- authored scene anchors
- tagged props/interactables
- witness/publicness context
- security context
- reusable condition resolver

---

## G4 — Scene Runtime

Goal: one authored scene can be long, reactive, interruptible, and reliable.

Required:

- scene entry/exit
- positioning
- dialogue stages
- animation stages
- prop attachment
- choice/command branching
- conditional loops
- interruption/recovery
- persistence handoff

Exit test:

A single long scene can deepen one premise for many minutes without breaking placement, input, or state.

---

## G5 — Consequence Runtime

Goal: what happens in a scene matters after it ends.

Required:

- outfit/equipment state
- posture/movement modifier
- endurance/strain where relevant
- body-specific scene state
- witness memory
- facility logs/evidence
- cleanup/recovery
- later callbacks

---

## G6 — Stealth Game

Goal: the facility becomes an actual infiltration game.

Required:

- cameras
- patrol logic
- suspicion
- detection/alert
- restricted access
- hiding/cover
- disguises
- access credentials
- route choice

---

## G7 — Adult Scene Systems

Goal: the project can support the actual scenes the player wants.

This gate is **not** a fetish taxonomy and does not require equal support for every possible mechanic.

It implements what the approved scenes require.

Likely requirements include:

- internal device/ball state
- multiple-object tracking
- difficult extraction/expulsion
- stuck/slip-back progression
- bodily control/accident state
- restraints and positional control where desired
- machines/devices individually designed around appealing scenes
- player-controlled technical authority
- long dialogue/choice escalation
- persistent erotic aftermath

Exit test:

At least one adult scenario is genuinely desirable to replay, not merely technically functional.

---

## G8 — Operation Glasshouse Vertical Slice

Goal: one polished mission that demonstrates the actual game.

---

# G0 work order

1. **Player Desire Bible**
2. **First flagship erotic scene**
3. **Reina character bible derived from the scene**
4. **Commander/Reina relationship**
5. **Player interaction grammar**
6. **Autonomy/objection/refusal rules**
7. **Facility premise**
8. **Operation Glasshouse plot**
9. **Additional high-priority scenes**
10. **Restraint/control logic**
11. **Persistent consequence model**
12. **Dialogue system**
13. **Technical architecture**
14. **G1 exact specification**

The first two now exist as:

- \`PLAYER_DESIRE_BIBLE.md\`
- \`SCENE_01_DEVICE_EXTRACTION.md\`

---

# Planning rule

A complete small thing is more valuable than ten technically-present systems.

And for erotic content:

**personal desirability beats abstract design elegance.**
