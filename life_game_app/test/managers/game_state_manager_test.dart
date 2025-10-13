import 'package:flutter_test/flutter_test.dart';
import 'package:life_game_app/managers/game_state_manager.dart';
import 'package:life_game_app/enums/game_state.dart';

void main() {
  group('GameStateManager', () {
    late GameStateManager manager;

    setUp(() {
      manager = GameStateManager();
    });

    group('Initial State', () {
      test('should start with loading state', () {
        expect(manager.currentState, equals(GameState.loading));
      });

      test('should not be playing initially', () {
        expect(manager.isPlaying, isFalse);
      });

      test('should not be paused initially', () {
        expect(manager.isPaused, isFalse);
      });
    });

    group('State Transitions', () {
      test('should transition to any state', () {
        manager.setState(GameState.title);
        expect(manager.currentState, equals(GameState.title));

        manager.setState(GameState.playing);
        expect(manager.currentState, equals(GameState.playing));
        expect(manager.isPlaying, isTrue);

        manager.setState(GameState.paused);
        expect(manager.currentState, equals(GameState.paused));
        expect(manager.isPaused, isTrue);

        manager.setState(GameState.loading);
        expect(manager.currentState, equals(GameState.loading));
      });
    });

    group('Pause and Resume Methods', () {
      test('pause() should set state to paused', () {
        manager.pause();
        expect(manager.currentState, equals(GameState.paused));
        expect(manager.isPaused, isTrue);
        expect(manager.isPlaying, isFalse);
      });

      test('resume() should set state to playing', () {
        manager.resume();
        expect(manager.currentState, equals(GameState.playing));
        expect(manager.isPlaying, isTrue);
        expect(manager.isPaused, isFalse);
      });

      test('should be able to pause and resume multiple times', () {
        // First pause/resume cycle
        manager.pause();
        expect(manager.isPaused, isTrue);
        manager.resume();
        expect(manager.isPlaying, isTrue);

        // Second pause/resume cycle
        manager.pause();
        expect(manager.isPaused, isTrue);
        manager.resume();
        expect(manager.isPlaying, isTrue);
      });
    });

    group('State Getters', () {
      test('isPlaying should return true only when in playing state', () {
        expect(manager.isPlaying, isFalse);

        manager.setState(GameState.playing);
        expect(manager.isPlaying, isTrue);

        manager.setState(GameState.paused);
        expect(manager.isPlaying, isFalse);

        manager.setState(GameState.title);
        expect(manager.isPlaying, isFalse);
      });

      test('isPaused should return true only when in paused state', () {
        expect(manager.isPaused, isFalse);

        manager.setState(GameState.playing);
        expect(manager.isPaused, isFalse);

        manager.setState(GameState.paused);
        expect(manager.isPaused, isTrue);

        manager.setState(GameState.title);
        expect(manager.isPaused, isFalse);
      });

      test('currentState should always reflect the actual state', () {
        expect(manager.currentState, equals(GameState.loading));

        manager.setState(GameState.title);
        expect(manager.currentState, equals(GameState.title));

        manager.setState(GameState.playing);
        expect(manager.currentState, equals(GameState.playing));

        manager.setState(GameState.paused);
        expect(manager.currentState, equals(GameState.paused));
      });
    });
  });
}
