# PROJECT BLACKSITE

A story-driven Figura stealth companion project.

## v0.1 target

Operation Glasshouse begins as a real playable prototype rather than an animation gallery. The first milestone proves:

- an independent world-rendered companion
- stable follow / wait behavior without constant snap-teleporting
- contextual commands
- persistent mission and companion state
- a compact custom HUD
- a first mission chain: insertion -> service wing -> disguise -> checkpoint -> research floor
- consequences that survive the scene which created them

The current Reina model is intentionally a procedural proxy assembled in Lua so v0.1 can be tested before the final Blockbench model lands.

## Install

Copy `avatar/PROJECT-BLACKSITE` into:

`<minecraft directory>/figura/avatars/PROJECT-BLACKSITE`

Then select **PROJECT BLACKSITE v0.1** in Figura.

Default controls:

- **G** - context interaction / advance
- **H** - follow / wait
- **J** - command menu
- **R** - reset Reina beside the player (development recovery only)

## Design rule

BLACKSITE is not `player -> menu -> animation`.

It is:

`world context -> mission state -> Reina awareness -> available command -> consequence`

See `docs/` before adding scenes or systems. The tone, Reina characterization, adult-content architecture, endurance systems, and v0.1 acceptance criteria are documented there.

## Status

**0.1 in active implementation.**
