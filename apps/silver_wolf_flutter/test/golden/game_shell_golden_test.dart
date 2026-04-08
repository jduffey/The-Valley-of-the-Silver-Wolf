import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/app/app.dart';
import 'package:silver_wolf_flutter/app/providers.dart';
import 'package:silver_wolf_flutter/core/services/app_randomizer.dart';
import '../support/game_session_test_support.dart';

void main() {
  Future<void> pumpGoldenApp(
    WidgetTester tester, {
    GameState? gameState,
    Size size = const Size(1600, 1200),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final overrides = [
      appRandomizerProvider.overrideWithValue(FixedRandomizer(<int>[0, 0, 0])),
    ];
    if (gameState != null) {
      overrides.add(
        gameSessionControllerProvider.overrideWith(
          () => PreparedGameSessionController(buildViewState(gameState)),
        ),
      );
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const RepaintBoundary(
          key: ValueKey<String>('golden-root'),
          child: SilverWolfApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('captures the initial game shell', (WidgetTester tester) async {
    await pumpGoldenApp(tester);

    await expectLater(
      find.byKey(const ValueKey<String>('golden-root')),
      matchesGoldenFile('goldens/initial_game_shell.png'),
    );
  });

  testWidgets('captures the challenge dialog state', (
    WidgetTester tester,
  ) async {
    await pumpGoldenApp(
      tester,
      gameState: createChallengeDialogGameState(),
      size: const Size(1440, 1100),
    );

    await expectLater(
      find.byKey(const ValueKey<String>('golden-root')),
      matchesGoldenFile('goldens/challenge_dialog.png'),
    );
  });

  testWidgets('captures the combat selection state', (
    WidgetTester tester,
  ) async {
    await pumpGoldenApp(
      tester,
      gameState: createCombatGameStateAtPhase(CombatPhase.selection),
      size: const Size(1440, 1100),
    );

    await expectLater(
      find.byKey(const ValueKey<String>('golden-root')),
      matchesGoldenFile('goldens/combat_selection.png'),
    );
  });

  testWidgets('captures the combat reveal state', (WidgetTester tester) async {
    await pumpGoldenApp(
      tester,
      gameState: createCombatGameStateAtPhase(CombatPhase.reveal),
      size: const Size(1440, 1100),
    );

    await expectLater(
      find.byKey(const ValueKey<String>('golden-root')),
      matchesGoldenFile('goldens/combat_reveal.png'),
    );
  });
}
