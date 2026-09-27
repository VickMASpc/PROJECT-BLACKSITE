# Technical Architecture

## Figura assumptions

BLACKSITE uses the current Figura avatar layout:

\`avatar.json\` + Lua files, with \`script.lua\` as the only autoScript.

The companion visual is WORLD-parented. Figura WORLD parent parts use world coordinates multiplied by 16 model units per Minecraft block.

The HUD is a HUD-parented model part using TextTask.

Persistent host data uses Figura's config API.

## Runtime

\`script.lua\` is intentionally thin.

It owns the event loop and delegates to:

- \`blacksite/state.lua\`
- \`blacksite/companion.lua\`
- \`blacksite/mission.lua\`
- \`blacksite/ui.lua\`

### State

Single source of truth for:

- mission
- Reina
- UI
- future machine runtime

State changes that matter later are saved immediately.

### Companion

Owns:

- procedural v0.1 visual proxy
- world transform
- follow/wait
- lightweight local steering
- no-auto-teleport rule
- disguise appearance
- recovery placement

The final Blockbench model should replace the visual layer without replacing mission state or follow logic.

### Mission

Owns:

- Operation Glasshouse phases
- objective positions relative to mission origin
- contextual unlocks
- consequences
- mission-specific dialogue
- action execution

The mission never asks the UI to invent actions. It exposes the currently legal contextual actions.

### UI

Owns:

- keybinds
- HUD
- menu selection
- generic commands such as follow/wait and status

The UI does not decide story consequences.

## Input flow

Normal:

\`G -> Mission.interact()\`

Menu:

\`J -> open/cycle -> G -> selected command -> Mission.executeAction()\`

Direct companion:

\`H -> follow/wait\`

Recovery:

\`R -> reposition companion only\`

\`Shift+R -> reset v0.1 mission state\`

## Context flow

The intended mature architecture is:

\`world sensors -> context resolver -> mission rules -> Reina state -> available commands -> scene controller -> persistent state\`

0.1 currently uses objective nodes instead of real world sensors. This is deliberate: the state/controller contract should be stable before cameras, guards, doors, and bespoke geometry are attached.

## Cynthia lessons intentionally preserved

- World-parent the companion instead of trying to pretend she is the player's model.
- Keep a manual positioning/recovery path for development.
- Do not auto-follow by snapping/teleporting every time distance grows.
- Do not duplicate player-head rendering in first person.
- Avoid giant hierarchical animation transforms that make scene offsets impossible to reason about.
- Scene positions should eventually be captured as explicit world-relative anchors.
- Debug/animation viewing should remain a development tool, not become the actual game UI.

## Next technical gate after 0.1 test

Once the Lua slice loads without runtime errors:

1. replace procedural proxy with Reina bbmodel v1
2. add real pose/locomotion animations
3. add world trigger volumes and authored facility anchors
4. add camera/security state
5. add scene controller with explicit anchor capture
6. implement first S-Machine runtime using the endurance schema already present
