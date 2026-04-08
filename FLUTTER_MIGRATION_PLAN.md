# Flutter/Dart Migration Plan

## Purpose

This document defines the exact repository structure and implementation rollout for converting the existing web prototype into a Flutter/Dart project.

This plan is intentionally specific. The goal is to remove ambiguity about:

- what gets built first
- where code should live
- which logic belongs in pure Dart versus Flutter UI
- which prototype features are required for parity
- which future-facing features must be deferred until after local parity exists

The current prototype is a local, single-client game prototype implemented in static web files. The long-term product direction is larger than what exists in code today, so this migration must preserve the current playable prototype while also setting up a clean architecture for later multiplayer work.

## Decision Summary

### We are not doing a direct widget-for-widget port

The current prototype mixes rules, view state, DOM animation, and rendering in one large file. Reproducing that structure in Flutter would produce a brittle codebase immediately.

Instead, the migration will use:

- a pure Dart game engine package for game rules and state transitions
- a Flutter app package for rendering, interaction, animations, and device-specific behavior

### We are building a workspace, not a single flat Flutter app

The engine needs to stay portable so it can later be reused by:

- Flutter mobile
- Flutter desktop
- Flutter web
- server-side validation or authoritative game logic
- multiplayer simulation and replay tooling

That means the engine must not import Flutter.

### We are targeting local parity first

The first milestone is not multiplayer. The first milestone is a clean Flutter app that reproduces the current local prototype behavior.

That includes:

- board state
- player roster
- turn loop
- travel
- heal
- save school
- Silver Wolf pressure
- player-vs-player challenge flow
- combat encounter flow
- undo support for the currently undoable actions
- event log

That does **not** include:

- sign-in
- persistent accounts
- lobby creation
- real-time networking
- authoritative server logic
- matchmaking
- fully implemented technique activation

## Migration Scope

### In scope for Flutter parity v1

The Flutter parity version must include:

1. A playable local single-device game loop.
2. The same town, road, player, and school setup currently defined in the web prototype.
3. The same combat deck definitions and combat phase progression currently implemented.
4. The current Silver Wolf challenge and school destruction pressure loop.
5. The current injury, reputation, bonus-action, and form-point behavior.
6. Current modal flows:
   - challenge selection
   - challenge accept/decline
   - combat encounter
   - hometown selection if it is intentionally kept
7. Current undo behavior for the actions that already support undo.
8. A responsive UI that works on phone, tablet, and desktop form factors.

### Explicitly out of scope for parity v1

The following items must not be allowed to expand the initial port:

1. Multiplayer.
2. Authentication.
3. Lobby flow.
4. Real-time synchronization.
5. Persistence beyond simple local debugging or save-state serialization.
6. New combat rules that do not exist in the prototype.
7. Full technique activation rules beyond what is already implemented.
8. New map systems, quests, or live content systems.

## Prototype Reality Check

Before implementation starts, treat the current codebase as the source of truth for playable behavior, not the aspirational README.

Important observations from the prototype:

- The main game state and UI are mostly in `src/gameApp.js`.
- Static board and player data are in `src/gameData.js`.
- The board is built from CSS positioning, not from `map.png`.
- Several image references in the JavaScript point to files that are not currently present in the repo. An asset audit is required before the Flutter UI can match the prototype visually.
- Some features are present only partially or are not currently surfaced:
  - technique activation is explicitly not implemented
  - `pendingRoll` exists in state but is not meaningfully surfaced in the UI
  - `resolveRivalFight` exists but is not currently wired into the main turn flow
  - `SchoolCard` exists but is not used in the final layout
  - the hometown selection modal state exists but does not appear to be opened in the current flow

Because of that, the migration must preserve **implemented behavior**, not dead code paths.

## Architecture Rules

These rules are non-negotiable for the Flutter migration.

### Rule 1: No game-rule logic in widgets

Widgets may:

- read view state
- dispatch commands
- render animations
- manage ephemeral UI concerns

Widgets may not:

- mutate player stats directly
- calculate combat outcomes
- advance the Silver Wolf
- decide next-player logic
- apply undo snapshots

All of that belongs in the engine package.

### Rule 2: The engine must stay pure Dart

The engine package must not import:

- `package:flutter/...`
- `dart:ui`
- device APIs

The engine may only know about:

- data models
- enums
- commands
- reducers
- rule helpers
- deterministic random interfaces
- serialization helpers

### Rule 3: Randomness must be injectable

The current prototype uses `Math.random()` inline. That is acceptable in a prototype, but not in a maintainable engine.

In the Dart engine:

- randomness must be provided by an injected `Randomizer` abstraction
- reducers must be testable with seeded outcomes
- combat draws, shuffle order, die rolls, and stumble swaps must be reproducible in tests

### Rule 4: Durable game state and ephemeral UI state must be separated

Examples of durable game state:

- player positions
- player stats
- school status
- combat encounter state
- turn order
- undo snapshot contents

Examples of ephemeral UI state:

- selected profile panel player
- whether a dialog is open
- closing animation flags
- temporary highlight states
- animation controllers
- visual "rescue complete" timing cues if they are presentation-only

Durable game state belongs in the engine. Ephemeral UI state belongs in the Flutter app.

### Rule 5: The engine API must be command-driven

Do not let UI code reach into state and mutate fields.

The app should issue commands such as:

- `TravelClockwise`
- `TravelCounterClockwise`
- `PassTurn`
- `HealCurrentPlayer`
- `SaveCurrentSchool`
- `OpenChallenge`
- `ChooseChallengeTarget`
- `AcceptChallenge`
- `DeclineChallenge`
- `SelectCombatCard`
- `SelectCombatMode`
- `TriggerCombatStumble`
- `AdvanceCombatPhase`
- `ChallengeSilverWolf`
- `UndoLastAction`

The engine should process each command through a reducer and return a new state.

## State Ownership Decisions

The current prototype keeps many values in one React component. The Flutter migration must split them intentionally.

### Engine-owned state

These fields belong in `GameState` or related engine models:

- players
- schools
- current player index
- actions remaining
- current-turn bonus actions remaining
- next arrival order
- pending roll state
- event log
- winner identity
- game over reason
- challenge state
- combat state
- undo snapshot

Reason: these values either affect gameplay directly, gate legal moves, or must be restorable through undo/replay.

### App-owned state

These fields belong in Flutter controller/view state only:

- selected profile player id
- currently open dialog or sheet
- hometown dialog closing animation flag
- animation-in-progress flags
- focus, hover, and selection highlights
- any widget-specific layout caches

Reason: these values affect presentation but do not define the actual game rules.

### Ambiguous fields that need explicit handling

- `pendingRoll`
  - Keep this in the engine.
  - Even though the current UI does not fully surface it, it still gates actions and therefore affects gameplay state.

- `battleLog`
  - Keep this in the engine as an ordered event log.
  - The Flutter app should only render it.

- `isResolvingAction`
  - Do not keep this in the engine.
  - This is an app-side interaction/animation lock.

- `isCompletingSave`
  - Do not keep this as a core engine field unless gameplay depends on it.
  - Treat it as a presentation cue emitted from the engine as an effect or derived event, then handled by the Flutter app with a short-lived UI flag.

- hometown modal visibility
  - Keep this in the app layer.
  - Decide during implementation whether hometown selection is actually part of parity scope or should be dropped because it is not currently active in the prototype flow.

## Target Repository Structure

This is the intended target structure after the migration is underway.

```text
.
|-- FLUTTER_MIGRATION_PLAN.md
|-- README.md
|-- analysis_options.yaml
|-- melos.yaml
|-- docs/
|   |-- references/
|   |   |-- combat-reference.html
|   |   `-- WHITE_DIE.md
|   `-- migration/
|       `-- parity-checklist.md
|-- legacy/
|   `-- web-prototype/
|       |-- README.md
|       |-- app.js
|       |-- index.html
|       |-- styles.css
|       |-- src/
|       |   |-- gameApp.js
|       |   `-- gameData.js
|       `-- assets-from-prototype/
|-- apps/
|   `-- silver_wolf_flutter/
|       |-- pubspec.yaml
|       |-- analysis_options.yaml
|       |-- assets/
|       |   |-- board/
|       |   |-- fonts/
|       |   |-- icons/
|       |   |-- images/
|       |   `-- sigils/
|       |-- lib/
|       |   |-- main.dart
|       |   |-- app/
|       |   |   |-- app.dart
|       |   |   |-- bootstrap.dart
|       |   |   `-- providers.dart
|       |   |-- core/
|       |   |   |-- extensions/
|       |   |   |-- services/
|       |   |   |   |-- app_randomizer.dart
|       |   |   |   `-- asset_catalog.dart
|       |   |   |-- theme/
|       |   |   |   |-- app_colors.dart
|       |   |   |   |-- app_theme.dart
|       |   |   |   `-- app_typography.dart
|       |   |   `-- widgets/
|       |   |       |-- app_panel.dart
|       |   |       |-- resource_pips.dart
|       |   |       `-- section_header.dart
|       |   `-- features/
|       |       |-- game_session/
|       |       |   |-- application/
|       |       |   |   |-- game_session_controller.dart
|       |       |   |   `-- game_session_view_state.dart
|       |       |   `-- presentation/
|       |       |       `-- game_shell_page.dart
|       |       |-- board/
|       |       |   `-- presentation/
|       |       |       |-- board_panel.dart
|       |       |       |-- board_node_widget.dart
|       |       |       |-- occupant_marker.dart
|       |       |       `-- silver_wolf_button.dart
|       |       |-- roster/
|       |       |   `-- presentation/
|       |       |       |-- player_card.dart
|       |       |       `-- roster_sidebar.dart
|       |       |-- profile/
|       |       |   `-- presentation/
|       |       |       `-- fighter_profile_panel.dart
|       |       |-- event_log/
|       |       |   `-- presentation/
|       |       |       `-- event_log_panel.dart
|       |       |-- challenge/
|       |       |   `-- presentation/
|       |       |       `-- challenge_dialog.dart
|       |       |-- combat/
|       |       |   `-- presentation/
|       |       |       |-- combat_dialog.dart
|       |       |       |-- combat_card_widget.dart
|       |       |       |-- combat_phase_strip.dart
|       |       |       `-- combatant_summary_card.dart
|       |       `-- hometown/
|       |           `-- presentation/
|       |               `-- hometown_selection_dialog.dart
|       |-- test/
|       |   |-- widget/
|       |   |-- golden/
|       |   `-- helpers/
|       `-- integration_test/
|           `-- local_parity_smoke_test.dart
|-- packages/
|   `-- silver_wolf_engine/
|       |-- pubspec.yaml
|       |-- lib/
|       |   |-- silver_wolf_engine.dart
|       |   `-- src/
|       |       |-- constants/
|       |       |   `-- game_constants.dart
|       |       |-- enums/
|       |       |   |-- combat_lane.dart
|       |       |   |-- combat_mode.dart
|       |       |   |-- combat_phase.dart
|       |       |   |-- location_type.dart
|       |       |   `-- school_status.dart
|       |       |-- data/
|       |       |   |-- combat_deck_library.dart
|       |       |   |-- fighter_style_copy.dart
|       |       |   |-- starting_players.dart
|       |       |   |-- town_descriptions.dart
|       |       |   `-- track_details.dart
|       |       |-- models/
|       |       |   |-- challenge_state.dart
|       |       |   |-- combat_card.dart
|       |       |   |-- combat_resolution_summary.dart
|       |       |   |-- combat_state.dart
|       |       |   |-- combatant_state.dart
|       |       |   |-- game_log_entry.dart
|       |       |   |-- game_state.dart
|       |       |   |-- location.dart
|       |       |   |-- player.dart
|       |       |   |-- school.dart
|       |       |   `-- undo_snapshot.dart
|       |       |-- commands/
|       |       |   |-- game_command.dart
|       |       |   `-- game_command_factory.dart
|       |       |-- results/
|       |       |   |-- command_result.dart
|       |       |   `-- state_transition.dart
|       |       |-- random/
|       |       |   |-- randomizer.dart
|       |       |   `-- seeded_randomizer.dart
|       |       |-- reducers/
|       |       |   |-- combat_reducer.dart
|       |       |   |-- game_reducer.dart
|       |       |   `-- turn_reducer.dart
|       |       |-- rules/
|       |       |   |-- combat_rules.dart
|       |       |   |-- player_rules.dart
|       |       |   |-- school_rules.dart
|       |       |   |-- silver_wolf_rules.dart
|       |       |   `-- turn_rules.dart
|       |       |-- serialization/
|       |       |   `-- game_state_codec.dart
|       |       `-- factories/
|       |           |-- initial_state_factory.dart
|       |           `-- combat_state_factory.dart
|       `-- test/
|           |-- data/
|           |-- reducers/
|           |-- rules/
|           `-- factories/
`-- tool/
    `-- scripts/
        `-- verify_workspace.sh
```

## Directory Responsibilities

### Root workspace files

- `melos.yaml`
  - Declares the workspace packages.
  - Provides shared bootstrap and test commands.

- `analysis_options.yaml`
  - Defines shared linting rules for every package in the workspace.

- `docs/references/`
  - Stores the original design and rules references that are not runtime code.

- `legacy/web-prototype/`
  - Stores the original prototype intact after it is moved out of the root.
  - Must remain runnable for parity comparison until the Flutter port is accepted.

### Flutter app package

The Flutter package is responsible for:

- rendering the game
- user interaction
- animation
- responsive layout
- presenting modals and overlays
- selecting which panels are open
- mapping engine state into visual state

The Flutter package is **not** responsible for rule mutation.

#### `lib/app/`

- `app.dart`
  - Creates the `MaterialApp`.
  - Applies theme and top-level app configuration.

- `bootstrap.dart`
  - Wires together providers and startup initialization.
  - Good place for debug-only seed injection and app boot diagnostics.

- `providers.dart`
  - Declares global providers that are app-wide, not feature-local.

#### `lib/core/`

- `services/app_randomizer.dart`
  - Provides the app-side implementation of the engine `Randomizer` interface.

- `services/asset_catalog.dart`
  - Defines a single source of truth for asset paths.
  - No asset path string literals should appear inside feature widgets.

- `theme/`
  - Converts the current CSS visual language into Flutter theme primitives.

- `widgets/`
  - Holds reusable UI primitives shared across features.
  - This folder must not accumulate game-specific business logic.

#### `lib/features/game_session/`

This is the orchestration layer for the entire playable screen.

- `application/game_session_controller.dart`
  - Receives UI intents.
  - Dispatches engine commands.
  - Maintains app-level ephemeral UI state.
  - Exposes combined view state to the screen.

- `application/game_session_view_state.dart`
  - Combines engine `GameState` with UI-only fields such as:
    - selected profile player
    - open dialog
    - animation flags

- `presentation/game_shell_page.dart`
  - Main page layout.
  - Composes board, roster, profile, log, and overlays.

#### `lib/features/board/`

- `board_panel.dart`
  - Renders the board area and board chrome.

- `board_node_widget.dart`
  - Renders a town or road node.

- `occupant_marker.dart`
  - Renders a player marker on a node.

- `silver_wolf_button.dart`
  - Renders the center action to challenge the Silver Wolf.

#### `lib/features/roster/`

- `roster_sidebar.dart`
  - Renders the roster list in current-player order.

- `player_card.dart`
  - Renders one player summary card and action buttons.

#### `lib/features/profile/`

- `fighter_profile_panel.dart`
  - Rebuilds the current large fighter profile panel in Flutter.

#### `lib/features/event_log/`

- `event_log_panel.dart`
  - Displays the current battle/event log in reverse chronological order.

#### `lib/features/challenge/`

- `challenge_dialog.dart`
  - Handles challenge target selection and accept/decline flow.

#### `lib/features/combat/`

- `combat_dialog.dart`
  - Owns the combat overlay/page layout.

- `combat_card_widget.dart`
  - Renders one combat card.

- `combat_phase_strip.dart`
  - Renders the combat phase progress header.

- `combatant_summary_card.dart`
  - Renders the left/right combatant summaries.

#### `lib/features/hometown/`

- `hometown_selection_dialog.dart`
  - Exists only if the migration chooses to preserve hometown selection as a visible flow.
  - If the hometown selection flow is dropped from parity scope, this folder should not be created.

### Engine package

The engine package is responsible for:

- immutable game data
- commands
- state transitions
- game rules
- combat rules
- turn rules
- serialization
- deterministic tests

#### `lib/src/data/`

This folder contains the translated data from the current prototype:

- town descriptions
- track layout
- combat deck definitions
- player starting assignments
- style keyword copy

This folder is data-only. No reducers belong here.

#### `lib/src/models/`

This folder contains immutable domain models. These are the canonical shapes used by the engine and consumed by the Flutter app.

Every field that currently affects gameplay should be modeled here, including:

- player stats
- injury state
- reputation
- techniques counts
- hit points
- form points
- arrival order
- alive/dead state
- school siege state
- save progress
- combat draw pile / hand / discard
- selected combat card and mode
- undo snapshot

#### `lib/src/commands/`

This folder defines the public command API that the app is allowed to issue to the engine.

The Flutter app should never call internal reducers directly. It should send a command.

#### `lib/src/results/`

This folder defines the result of reducing a command.

At minimum, a command result should expose:

- the next `GameState`
- log entries produced by the transition
- any engine-level effect metadata needed by the app

#### `lib/src/reducers/`

This is the main engine behavior layer.

- `game_reducer.dart`
  - Top-level dispatcher from command to specific reducer path.

- `turn_reducer.dart`
  - Handles non-combat turn flow.

- `combat_reducer.dart`
  - Handles combat command progression and combat resolution.

#### `lib/src/rules/`

This folder holds pure helper logic used by reducers.

Examples:

- clamp stat logic
- next living player logic
- Silver Wolf strength logic
- challenge eligibility logic
- school save rules
- combat lane resolution

These helpers must be stateless.

#### `lib/src/factories/`

- `initial_state_factory.dart`
  - Builds the initial game state from static data.

- `combat_state_factory.dart`
  - Builds a combat encounter state when a challenge is accepted.

#### `lib/src/random/`

The `Randomizer` abstraction lives here. This is required to test:

- die rolls
- card shuffles
- stumble swaps
- Silver Wolf targeting

#### `lib/src/serialization/`

Even if multiplayer is deferred, state serialization should exist early. This will help with:

- debugging
- snapshot tests
- possible future save/load
- later server/client transport

## Current Prototype to Target Mapping

This section maps the current files and responsibilities into the new structure.

### `src/gameData.js`

Move its responsibilities into:

- `packages/silver_wolf_engine/lib/src/data/track_details.dart`
- `packages/silver_wolf_engine/lib/src/data/town_descriptions.dart`
- `packages/silver_wolf_engine/lib/src/data/starting_players.dart`

Do **not** keep asset URL helpers in the engine. Asset lookup belongs in the Flutter app.

### `src/gameApp.js`

This file currently does too much. It should be split as follows:

- constants, helpers, and shared rule functions:
  - engine `constants/`, `rules/`, and `factories/`

- combat data and combat helpers:
  - engine `data/combat_deck_library.dart`
  - engine `rules/combat_rules.dart`
  - engine `reducers/combat_reducer.dart`

- root React component state:
  - app `features/game_session/application/game_session_controller.dart`

- board rendering:
  - app `features/board/presentation/`

- roster rendering:
  - app `features/roster/presentation/`

- fighter profile panel:
  - app `features/profile/presentation/`

- combat modal:
  - app `features/combat/presentation/`

- challenge modal:
  - app `features/challenge/presentation/`

- DOM-specific animation code:
  - rebuilt from scratch in Flutter using Flutter animation primitives
  - not ported line-for-line

### `styles.css`

Translate this into:

- `app_colors.dart`
- `app_typography.dart`
- `app_theme.dart`
- feature-local widget composition

Do not attempt to create a 1:1 CSS translation layer.

### `combat-reference.html`

Keep as a reference document only.

It should move to:

- `docs/references/combat-reference.html`

It should not remain part of the runtime app.

## Recommended Dependencies

These are the recommended package-level dependencies for the initial implementation.

### Flutter app package

- `flutter`
- `flutter_riverpod`
- `flutter_svg`
- `google_fonts` only if the selected typefaces cannot be bundled as local assets

### Engine package

- `freezed_annotation`
- `json_annotation`
- `collection`

### Dev dependencies

- `build_runner`
- `freezed`
- `json_serializable`
- `flutter_test`
- `test`
- `very_good_analysis` or an equivalent lint set if the team wants a strong starting baseline

If dependency simplicity is preferred, `freezed` can be skipped, but the team must still maintain immutable models. The architecture requirement is immutability, not any specific codegen package.

## Implementation Conventions

These conventions should be followed from the first implementation commit onward.

1. Every engine state model is immutable.
2. Every command produces a new state instead of mutating the current one.
3. Every random branch is testable with a seeded randomizer.
4. Every gameplay rule has direct engine tests.
5. Widget tests cover at least:
   - board render
   - roster render
   - action enable/disable state
   - challenge dialog
   - combat dialog
6. Golden tests cover the major screen configurations after the main layout exists.
7. Integration tests cover one full local flow from app start to at least one resolved combat.
8. Asset references go through `asset_catalog.dart`.
9. No feature widget imports static data directly from the engine data layer unless the controller has already exposed it as view state.

## Phased Rollout Plan

The phases below are the required order of execution. Do not skip ahead unless the exit criteria for the current phase are complete.

---

## Phase 0: Repository Prep and Asset Audit

### Goal

Prepare the repository so the Flutter workspace can be added without colliding with the existing root-level prototype files.

### Work to do

1. Create `docs/references/` and move:
   - `combat-reference.html`
   - `WHITE_DIE.md`

2. Create `legacy/web-prototype/` and move the existing prototype files there:
   - `app.js`
   - `index.html`
   - `styles.css`
   - `src/`
   - any prototype-only image files

3. Split the current root README responsibilities:
   - create `legacy/web-prototype/README.md` with prototype-specific notes
   - rewrite the root `README.md` later to describe the new workspace layout

4. Audit every asset reference currently used by the prototype and record:
   - file name
   - current source path
   - whether the file exists
   - whether a replacement is needed

5. Create `docs/migration/parity-checklist.md` with a manual parity list of behaviors to verify during the port.

### Do not do in this phase

- Do not create Flutter packages yet.
- Do not rewrite any game logic.
- Do not introduce new gameplay rules.

### Exit criteria

- The legacy web prototype still runs from its new location.
- The root is ready for workspace files.
- Every currently referenced asset is either found or explicitly marked missing.
- The parity checklist exists.

---

## Phase 1: Workspace Bootstrap

### Goal

Create the monorepo structure and bootable Flutter/Dart packages.

### Work to do

1. Add root workspace files:
   - `melos.yaml`
   - `analysis_options.yaml`

2. Create `apps/silver_wolf_flutter/` as the Flutter app package.

3. Create `packages/silver_wolf_engine/` as the pure Dart engine package.

4. Add a simple bootstrap script in `tool/scripts/verify_workspace.sh` that runs:
   - package bootstrap
   - formatting
   - static analysis
   - tests

5. Make the Flutter app launch a placeholder shell page that confirms the workspace is wired correctly.

### Do not do in this phase

- Do not port game rules yet.
- Do not start building the full board UI.
- Do not add temporary duplicate logic in the app package.

### Exit criteria

- `melos bootstrap` succeeds.
- `flutter run` launches the app package.
- `dart test` in the engine package succeeds, even if it only runs a placeholder smoke test.
- Static analysis succeeds at the workspace level.

---

## Phase 2: Static Data and Domain Models

### Goal

Translate the prototype's static data and state shapes into immutable Dart models.

### Work to do

1. Port static board and fighter data into:
   - `track_details.dart`
   - `town_descriptions.dart`
   - `starting_players.dart`
   - `fighter_style_copy.dart`
   - `combat_deck_library.dart`

2. Define all engine enums:
   - combat lane
   - combat mode
   - combat phase
   - location type
   - school status

3. Define immutable models for:
   - `Location`
   - `Player`
   - `School`
   - `CombatCard`
   - `CombatantState`
   - `CombatState`
   - `ChallengeState`
   - `UndoSnapshot`
   - `GameState`

4. Build `InitialStateFactory`.

5. Add unit tests that verify the initial state matches the prototype:
   - player count
   - starting positions
   - starting stats
   - starting school states
   - combat deck library contents

### Do not do in this phase

- Do not implement reducers.
- Do not hide missing fields because they are "not used yet." If they affect state now or later, model them now.

### Exit criteria

- The engine can construct a complete initial game state.
- All models are immutable.
- Static-data parity tests pass.

---

## Phase 3: Core Turn Engine

### Goal

Port all non-combat gameplay state transitions into the engine.

### Work to do

1. Implement rule helpers for:
   - stat clamping
   - total-stat calculation
   - living-player selection
   - action count calculation
   - reputation changes
   - injury changes
   - board index normalization

2. Implement command handling for:
   - travel clockwise
   - travel counter-clockwise
   - pass turn
   - heal current player
   - save current school
   - challenge Silver Wolf
   - undo last action

3. Implement Silver Wolf progression rules:
   - siege targeting
   - destruction roll behavior
   - school-loss side effects
   - reputation loss from destroyed schools
   - injury caused by being present at a newly destroyed school

4. Implement undo snapshots for the actions that currently support undo in the prototype.

5. Preserve `pendingRoll` in engine state if it still gates actions, even if the UI presentation remains minimal during parity.

6. Add engine tests for:
   - travel and wraparound behavior
   - heal gating
   - save-school progression
   - turn end behavior
   - next living player selection
   - Silver Wolf school destruction effects
   - Silver Wolf challenge win/lose
   - undo restoration

### Do not do in this phase

- Do not implement combat yet.
- Do not place visual timers or animation concepts into engine state unless they are required for gameplay correctness.

### Exit criteria

- All non-combat commands are engine-driven.
- Turn loop behavior is covered by deterministic tests.
- No app code is required to mutate core turn state directly.

---

## Phase 4: Combat Engine

### Goal

Port the full currently implemented combat system into the engine.

### Work to do

1. Implement combat state factory logic:
   - attacker/defender lookup
   - deck creation
   - deck shuffle
   - opening hand draw

2. Implement combat commands:
   - select combat card
   - select combat mode
   - trigger stumble
   - advance combat phase
   - close combat if needed as an app-level action

3. Implement combat rules:
   - keyword activation
   - special card behavior
   - swap attack / swap defense behavior
   - form point costs
   - lane comparison
   - reversal damage
   - overwhelm defense ignore
   - stumble swap logic
   - end-of-clash discard and redraw logic

4. Implement combat resolution effects on the main game state:
   - loser injured
   - loser loses reputation
   - winner gains reputation
   - winner gains temporary bonus action next turn

5. Explicitly preserve the current prototype's "technique activation not implemented" state.
   - Do not invent missing rules here.
   - The activation phase may remain a no-op placeholder if that matches current playable behavior.

6. Add deterministic tests for:
   - deck creation by hometown
   - available combat modes
   - mode-cost calculation
   - lane resolution
   - stumble behavior
   - clash advancement
   - knockout / simultaneous defeat outcomes
   - discard-and-redraw behavior

### Do not do in this phase

- Do not redesign combat.
- Do not add new card mechanics.
- Do not expand the techniques system beyond parity.

### Exit criteria

- The engine can run a full combat encounter without Flutter code performing rule calculations.
- Combat tests cover the major phase transitions and edge cases.

---

## Phase 5: App Shell and State Wiring

### Goal

Create the Flutter application shell and connect it to the engine cleanly.

### Work to do

1. Build the `MaterialApp` shell and theme.

2. Create `GameSessionController` that:
   - owns the current engine `GameState`
   - exposes a combined view state
   - dispatches engine commands
   - tracks UI-only state such as:
     - selected profile player
     - open dialog kind
     - transient animation flags

3. Build a placeholder `GameShellPage` with empty layout regions:
   - board area
   - roster area
   - profile area
   - event log area

4. Connect action buttons in the placeholder shell to real engine commands before the final visuals are built.

### Do not do in this phase

- Do not pursue visual polish yet.
- Do not duplicate logic in controller methods that belongs in engine reducers.

### Exit criteria

- The app can load the initial engine state.
- The main screen can dispatch commands into the engine.
- The screen updates from engine state changes.

---

## Phase 6: Board, Roster, and Profile UI

### Goal

Rebuild the main non-combat interface in Flutter.

### Work to do

1. Rebuild the circular board using Flutter layout primitives:
   - `LayoutBuilder`
   - `Stack`
   - polar position math
   - optional `CustomPaint` for the board ring and glow

2. Recreate node rendering:
   - towns
   - roads
   - school status overlays
   - occupant markers

3. Rebuild the center Silver Wolf action button.

4. Rebuild the roster sidebar:
   - current-player ordering
   - player summary
   - actions
   - reputation display
   - injury display

5. Rebuild the fighter profile panel.

6. Rebuild the event log panel.

7. Implement Flutter-native animations for:
   - roster reordering
   - action-indicator consumption
   - highlighted active-player transitions

Do not try to recreate DOM ghost-node animation literally. Match the intent in a Flutter-native way.

### Do not do in this phase

- Do not build the combat dialog yet.
- Do not block phase completion on perfect art parity if assets are still being cleaned up.

### Exit criteria

- A user can play all non-combat actions from the Flutter UI.
- The board and roster respond correctly to engine state.
- The layout is usable on at least one phone width and one desktop width.

---

## Phase 7: Challenge and Combat UI

### Goal

Build the playable combat flow in Flutter on top of the engine that already exists.

### Work to do

1. Rebuild the challenge dialog:
   - target selection
   - accept flow
   - decline flow

2. Rebuild the combat dialog/page:
   - phase strip
   - combatant summaries
   - hand display
   - combat card selection
   - mode selection
   - reveal step
   - reaction step
   - calculation summary
   - activation placeholder
   - clash log

3. Recreate combat card visuals in Flutter.

4. Wire every combat interaction through controller -> engine commands.

5. Add widget tests for:
   - challenge dialog behavior
   - combat selection state
   - combat phase progression
   - disabled mode selection when form points are insufficient

### Do not do in this phase

- Do not expand the combat system with new rules.
- Do not embed combat rule calculations in widgets.

### Exit criteria

- A full combat encounter can be played end-to-end in Flutter.
- Combat UI reflects engine state without local rule duplication.

---

## Phase 8: Visual Polish, Asset Closure, and Parity Validation

### Goal

Close the gap between "technically working" and "acceptable Flutter replacement."

### Work to do

1. Replace missing temporary assets with final bundled assets where possible.

2. Finalize typography, colors, spacing, and panel styling.

3. Add responsive adjustments for:
   - narrow phone portrait
   - tablet portrait
   - desktop landscape

4. Use the parity checklist to validate:
   - startup state
   - turn loop
   - board transitions
   - challenge flow
   - combat flow
   - Silver Wolf destruction behavior
   - undo behavior

5. Add golden tests for the major screen states:
   - initial screen
   - active challenge dialog
   - combat selection phase
   - combat reveal phase
   - endgame / winner state if implemented visually

### Do not do in this phase

- Do not begin multiplayer work.
- Do not begin backend integration.

### Exit criteria

- The Flutter app is the new primary local prototype.
- Major parity checks pass.
- The legacy prototype remains only as archive/reference material.

---

## Phase 9: Post-Parity Preparation for Multiplayer

### Goal

This phase is not required for the initial Flutter migration, but it should be the next architectural step after parity.

### Work to do later

1. Introduce stable command and event serialization.
2. Define authoritative engine execution boundaries.
3. Split client UI state from network-safe engine state more aggressively if needed.
4. Add replay-friendly event logs.
5. Design lobby and account flows outside the local parity branch.

### Do not do now

- Do not start this phase until parity is accepted.

## Recommended Order of File Creation

To keep implementation orderly, create files in this order:

1. Root workspace files.
2. Engine package skeleton.
3. Engine enums.
4. Engine models.
5. Engine static data.
6. Engine factories.
7. Engine rule helpers.
8. Engine reducers.
9. Engine tests.
10. App package shell.
11. App controller and view state.
12. Non-combat UI features.
13. Combat UI features.
14. Integration and golden tests.

## Acceptance Standard for the Overall Migration

The Flutter migration is complete when all of the following are true:

1. The app boots from the Flutter package with no dependency on the legacy web prototype.
2. All current prototype gameplay rules are handled in the Dart engine.
3. The Flutter app can drive those rules through commands only.
4. The main local game loop is playable without using the legacy prototype.
5. Engine tests cover the core rule system.
6. Widget and integration tests cover the major user flows.
7. The repo has a clear boundary between:
   - archived prototype code
   - engine code
   - app code

## Final Notes

If implementation pressure forces tradeoffs, use this priority order:

1. Correct rules in pure Dart.
2. Reliable app-to-engine wiring.
3. Playable local parity.
4. Visual parity.
5. Future multiplayer preparation.

If there is a conflict between matching an exact DOM animation and keeping the architecture clean, choose the clean architecture and reproduce the animation intent in a Flutter-native way.
