import 'package:life_game_app/enums/game_state.dart';
import 'package:life_game_app/interfaces/game_state_listener.dart';

class GameStateManager {
  GameState _currentState = GameState.loading;
  final List<GameStateListener> _listeners = [];

  static const Map<GameState, Set<GameState>> _allowedTransitions = {
    GameState.loading: {GameState.title},
    GameState.title: {GameState.playing, GameState.loading},
    GameState.playing: {GameState.playing, GameState.paused},
    GameState.paused: {GameState.playing, GameState.title},
  };

  void addListener(GameStateListener listener) {
    _listeners.add(listener);
  }

  void removeListener(GameStateListener listener) {
    _listeners.remove(listener);
  }

  bool _canTransitionTo(GameState newState) {
    return _allowedTransitions[_currentState]?.contains(newState) ?? false;
  }

  void setState(GameState newState) {
    if (!_canTransitionTo(newState)) {
      throw Exception(
        'Invalid state transition from $_currentState to $newState',
      );
    }
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
