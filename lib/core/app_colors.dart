// ============================================================
// FILE   : core/app_colors.dart
// FUNGSI : Palet warna (class C)
//          Semua warna & gradasi aplikasi. C = singkatan "Colors".
// UBAH DI SINI UNTUK: Ubah warna tema: edit di sini, seluruh aplikasi ikut berubah.
// ============================================================

import 'package:flutter/material.dart';

class C {
  static const primary = Color(0xFF04261A);
  static const primary2 = Color(0xFF14452F);
  static const lime = Color(0xFFB7F24B);
  static const bg = Color(0xFFF1EFFC);
  static const border = Color(0xFFE6E4F4);
  static const muted = Color(0xFF6B7280);
  static const green = Color(0xFF16A34A);
  static const red = Color(0xFFDC2626);

  // ---- Aksen warna tambahan (kartu, ikon fasilitas, banner) ----
  static const teal = Color(0xFF14B8A6);
  static const orange = Color(0xFFF97316);
  static const violet = Color(0xFF7C3AED);
  static const pink = Color(0xFFEC4899);
  static const sky = Color(0xFF0EA5E9);
  static const amber = Color(0xFFF59E0B);
  static const accents = [teal, orange, violet, pink, sky, amber];

  /// Gradasi utama (splash, kartu sapaan).
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF0B2E1F), Color(0xFF1F7A4D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// 4 pilihan warna latar banner promo (dipilih admin).
  static const bannerGradients = [
    LinearGradient(colors: [Color(0xFF0B2E1F), Color(0xFF1F7A4D)]),
    LinearGradient(colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)]),
    LinearGradient(colors: [Color(0xFFC2410C), Color(0xFFF59E0B)]),
    LinearGradient(colors: [Color(0xFF0369A1), Color(0xFF14B8A6)]),
  ];
}
