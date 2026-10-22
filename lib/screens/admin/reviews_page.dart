// ============================================================
// FILE   : screens/admin/reviews_page.dart
// FUNGSI : Ulasan customer
//          Rata-rata rating + daftar ulasan.
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/live_builder.dart';
import '../../widgets/star_row.dart';
import '../../widgets/user_avatar.dart';

/// Admin: daftar rating & ulasan dari customer (hasil RatingPage).
class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStore.I;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          pageHeader(context, 'Ulasan Customer'),
          Expanded(
            child: LiveBuilder((context) {
              final list = s.ratings.reversed.toList();
              return ListView(padding: const EdgeInsets.all(16), children: [
                card(
                  gradient: C.heroGradient,
                  child: Row(children: [
                    Text(s.ratingCount == 0 ? '-' : s.avgRating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      StarRow(s.avgRating, size: 20),
                      const SizedBox(height: 4),
                      Text('${s.ratingCount} ulasan', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 14),
                if (list.isEmpty) const Text('Belum ada ulasan. Ulasan muncul setelah customer menyelesaikan sesi bermain.', style: TextStyle(fontSize: 12, color: C.muted)),
                for (final r in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: card(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          UserAvatar(r.raterName, email: r.raterEmail, r: 16),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.raterName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            Text('${r.isRoom ? 'Room' : 'Lapangan'}: ${r.targetName}', style: const TextStyle(fontSize: 10, color: C.muted)),
                          ])),
                          StarRow(r.stars.toDouble()),
                        ]),
                        if (r.comment.isNotEmpty) ...[const SizedBox(height: 8), Text(r.comment, style: const TextStyle(fontSize: 11))],
                        const SizedBox(height: 4),
                        Text('${tanggalPendek(r.at)} ${jam(r.at)}', style: const TextStyle(fontSize: 9, color: C.muted)),
                      ]),
                    ),
                  ),
              ]);
            }),
          ),
        ]),
      ),
    );
  }
}
