import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silver_wolf_flutter/app/app.dart';

void main() {
  testWidgets('renders the game shell and dispatches engine actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SilverWolfApp()));

    expect(find.text('Game Shell'), findsOneWidget);
    expect(find.text('Connected Actions'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Travel Clockwise'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Travel Clockwise'));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Board Area'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Board Area'), findsOneWidget);
    expect(find.text('Position index: 1'), findsOneWidget);
  });
}
