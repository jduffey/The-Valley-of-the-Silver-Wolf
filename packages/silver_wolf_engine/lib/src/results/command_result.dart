import 'package:silver_wolf_engine/src/models/game_state.dart';
import 'package:silver_wolf_engine/src/results/state_transition.dart';

class CommandResult {
  const CommandResult({
    required this.state,
    this.transition = const StateTransition(),
  });

  final GameState state;
  final StateTransition transition;

  factory CommandResult.unchanged(GameState state) {
    return CommandResult(state: state);
  }
}
