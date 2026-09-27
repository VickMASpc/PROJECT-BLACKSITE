# G0 — Master Planning Gate

## Why G0 exists

The first BLACKSITE implementation attempt spread across too many incomplete ideas at once: companion following, mission nodes, persistence, HUD, endurance, disguise, contextual commands, and future machine hooks.

That proved some Figura concepts, but it did **not** produce a game worth using.

G0 exists to prevent that pattern from repeating.

No new gameplay implementation starts until the project can answer, in writing, what the game is, what Reina is, what the player can do, how scenes work, what the facility is, how adult content escalates, and what one complete mission is supposed to feel like.

The current code is therefore **v0.0.1 — technical spike**.

---

# Development gates

## G0 — Design Bible

Goal: know what BLACKSITE is before building it.

Must lock:

- player role
- Reina/player history and authority relationship
- Reina's baseline personality and behavioral boundaries
- core interaction grammar
- companion autonomy
- dialogue/reporting system
- scene escalation grammar
- humiliation logic
- persistent-compromise logic
- S-Machine concept and categories
- B/D/control-state taxonomy
- facility premise
- Operation Glasshouse plot
- first mission pacing
- technical boundaries imposed by Figura
- exact acceptance criteria for G1

No feature is "implemented" during G0.

---

## G1 — Reina Companion Prototype

Goal: Reina alone is pleasant to use in a normal Minecraft world.

Nothing from later gates counts if this is weak.

Required:

- actual Reina model, not a block proxy
- stable WORLD-parented rendering
- clean first-person behavior
- believable idle
- believable walk
- turning
- gaze
- FOLLOW
- WAIT
- COME HERE
- MOVE THERE
- sensible stopping distance
- stairs/slopes/doorway behavior
- local obstacle handling
- manual recovery
- no routine snap-teleporting
- basic interaction targeting
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
- gaze reactions
- proximity reactions
- player-staring awareness where appropriate
- simple autonomous reactions
- persistent local relationship/state facts
- clear division between what Reina does automatically and what requires an order

Exit test:

A player can communicate with Reina for several minutes in an empty test space and understand what she is thinking/doing without reading debug text.

---

## G3 — Environment Context

Goal: the world can tell Reina and the player what kind of situation they are in.

Required:

- tagged locations
- trigger volumes
- authored scene anchors
- tagged props/interactables
- room states
- cover/disguise contexts
- witness/publicness context
- security context
- reusable condition resolver

Exit test:

Moving Reina through a small test facility causes different valid commands/reactions without hardcoding each interaction directly into the UI.

---

## G4 — Scene Runtime

Goal: one authored scene can be long, reactive, interruptible, and reliable.

Required:

- scene entry
- position locking/soft positioning
- camera optionality
- dialogue stages
- animation stages
- prop attachment
- command choice
- conditional branches
- interruption/recovery
- exit state
- persistence handoff

Exit test:

A single ten-minute non-explicit test scene can branch, pause, resume, and leave state behind without breaking Reina's placement or controls.

---

## G5 — Consequence Runtime

Goal: what happens in a scene matters after it ends.

Required:

- outfit state
- equipment state
- posture/movement modifier
- endurance/strain
- discomfort
- composure
- witness memory
- facility log/evidence state
- disguise integrity
- recovery
- later-context callbacks

Exit test:

A choice made in one room visibly changes Reina, her dialogue, her available actions, or facility behavior several rooms later.

---

## G6 — Stealth Game

Goal: BLACKSITE becomes an actual infiltration game.

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
- nonlethal failure/recovery states where possible

Exit test:

A small facility floor is enjoyable without any adult content enabled.

---

## G7 — Adult Systems

Goal: erotic/humiliating content becomes deep gameplay instead of a gallery.

Required:

- S-Machine runtime
- machine endurance/recovery
- control/restraint states
- compromised locomotion
- reporting under pressure
- public/private/witness context
- normalization-driven behavior
- persistent aftermath
- multiple ways for a scene to escalate without merely increasing physical intensity

Exit test:

One adult scenario can sustain meaningful interaction for a long scene using dialogue, procedure, state, choices, and aftermath rather than a stack of unrelated animations.

---

## G8 — Operation Glasshouse Vertical Slice

Goal: one polished mission that demonstrates the actual game.

Required:

- authored facility area
- insertion
- reconnaissance
- cover/disguise play
- one major escalating compromised-state sequence
- one S-Machine sequence
- at least one serious plot discovery
- route variation
- persistent consequences
- extraction
- post-mission state

Exit test:

The mission can be played from start to finish and feels like a coherent obscure-JP-eroge-meets-infiltration game rather than a tech demo.

---

# G0 work order

We will complete G0 in this order:

1. **Player + Reina relationship**
2. **Core scene grammar**
3. **Reina character bible**
4. **Player interaction grammar**
5. **Autonomy and refusal/objection rules**
6. **Facility premise**
7. **Operation Glasshouse plot**
8. **Humiliation/context model**
9. **S-Machine taxonomy**
10. **B/D/control-state taxonomy**
11. **Persistent consequence model**
12. **Dialogue/report system**
13. **Technical architecture**
14. **G1 exact specification**

The first four are started in \`DESIGN_BIBLE.md\`.

---

# Planning rule

Do not solve future problems by implementing placeholders.

If a later system is known but not ready, document its contract and leave it unimplemented.

A complete small thing is more valuable than ten "technically present" systems.
