import 'package:audioplayers/audioplayers.dart';

class SoundUtils {
  static final _player = AudioPlayer();

  static Future<void> playDone() async {
    await _player.play(AssetSource('sounds/success.m4a'));
  }
}
