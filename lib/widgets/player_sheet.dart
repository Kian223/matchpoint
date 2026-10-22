// ============================================================
// FILE   : widgets/player_sheet.dart
// FUNGSI : Profil singkat pemain
//          Bottom sheet saat menekan nama pemain di roster room.
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/app_store.dart';
import '../data/models/room.dart';
import 'common_widgets.dart';
import 'user_avatar.dart';

/// Bottom sheet profil singkat pemain (dibuka dengan menekan nama di roster room mabar).
/// Menampilkan level, bio, dan akun media sosial bila pemain sudah mengisinya.
void showPlayerSheet(BuildContext context, Player p) {
  final u = AppStore.I.users.where((x) => x.email == p.email).firstOrNull;
  final socials = <(IconData, String)>[
    if (u != null && u.instagram.isNotEmpty) (Icons.camera_alt_outlined, '@${u.instagram}'),
    if (u != null && u.twitter.isNotEmpty) (Icons.alternate_email, '@${u.twitter}'),
    if (u != null && u.facebook.isNotEmpty) (Icons.facebook, u.facebook),
  ];
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        UserAvatar(p.name, email: p.email, r: 34),
        const SizedBox(height: 10),
        Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        chip('Level: ${p.level}', bg: const Color(0xFFE3EEFF), fg: const Color(0xFF1E5BB8)),
        const SizedBox(height: 10),
        Text(u == null || u.bio.isEmpty ? 'Belum ada bio.' : u.bio, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: C.muted)),
        if (socials.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 6, children: [for (final s in socials) chip(s.$2, bg: const Color(0xFFEEECFF), fg: C.violet, icon: s.$1)]),
        ],
      ]),
    ),
  );
}
