// ============================================================
// FILE   : core/feedback_service.dart
// FUNGSI : Getar & bunyi
//          Dipakai saat pemesanan berhasil dan notifikasi masuk.
// UBAH DI SINI UNTUK: Ganti jenis getar / bunyi.
// ============================================================

import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class FeedbackService {
  static final _player = AudioPlayer();
  static bool isAlarmPlaying = false; // Penanda apakah alarm sedang nyala

  /// Pemesanan berhasil dibuat.
  static void booking() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  /// Notifikasi masuk.
  static void notify() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Sentuhan ringan (pilih bintang, dsb.).
  static void tap() => HapticFeedback.selectionClick();

  /// Bunyikan alarm khusus (looping)
  static Future<void> alarm() async {
    isAlarmPlaying = true;
    HapticFeedback.heavyImpact();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sounds/alert.mp3')); // Menggunakan alert.mp3
  }

  /// Matikan alarm
  static Future<void> stopAlarm() async {
    isAlarmPlaying = false;
    await _player.stop();
  }

  /// Bolak-balik nyala/mati (Toggle) dari ikon speaker
  static Future<void> toggleAlarm() async {
    if (isAlarmPlaying) {
      await stopAlarm();
    } else {
      await alarm();
    }
  }
}