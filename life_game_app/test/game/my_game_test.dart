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

      test('初期状態ではpausedがfalseであること', () {
        expect(game.paused, isFalse);
      });
    });

    group('State Transitions', () {
      test('setStateで任意の状態に遷移できること', () {
        game.setState(GameState.title);
        expect(game.currentState, equals(GameState.title));

        game.setState(GameState.playing);
        expect(game.currentState, equals(GameState.playing));
        expect(game.isPlaying, isTrue);

        game.setState(GameState.loading);
        expect(game.currentState, equals(GameState.loading));
      });
    });

    group('Pause and Resume Methods', () {
      test('pause()でFlameのpausedがtrueになること', () {
        game.pause();
        expect(game.paused, isTrue);
      });

      test('resume()でFlameのpausedがfalseになること', () {
        game.pause();
        expect(game.paused, isTrue);
        game.resume();
        expect(game.paused, isFalse);
      });

      test('pause/resumeを複数回繰り返せること', () {
        // First pause/resume cycle
        game.pause();
        expect(game.paused, isTrue);
        game.resume();
        expect(game.paused, isFalse);

        // Second pause/resume cycle
        game.pause();
        expect(game.paused, isTrue);
        game.resume();
        expect(game.paused, isFalse);
      });
    });

    group('State Getters', () {
      test('isPlayingはplaying状態の時のみtrueを返すこと', () {
        expect(game.isPlaying, isFalse);

        game.setState(GameState.playing);
        expect(game.isPlaying, isTrue);

        game.setState(GameState.title);
        expect(game.isPlaying, isFalse);
      });

      test('currentStateは常に現在の状態を返すこと', () {
        expect(game.currentState, equals(GameState.loading));

        game.setState(GameState.title);
        expect(game.currentState, equals(GameState.title));

        game.setState(GameState.playing);
        expect(game.currentState, equals(GameState.playing));
      });
    });
  });
}
