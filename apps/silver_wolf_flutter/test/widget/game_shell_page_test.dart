import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_wolf_flutter/app/app.dart';

void main() {
  testWidgets('renders the main non-combat panels on a desktop layout', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1600, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: SilverWolfApp()));
    await tester.pumpAndSettle();

    expect(find.text('Game Shell'), findsOneWidget);
    expect(find.text('Board'), findsOneWidget);
    expect(find.text('Roster'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Fighter Profile'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Fighter Profile'), findsOneWidget);
    expect(find.text('Event Log'), findsOneWidget);

    final OutlinedButton healButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Heal'),
    );
    final OutlinedButton saveButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Save'),
    );

    expect(healButton.onPressed, isNull);
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('dispatches movement and pass-turn commands from the roster UI', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1600, 1200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: SilverWolfApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Move CW'));
    await tester.pumpAndSettle();

    expect(find.text('Location: Stone Ford'), findsOneWidget);

    await tester.tap(find.text('Pass'));
    await tester.pumpAndSettle();

    expect(find.text('Current: P2'), findsOneWidget);
  });
}
