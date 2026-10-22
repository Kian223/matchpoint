// ============================================================
// FILE   : widgets/live_builder.dart
// FUNGSI : LiveBuilder
//          Membangun ulang tampilan tiap detik + saat data berubah (countdown realtime).
// UBAH DI SINI UNTUK: —
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../data/app_store.dart';

/// Membangun ulang tampilan tiap detik DAN setiap data store berubah (untuk countdown realtime).
class LiveBuilder extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  const LiveBuilder(this.builder, {super.key});
  @override
  State<LiveBuilder> createState() => _LiveBuilderState();
}

class _LiveBuilderState extends State<LiveBuilder> {
  Timer? _t;
  void _r() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    AppStore.I.addListener(_r);
    _t = Timer.periodic(const Duration(seconds: 1), (_) => _r());
  }

  @override
  void dispose() {
    AppStore.I.removeListener(_r);
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
