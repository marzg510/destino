import 'package:flutter_test/flutter_test.dart';
import 'package:life_game_app/src/my_game.dart';

void main() {
  group('MyGame - GameState管理', () {
    late MyGame game;

    setUp(() {
      game = MyGame();
    });

    group('Initial State', () {
      test('初期状態はloadingであること', () {
        expect(game.currentState, equals(GameState.loading));
      });

      test('初期状態ではisPlayingがfalseであること', () {
        expect(game.isPlaying, isFalse);
      });

      test('初期状態ではisPausedがfalseであること', () {
        expect(game.isPaused, isFalse);
      });
    });

    group('State Transitions', () {
      test('setStateで任意の状態に遷移できること', () {
        game.setState(GameState.title);
        expect(game.currentState, equals(GameState.title));

        game.setState(GameState.playing);
        expect(game.currentState, equals(GameState.playing));
        expect(game.isPlaying, isTrue);

        game.setState(GameState.paused);
        expect(game.currentState, equals(GameState.paused));
        expect(game.isPaused, isTrue);

        game.setState(GameState.loading);
        expect(game.currentState, equals(GameState.loading));
      });
    });

    group('Pause and Resume Methods', () {
      test('pause()でpaused状態になること', () {
        game.pause();
        expect(game.currentState, equals(GameState.paused));
        expect(game.isPaused, isTrue);
        expect(game.isPlaying, isFalse);
      });

      test('resume()でplaying状態になること', () {
        game.resume();
        expect(game.currentState, equals(GameState.playing));
        expect(game.isPlaying, isTrue);
        expect(game.isPaused, isFalse);
      });

      test('pause/resumeを複数回繰り返せること', () {
        // First pause/resume cycle
        game.pause();
        expect(game.isPaused, isTrue);
        game.resume();
        expect(game.isPlaying, isTrue);

        // Second pause/resume cycle
        game.pause();
        expect(game.isPaused, isTrue);
        game.resume();
        expect(game.isPlaying, isTrue);
      });
    });

    group('State Getters', () {
      test('isPlayingはplaying状態の時のみtrueを返すこと', () {
        expect(game.isPlaying, isFalse);

        game.setState(GameState.playing);
        expect(game.isPlaying, isTrue);

        game.setState(GameState.paused);
        expect(game.isPlaying, isFalse);

        game.setState(GameState.title);
        expect(game.isPlaying, isFalse);
      });

      test('isPausedはpaused状態の時のみtrueを返すこと', () {
        expect(game.isPaused, isFalse);

        game.setState(GameState.playing);
        expect(game.isPaused, isFalse);

        game.setState(GameState.paused);
        expect(game.isPaused, isTrue);

        game.setState(GameState.title);
        expect(game.isPaused, isFalse);
      });

      test('currentStateは常に現在の状態を返すこと', () {
        expect(game.currentState, equals(GameState.loading));

        game.setState(GameState.title);
        expect(game.currentState, equals(GameState.title));

        game.setState(GameState.playing);
        expect(game.currentState, equals(GameState.playing));

        game.setState(GameState.paused);
        expect(game.currentState, equals(GameState.paused));
      });
    });
  });
}
