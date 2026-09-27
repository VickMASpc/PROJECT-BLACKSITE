# PROJECT BLACKSITE

Story-driven adult Figura companion/infiltration project.

## Development status

**G1 — Reina Companion Prototype is now active.**

The earlier mission/HUD/state implementation is retained in the repository as the **v0.0.1 technical spike**, but it is no longer loaded by the active avatar.

Planning has been intentionally cut off at the point needed to build something real. The minimum locked creative canon is in `docs/CORE_LOCK.md`. The flagship adult target remains `docs/SCENE_01_DEVICE_EXTRACTION.md`.

## Current playable target

G1 is deliberately narrow: make Reina feel good as a companion in ordinary Minecraft before building story content around her.

The active avatar now contains:

- a real hierarchical Reina field model v1
- world-independent rendering visible in first person
- idle/walk animation
- natural-ish gaze
- FOLLOW / WAIT
- COME HERE
- MOVE THERE
- local ground/obstacle handling
- manual recovery
- compact development HUD

## Install

Copy:

`avatar/PROJECT-BLACKSITE`

to:

`<minecraft directory>/figura/avatars/PROJECT-BLACKSITE`

Then select **PROJECT BLACKSITE — G1 Reina**.

## Controls

- **H** — follow / wait
- **G** — come here
- **J** — move to crosshair target
- **R** — recover Reina beside player
- **K** — toggle G1 HUD

## Testing priority

Do not test story content yet.

Walk around with Reina. Use stairs, slabs, doorways, slopes, cramped interiors, first person, and third person. Try all four movement commands.

If something feels bad, that is the thing we fix next.

See `docs/G1.md` for the actual acceptance criteria.
