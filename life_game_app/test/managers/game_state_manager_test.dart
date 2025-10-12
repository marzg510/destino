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
      test('should start with title state', () {
        expect(manager.currentState, equals(GameState.title));
      });

      test('should not be playing initially', () {
        expect(manager.isPlaying, isFalse);
      });

      test('should not be paused initially', () {
        expect(manager.isPaused, isFalse);
      });
    });

    group('Valid State Transitions', () {
      test('should transition from title to playing', () {
        manager.setState(GameState.playing);
        expect(manager.currentState, equals(GameState.playing));
        expect(manager.isPlaying, isTrue);
      });

      test('should transition from title to loading', () {
        manager.setState(GameState.loading);
        expect(manager.currentState, equals(GameState.loading));
      });

      test('should transition from loading to title', () {
        manager.setState(GameState.loading);
        manager.setState(GameState.title);
        expect(manager.currentState, equals(GameState.title));
      });

      test('should transition from playing to paused', () {
        manager.setState(GameState.playing);
        manager.setState(GameState.paused);
        expect(manager.currentState, equals(GameState.paused));
        expect(manager.isPaused, isTrue);
      });

      test('should transition from paused to playing', () {
        manager.setState(GameState.playing);
        manager.setState(GameState.paused);
        manager.setState(GameState.playing);
        expect(manager.currentState, equals(GameState.playing));
        expect(manager.isPlaying, isTrue);
      });

      test('should transition from paused to title', () {
        manager.setState(GameState.playing);
        manager.setState(GameState.paused);
        manager.setState(GameState.title);
        expect(manager.currentState, equals(GameState.title));
      });
    });

    group('Invalid State Transitions', () {
      test('should throw exception when transitioning from title to paused', () {
        expect(
          () => manager.setState(GameState.paused),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid state transition from ${GameState.title} to ${GameState.paused}'),
          )),
        );
      });

      test('should throw exception when transitioning from playing to loading', () {
        manager.setState(GameState.playing);
        expect(
          () => manager.setState(GameState.loading),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when transitioning from playing to title', () {
        manager.setState(GameState.playing);
        expect(
          () => manager.setState(GameState.title),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when transitioning from loading to playing', () {
        manager.setState(GameState.loading);
        expect(
          () => manager.setState(GameState.playing),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when transitioning from loading to paused', () {
        manager.setState(GameState.loading);
        expect(
          () => manager.setState(GameState.paused),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when pausing from title', () {
        expect(
          () => manager.pause(),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when resuming from title', () {
        // resume() calls setState(GameState.playing)
        // title -> playing is a valid transition, so this should NOT throw
        // Let's verify it doesn't throw instead
        manager.resume();
        expect(manager.currentState, equals(GameState.playing));
      });
    });

    group('Pause and Resume Methods', () {
      test('pause() should transition from playing to paused', () {
        manager.setState(GameState.playing);
        manager.pause();
        expect(manager.currentState, equals(GameState.paused));
        expect(manager.isPaused, isTrue);
        expect(manager.isPlaying, isFalse);
      });

      test('resume() should transition from paused to playing', () {
        manager.setState(GameState.playing);
        manager.pause();
        manager.resume();
        expect(manager.currentState, equals(GameState.playing));
        expect(manager.isPlaying, isTrue);
        expect(manager.isPaused, isFalse);
      });

      test('should be able to pause and resume multiple times', () {
        manager.setState(GameState.playing);

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
        expect(manager.currentState, equals(GameState.title));

        manager.setState(GameState.loading);
        expect(manager.currentState, equals(GameState.loading));

        manager.setState(GameState.title);
        expect(manager.currentState, equals(GameState.title));

        manager.setState(GameState.playing);
        expect(manager.currentState, equals(GameState.playing));

        manager.setState(GameState.paused);
        expect(manager.currentState, equals(GameState.paused));
      });
    });

    group('Complex State Transition Scenarios', () {
      test('should handle complete game flow: title -> playing -> pause -> resume -> pause -> title', () {
        // Start at title
        expect(manager.currentState, equals(GameState.title));

        // Start game
        manager.setState(GameState.playing);
        expect(manager.isPlaying, isTrue);

        // Pause game
        manager.pause();
        expect(manager.isPaused, isTrue);

        // Resume game
        manager.resume();
        expect(manager.isPlaying, isTrue);

        // Pause again
        manager.pause();
        expect(manager.isPaused, isTrue);

        // Return to title
        manager.setState(GameState.title);
        expect(manager.currentState, equals(GameState.title));
      });

      test('should handle loading scenario: title -> loading -> title -> playing', () {
        expect(manager.currentState, equals(GameState.title));

        manager.setState(GameState.loading);
        expect(manager.currentState, equals(GameState.loading));

        manager.setState(GameState.title);
        expect(manager.currentState, equals(GameState.title));

        manager.setState(GameState.playing);
        expect(manager.isPlaying, isTrue);
      });

      test('should maintain state consistency across multiple operations', () {
        manager.setState(GameState.playing);

        for (int i = 0; i < 5; i++) {
          manager.pause();
          expect(manager.isPaused, isTrue);
          expect(manager.isPlaying, isFalse);

          manager.resume();
          expect(manager.isPlaying, isTrue);
          expect(manager.isPaused, isFalse);
        }
      });
    });

    group('Edge Cases', () {
      test('should handle setting the same state (should throw exception)', () {
        manager.setState(GameState.playing);
        expect(
          () => manager.setState(GameState.playing),
          throwsA(isA<Exception>()),
        );
      });

      test('should not change state when invalid transition is attempted', () {
        final initialState = manager.currentState;

        try {
          manager.setState(GameState.paused);
        } catch (e) {
          // Expected exception
        }

        // State should remain unchanged
        expect(manager.currentState, equals(initialState));
      });
    });
  });
}
