// ============================================================
// FILE   : widgets/common_widgets.dart
// FUNGSI : Widget umum
//          card(), chip(), logoBox(), pageHeader(), sectionTitle(), soon(), summaryRow().
// UBAH DI SINI UNTUK: Ubah gaya kartu / chip di seluruh aplikasi.
// ============================================================

import 'package:flutter/material.dart';
import '../core/app_colors.dart';

Widget card({required Widget child, EdgeInsets? padding, Color? color, Gradient? gradient, double radius = 18}) =>
    Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Colors.white) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: C.border),
      ),
      child: child,
    );

Widget chip(String t, {Color bg = const Color(0xFFE8F5EC), Color fg = C.green, IconData? icon}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 11, color: fg), const SizedBox(width: 3)],
        Text(t, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
      ]),
    );

Widget logoBox({double size = 36}) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: C.primary,
        borderRadius: BorderRadius.circular(size * .3),
        border: Border.all(color: C.lime.withValues(alpha: .6)),
      ),
      child: Icon(Icons.sports_tennis, color: C.lime, size: size * .55),
    );

void soon(BuildContext c, [String m = 'Fitur ini dibuat di tahap berikutnya']) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m), duration: const Duration(seconds: 1)));

Widget pageHeader(BuildContext c, String t) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
      child: Row(children: [
        IconButton(onPressed: () => Navigator.of(c).pop(), icon: const Icon(Icons.arrow_back)),
        logoBox(size: 28),
        const SizedBox(width: 8),
        Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ]),
    );

Widget sectionTitle(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
    );

Widget summaryRow(String l, String v, {bool bold = false, Color? c}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(child: Text(l, style: TextStyle(fontSize: 11, color: bold ? Colors.black : C.muted, fontWeight: bold ? FontWeight.w800 : FontWeight.w500))),
        Text(v, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: c)),
      ]),
    );
