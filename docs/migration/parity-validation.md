# Flutter Parity Validation

This document records the validation standard used for the Flutter migration once the local-play parity surface is implemented.

## Automated Coverage

- Engine rules are validated through the `silver_wolf_engine` package test suite, including turn flow, Silver Wolf pressure, challenge flow, and combat reducer behavior.
- Flutter widget behavior is covered by:
  - `apps/silver_wolf_flutter/test/widget/game_shell_page_test.dart`
  - `apps/silver_wolf_flutter/test/widget/challenge_and_combat_dialog_test.dart`
- Visual parity snapshots are covered by:
  - `apps/silver_wolf_flutter/test/golden/game_shell_golden_test.dart`
- A deterministic end-to-end local combat path is covered by:
  - `apps/silver_wolf_flutter/integration_test/local_parity_smoke_test.dart`

## Evidence by Area

- Startup, board state, and roster rendering: exercised by the desktop shell widget test and the initial shell golden.
- Turn flow and action availability: exercised by the roster interaction widget test and engine reducer tests.
- Challenge targeting and decline behavior: exercised by the challenge dialog widget test and the challenge dialog golden.
- Combat selection, mode availability, phase progression, and resolution UI: exercised by the combat widget tests, the combat goldens, and the integration smoke test.
- Responsiveness and overlay safety: exercised by widget layouts plus goldens captured with the overlay states present.

## Commands

Run the full workspace verification with:

```bash
./tool/scripts/verify_workspace.sh
```

That command bootstraps the workspace, formats code, runs static analysis, runs the standard test suites, and runs the Flutter integration tests when present.

## Known Intentional Gap

- Combat activation remains a placeholder stage because the original prototype does not yet define the full technique activation rules. The engine and Flutter UI both preserve that placeholder instead of inventing behavior.
