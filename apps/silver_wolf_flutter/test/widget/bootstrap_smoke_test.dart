import 'package:flutter_test/flutter_test.dart';
import 'package:silver_wolf_flutter/app/app.dart';

void main() {
  testWidgets('renders the workspace bootstrap shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SilverWolfApp());

    expect(find.text('Workspace bootstrap complete'), findsOneWidget);
    expect(find.text('Silver Wolf engine ready'), findsOneWidget);
  });
}
