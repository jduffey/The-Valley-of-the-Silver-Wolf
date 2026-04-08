# Authoritative Engine Boundaries

This document defines the intended multiplayer-safe boundary after the Flutter parity migration.

## Authority Model

- The Dart engine is the only layer allowed to mutate durable gameplay state.
- Flutter UI code may render engine state and dispatch commands, but it must not apply rule outcomes locally by mutating fields.
- A future authoritative host may be a local desktop process, a dedicated game server, or a peer elected as host. The protocol stays the same either way.

## Network-Safe Payloads

The engine now exposes stable codecs for:

- `GameCommand`
- `GameState`
- `StateTransition`

These payloads are the intended transport boundary for later multiplayer work.

## What Can Cross the Boundary

Safe to send across a process or network boundary:

- serialized `GameCommand` payloads from UI clients
- serialized `GameState` snapshots from the authority
- serialized `StateTransition` payloads for incremental UI updates
- typed `GameLogEntry` records for replay and spectator timelines

Not safe to treat as authoritative:

- selected profile panel state
- open dialog state
- animation flags
- scroll positions
- hover and focus state
- any other Flutter-only presentation concerns

## Recommended Execution Loop

1. A client issues a serialized `GameCommand`.
2. The authoritative engine decodes that command.
3. The engine reducer executes against the last accepted `GameState`.
4. The authority publishes:
   - the next serialized `GameState`
   - the serialized `StateTransition`
5. Clients rebuild UI from that durable state and keep their local presentation state separate.

## Replay Direction

- The ordered event log remains part of durable game state.
- Each log entry now carries a stable `type` plus structured `metadata`.
- Replays can use the event log for human-readable history while authoritative playback can still rely on command streams and state snapshots.

## Non-Goals for This Stage

- This does not define networking transport, authentication, lobbies, or persistence infrastructure.
- This does not change the current local-only Flutter prototype into a multiplayer product by itself.
