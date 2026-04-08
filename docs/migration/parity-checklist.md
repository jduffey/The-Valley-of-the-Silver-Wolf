# Local Parity Checklist

This checklist defines the behaviors that the Flutter app must match before the legacy web prototype can be considered fully superseded for local play.

## Startup

- The app starts with five players.
- Each player starts in the same hometown/track position as the legacy prototype.
- Each player starts with the same stats, hit points, form points, reputation, injury state, and alive state.
- All schools begin as `whole`.
- The current player starts as Player 1.
- The starting action count matches the current player health and bonus-action rules.

## Board State

- Town and road nodes appear in the same order around the board.
- Occupant markers render correctly at a node for one or more players.
- Injured players render differently from healthy players.
- School states render distinctly for:
  - whole
  - sieged
  - destroyed

## Turn Flow

- A player can travel clockwise.
- A player can travel counter-clockwise.
- Travel wraps around the track correctly in both directions.
- Passing the turn advances to the next living player.
- Dead players are skipped automatically.
- Bonus actions granted for the next turn are consumed correctly at turn start.

## Player Actions

- Heal is only available when the current player is injured and located in a town.
- Save school is only available when the current player is in a sieged town that is not already completing its rescue presentation flow.
- Save school progresses from `0` to `3`.
- A completed school rescue restores the school to `whole`.
- Eligible defenders gain reputation when a school is fully saved.
- Undo works for the same actions that are currently undoable in the legacy prototype.

## Silver Wolf Pressure

- The White Die behavior matches the documented rules.
- The Silver Wolf can lay siege to whole schools.
- The Silver Wolf can destroy a sieged school on the correct White Die result.
- Newly destroyed schools reduce player reputation correctly.
- Players present at a newly destroyed school become injured under the same conditions as the legacy prototype.
- The game ends if all schools are destroyed.

## Challenge Flow

- Fight is only available when at least one rival is on the same position.
- If multiple rivals are present, the challenger can choose a target.
- If the target accepts, combat starts.
- If the target declines, the target loses reputation.
- The challenger receives the same action-banking behavior as the legacy prototype.

## Combat Flow

- Each fighter receives the correct hometown deck.
- The opening hand size matches the legacy prototype.
- Available combat modes match the selected card type.
- Form point costs are charged correctly.
- Keyword behavior matches hometown rules.
- Swap attack and swap defense behavior matches the legacy prototype.
- Stumble can swap the revealed card for a different random card from hand.
- Attack and defense lane resolution matches the legacy prototype.
- Reversal damage is applied correctly.
- Overwhelm ignores incoming attack correctly.
- Clash progression follows:
  - selection
  - reveal
  - reaction
  - calculation
  - activation
- Activation remains a placeholder until the actual technique rules are defined.
- Card discard and redraw behavior matches the legacy prototype.
- Combat victory and defeat apply the correct reputation, injury, and bonus-action effects.

## Silver Wolf Challenge

- A player may only challenge the Silver Wolf when the total-stat threshold is met.
- Silver Wolf strength scales with destroyed schools.
- Winning the Silver Wolf challenge ends the game with the current player as winner.
- Losing the Silver Wolf challenge kills the challenger and logs the result.

## Event Log

- Major actions append readable event log entries.
- Combat outcomes append readable event log entries.
- School destruction and rescue append readable event log entries.

## UI and Responsiveness

- The main local-play screen is usable on a phone-sized layout.
- The main local-play screen is usable on a desktop-sized layout.
- Combat is playable on narrow and wide layouts.
- Dialogs and overlays do not hide required controls.

## Validation Standard

The Flutter app reaches local parity when:

- engine tests cover the major game rules
- widget tests cover the major flows and control states
- integration tests cover at least one full local play path through combat
- manual smoke testing confirms the above behaviors against the legacy prototype
