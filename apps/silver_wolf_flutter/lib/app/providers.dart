import 'package:flutter_riverpod/flutter_riverpod.dart';

final workspaceStatusProvider = Provider<String>((Ref ref) {
  return 'Workspace bootstrap complete';
});
