// ============================================================
// FILE   : widgets/star_row.dart
// FUNGSI : Bintang rating
//          Baris bintang tampilan saja.
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Baris bintang (hanya tampilan). value 0..5, mendukung setengah bintang.
class StarRow extends StatelessWidget {
  final double value, size;
  const StarRow(this.value, {super.key, this.size = 14});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 1; i <= 5; i++)
          Icon(value >= i ? Icons.star_rounded : value >= i - .5 ? Icons.star_half_rounded : Icons.star_outline_rounded, size: size, color: C.amber),
      ]);
}
