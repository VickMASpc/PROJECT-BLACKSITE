# PROJECT BLACKSITE

A story-driven Figura stealth companion project: a serious infiltration game whose mission logic can become increasingly indecent, absurd, humiliating, and consequential without turning into an animation picker.

## v0.1 — Operation Glasshouse foundation

This build proves the core loop:

- Reina is an independent WORLD-parented companion, visible in first person.
- Follow / wait works without routine snap-teleporting.
- A procedural Reina proxy lets the systems be tested before the final Blockbench model exists.
- Mission progress and Reina state persist through Figura's config API.
- A compact custom HUD shows objective distance, companion state, dialogue, and contextual commands.
- Context commands change what happens later instead of resetting after a scene.
- The first test route covers insertion, service access, disguise, checkpoint concealment, research-floor aftermath, a maintenance-shaft consequence, the lab, and a second checkpoint.
- Endurance, strain, discomfort, annoyance, normalization, concealment, disguise, alert, and machine-state hooks already exist in the state model.

The architecture is deliberately **not**:

\`player -> menu -> animation\`

It is:

\`world context -> mission state -> Reina awareness -> available command -> persistent consequence\`

## Install

Copy:

\`avatar/PROJECT-BLACKSITE\`

into:

\`<minecraft directory>/figura/avatars/PROJECT-BLACKSITE\`

Then select **PROJECT BLACKSITE v0.1** in Figura.

Figura recognizes avatars through \`avatar.json\`; all Lua is loaded through \`script.lua\`.

## Controls

- **G** — interact / advance / confirm selected contextual command
- **H** — toggle Reina FOLLOW / WAIT
- **J** — open command menu; press again to cycle
- **Shift+J** — close command menu
- **R** — development recovery: move Reina beside the player
- **Shift+R** — wipe the v0.1 mission save and restart Operation Glasshouse

## Testing route

When a fresh save starts, BLACKSITE records the player's position and facing as the operation origin. Objectives extend forward from that heading, so a flat test world is easiest.

The HUD gives distance to the next operation node. Walk to it and press **G**.

The route is deliberately abstract in 0.1. The actual facility geometry/map is a later layer; this version is for proving that the companion, state machine, and downstream consequences work before we spend time building rooms around broken logic.

## Important current limitations

- Reina is a procedural block proxy, not the final character model.
- Navigation is lightweight local steering, not a full pathfinder.
- Reina is rendered, not a real server-side entity; Minecraft mobs do not treat her as an entity yet.
- Facility guards/cameras/scanners are mission logic in 0.1, not spawned NPC AI.
- S-Machines and the full B/D system are architected and documented, but only endurance/consequence hooks are exercised in the slice.

Read \`docs/THEME.md\`, \`docs/REINA.md\`, \`docs/CONTENT_SYSTEMS.md\`, \`docs/TECHNICAL.md\`, and \`docs/V0.1.md\` before expanding the project.
