import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
  }

  Future<void> playSoundEffect(String fileName) async {
    if (!_soundEnabled) return;
    
    try {
      await FlameAudio.play(fileName);
    } catch (e) {
      // 音声ファイルの読み込みに失敗した場合は静かに失敗
      // デバッグ時やログが必要な場合はここに追加
    }
  }

  Future<void> playMusic(String fileName, {bool loop = true}) async {
    if (!_musicEnabled) return;
    
    try {
      if (loop) {
        await FlameAudio.loop(fileName);
      } else {
        await FlameAudio.play(fileName);
      }
    } catch (e) {
      // 音楽ファイルの読み込みに失敗した場合は静かに失敗
    }
  }

  Future<void> stopMusic() async {
    try {
      await FlameAudio.bgm.stop();
    } catch (e) {
      // 停止に失敗した場合は静かに失敗
    }
  }

  Future<void> pauseMusic() async {
    try {
      await FlameAudio.bgm.pause();
    } catch (e) {
      // 一時停止に失敗した場合は静かに失敗
    }
  }

  Future<void> resumeMusic() async {
    try {
      await FlameAudio.bgm.resume();
    } catch (e) {
      // 再開に失敗した場合は静かに失敗
    }
  }

  void dispose() {
    FlameAudio.bgm.dispose();
  }

  // よく使用される効果音のヘルパーメソッド
  Future<void> playArrivalSound() async {
    await playSoundEffect('arrival.mp3');
  }

  Future<void> playClickSound() async {
    await playSoundEffect('click.mp3');
  }

  Future<void> playErrorSound() async {
    await playSoundEffect('error.mp3');
  }
}