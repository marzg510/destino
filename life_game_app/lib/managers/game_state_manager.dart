import 'package:life_game_app/enums/game_state.dart';
import 'package:life_game_app/interfaces/game_state_listener.dart';

class GameStateManager {
  GameState _currentState = GameState.loading;
  final List<GameStateListener> _listeners = [];

  void addListener(GameStateListener listener) {
    _listeners.add(listener);
  }

  void removeListener(GameStateListener listener) {
    _listeners.remove(listener);
  }

  void setState(GameState newState) {
    _currentState = newState;

    // リスナーに通知
    for (var listener in _listeners) {
      listener.onGameStateChanged(newState);
    }
  }

  void pause() {
    setState(GameState.paused);
  }

  void resume() {
    setState(GameState.playing);
  }

  bool get isPlaying => _currentState == GameState.playing;
  bool get isPaused => _currentState == GameState.paused;
  GameState get currentState => _currentState;
}
