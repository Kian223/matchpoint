// ============================================================
// FILE   : core/theme.dart
// FUNGSI : Tema global
//          Font, warna dasar, dan animasi perpindahan halaman.
// UBAH DI SINI UNTUK: Ubah font / gaya transisi halaman.
// ============================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tema aplikasi: font, warna dasar, dan animasi perpindahan halaman (fade + geser halus).
/// Ubah tampilan global dari file ini.
class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: C.primary),
        scaffoldBackgroundColor: C.bg,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {for (final p in TargetPlatform.values) p: const SmoothTransitionsBuilder()},
        ),
      );
}

/// Transisi halaman: fade-in sambil bergeser sedikit dari kanan.
class SmoothTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothTransitionsBuilder();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(curved), child: child),
    );
  }
}
