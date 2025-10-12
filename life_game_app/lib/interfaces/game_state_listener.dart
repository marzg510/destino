import '../enums/game_state.dart';

abstract class GameStateListener {
  void onGameStateChanged(GameState newState);
}
