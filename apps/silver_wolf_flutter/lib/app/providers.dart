import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_controller.dart';
import 'package:silver_wolf_flutter/features/game_session/application/game_session_view_state.dart';

final gameSessionControllerProvider =
    NotifierProvider<GameSessionController, GameSessionViewState>(
      GameSessionController.new,
    );
