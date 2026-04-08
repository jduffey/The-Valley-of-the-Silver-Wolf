import 'package:silver_wolf_engine/silver_wolf_engine.dart';
import 'package:test/test.dart';

void main() {
  test('exports the workspace bootstrap message', () {
    expect(workspaceReadyMessage, 'Silver Wolf engine ready');
  });
}
