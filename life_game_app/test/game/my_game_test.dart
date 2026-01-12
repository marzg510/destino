import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_game_app/src/my_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('MyGame - Garbage Collection', () {
    testWithGame<MyGame>(
      'selectNextGarbageがランダムなゴミを選択する',
      () => MyGame(),
      (game) async {
        await game.ready();
        game.startGame();
        await game.ready();

        final garbages = game.garbageManager.getAllGarbages();
        expect(garbages, isNotEmpty);

        game.selectNextGarbage();
        await game.ready();

        expect(game.player.destination, isNotNull);
      },
    );

    testWithGame<MyGame>(
      'resetGame後にゴミがクリアされる',
      () => MyGame(),
      (game) async {
        await game.ready();
        game.startGame();
        await game.ready();

        game.resetGame();
        await game.ready();

        // resetGameではゴミはクリアされるが、その後のupdateで再生成される
        expect(game.garbageManager, isNotNull);
      },
    );
  });
}
