import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:silver_wolf_flutter/app/app.dart';
import 'package:silver_wolf_flutter/app/providers.dart';
import 'package:silver_wolf_flutter/core/services/app_randomizer.dart';
import 'package:silver_wolf_flutter/features/game_session/presentation/game_shell_page.dart';
import '../support/game_session_test_support.dart';

void main() {
  setUp(() {});

  testWidgets('challenge dialog supports target selection and decline flow', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1600, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final GameState challengeState = createChallengeDialogGameState();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRandomizerProvider.overrideWithValue(FixedRandomizer(<int>[5, 0])),
          gameSessionControllerProvider.overrideWith(
            () => PreparedGameSessionController(buildViewState(challengeState)),
          ),
        ],
        child: const SilverWolfApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Combat Challenge'), findsOneWidget);

    final FilledButton acceptButtonBefore = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Accept Challenge'),
    );
    expect(acceptButtonBefore.onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey<String>('challenge-target-p3')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Decline'));
    await tester.pumpAndSettle();

    expect(find.text('Combat Challenge'), findsNothing);
    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(GameShellPage)),
    );
    expect(
      container
          .read(gameSessionControllerProvider)
          .gameState
          .eventLog
          .first
          .message,
      contains("declines Player 1's challenge"),
    );
  });

  testWidgets('combat dialog tracks selection state and advances phases', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1600, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final CombatFixture fixture = createLethalCombatFixture();
    final GameState gameState = fixture.gameState;
    final CombatCard attackerCard = fixture.choice.attackerCard;
    final CombatCard defenderCard = fixture.choice.defenderCard;
    final CombatMode attackerMode = fixture.choice.attackerMode;
    final CombatMode defenderMode = fixture.choice.defenderMode;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameSessionControllerProvider.overrideWith(
            () => PreparedGameSessionController(buildViewState(gameState)),
          ),
        ],
        child: const SilverWolfApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Combat Encounter'), findsOneWidget);
    final FilledButton nextPhaseBefore = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Next Phase'),
    );
    expect(nextPhaseBefore.onPressed, isNull);

    await tester.tap(
      find.byKey(ValueKey<String>('combat-card-p1-${attackerCard.id}')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(ValueKey<String>('combat-mode-p1-${attackerMode.name}')),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey<String>('combat-mode-p1-${attackerMode.name}')),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(ValueKey<String>('combat-card-p2-${defenderCard.id}')),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey<String>('combat-card-p2-${defenderCard.id}')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(ValueKey<String>('combat-mode-p2-${defenderMode.name}')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey<String>('combat-mode-p2-${defenderMode.name}')),
    );
    await tester.pumpAndSettle();

    final FilledButton nextPhaseAfter = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Next Phase'),
    );
    expect(nextPhaseAfter.onPressed, isNotNull);

    await tester.tap(find.text('Next Phase'));
    await tester.pumpAndSettle();

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(GameShellPage)),
    );
    expect(
      container
          .read(gameSessionControllerProvider)
          .gameState
          .combatState!
          .phase,
      CombatPhase.reveal,
    );
  });

  testWidgets('combat mode chips disable when form points are insufficient', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1600, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final CombatState baseCombatState =
        createLethalCombatFixture().gameState.combatState!;
    final CombatantState attacker = baseCombatState.combatants['p1']!;
    final CombatCard selectedCard = attacker.hand.first;
    final CombatState combatState = baseCombatState.copyWith(
      combatants: <String, CombatantState>{
        ...baseCombatState.combatants,
        'p1': attacker.copyWith(
          currentFormPoints: 0,
          selectedCardId: selectedCard.id,
          effectiveCardId: selectedCard.id,
        ),
      },
    );
    final GameState gameState = InitialStateFactory.create().copyWith(
      combatState: combatState,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameSessionControllerProvider.overrideWith(
            () => PreparedGameSessionController(buildViewState(gameState)),
          ),
        ],
        child: const SilverWolfApp(),
      ),
    );
    await tester.pumpAndSettle();

    final ChoiceChip modeChip = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey<String>('combat-mode-p1-keyword')),
    );
    expect(modeChip.onSelected, isNull);
  });
}
