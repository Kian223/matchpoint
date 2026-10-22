// ============================================================
// FILE   : screens/auth/splash_page.dart
// FUNGSI : Splash screen
//          Animasi logo lalu otomatis ke Login.
// UBAH DI SINI UNTUK: Ubah animasi pembuka.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/common_widgets.dart';
import 'login_page.dart';

/// Splash screen: logo membesar dengan efek memantul, teks muncul bergantian, lalu bar loading.
/// Setelah selesai otomatis pindah ke halaman Login dengan transisi fade.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  // Satu controller, dibagi menjadi beberapa tahap lewat Interval
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
  late final Animation<double> _logo = CurvedAnimation(parent: _c, curve: const Interval(0, .45, curve: Curves.elasticOut));
  late final Animation<double> _title = CurvedAnimation(parent: _c, curve: const Interval(.35, .7, curve: Curves.easeOutCubic));
  late final Animation<double> _sub = CurvedAnimation(parent: _c, curve: const Interval(.55, .85, curve: Curves.easeOut));
  late final Animation<double> _bar = CurvedAnimation(parent: _c, curve: const Interval(.2, 1, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(_next);
  }

  void _next() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) => const LoginPage(),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
    ));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Container(
          width: double.infinity,
          decoration: const BoxDecoration(gradient: C.heroGradient),
          child: Stack(children: [
            // Lingkaran dekorasi di latar
            Positioned(top: -60 + 20 * _logo.value, right: -50, child: _circle(220, .10)),
            Positioned(bottom: -80, left: -60 + 20 * _logo.value, child: _circle(260, .08)),
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Opacity(
                  opacity: _logo.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _logo.value,
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: C.lime.withValues(alpha: .35), blurRadius: 10 + 40 * _logo.value.clamp(0.0, 1.0), spreadRadius: 2)]),
                      child: logoBox(size: 96),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Opacity(
                  opacity: _title.value,
                  child: Transform.translate(offset: Offset(0, 20 * (1 - _title.value)), child: const Text('MatchPoint', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 1))),
                ),
                const SizedBox(height: 6),
                Opacity(opacity: _sub.value, child: const Text('GOR Bulutangkis Bandung', style: TextStyle(color: C.lime, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2))),
                const SizedBox(height: 40),
                Opacity(
                  opacity: _sub.value,
                  child: SizedBox(
                    width: 150,
                    child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: _bar.value, minHeight: 5, backgroundColor: Colors.white24, color: C.lime)),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _circle(double s, double a) => Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: a)));
}
