// ============================================================
// FILE   : widgets/app_top_bar.dart
// FUNGSI : Top bar
//          Logo, lonceng notifikasi (badge), dan foto profil.
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/formatters.dart';
import '../data/app_store.dart';
import 'common_widgets.dart';
import 'user_avatar.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        logoBox(),
        const SizedBox(width: 8),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MatchPoint', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.1)),
          Text('BANDUNG COURTS', style: TextStyle(fontSize: 8, letterSpacing: 1, color: C.muted, fontWeight: FontWeight.w600)),
        ]),
        const Spacer(),
        const _Bell(),
        const SizedBox(width: 10),
        UserAvatar(AppStore.I.current?.name ?? '?', email: AppStore.I.current?.email, r: 16),
      ]);
}

/// Lonceng notifikasi: admin dapat notif saat ada pesanan masuk, customer saat pesanan disetujui/ditolak.
class _Bell extends StatelessWidget {
  const _Bell();
  @override
  Widget build(BuildContext context) {
    final s = AppStore.I;
    return ListenableBuilder(
      listenable: s,
      builder: (ctx, _) {
        final n = s.unread;
        return GestureDetector(
          onTap: () {
            final list = s.myNotifs;
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (_) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: list.isEmpty
                    ? const SizedBox(height: 90, child: Center(child: Text('Belum ada notifikasi', style: TextStyle(color: C.muted))))
                    : ListView(shrinkWrap: true, children: [
                        for (final x in list)
                          ListTile(
                            dense: true,
                            leading: Icon(Icons.notifications_active_outlined, color: x.read ? C.muted : C.green),
                            title: Text(x.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            subtitle: Text(jam(x.at), style: const TextStyle(fontSize: 10)),
                          ),
                      ]),
              ),
            );
            s.markRead();
          },
          child: Stack(children: [
            const Icon(Icons.notifications_none_rounded, size: 26),
            if (n > 0)
              Positioned(right: 0, top: 0, child: CircleAvatar(radius: 7, backgroundColor: C.red, child: Text('$n', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)))),
          ]),
        );
      },
    );
  }
}
