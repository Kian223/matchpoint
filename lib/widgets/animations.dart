// ============================================================
// FILE   : widgets/animations.dart
// FUNGSI : Animasi
//          FadeSlideIn (muncul halus) dan Pressable (efek tekan).
// UBAH DI SINI UNTUK: Ubah kecepatan / gaya animasi.
// ============================================================

import 'package:flutter/material.dart';

/// Animasi kecil yang dipakai di banyak halaman.

/// Muncul perlahan sambil naik sedikit. [delayMs] dipakai untuk efek berurutan (stagger).
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final double dy;
  const FadeSlideIn({super.key, required this.child, this.delayMs = 0, this.dy = 18});
  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _a,
        builder: (_, child) => Opacity(opacity: _a.value, child: Transform.translate(offset: Offset(0, (1 - _a.value) * widget.dy), child: child)),
        child: widget.child,
      );
}

/// Efek mengecil sedikit saat disentuh (terasa "empuk"). Bungkus kartu / tombol apa saja.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const Pressable({super.key, required this.child, this.onTap});
  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(scale: _down ? 0.96 : 1, duration: const Duration(milliseconds: 120), curve: Curves.easeOut, child: widget.child),
      );
}
