// ============================================================
// FILE   : main.dart
// FUNGSI : Titik masuk aplikasi
//          Memasang tema (core/theme.dart) lalu membuka SplashPage.
// UBAH DI SINI UNTUK: Ganti halaman awal / judul aplikasi.
// ============================================================

import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/auth/splash_page.dart';

/// Titik masuk aplikasi: memasang tema dan membuka Splash Screen.
void main() => runApp(const MatchPointApp());

class MatchPointApp extends StatelessWidget {
  const MatchPointApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'MatchPoint',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashPage(),
      );
}
