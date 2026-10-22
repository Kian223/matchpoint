// ============================================================
// FILE   : widgets/user_avatar.dart
// FUNGSI : Avatar pengguna
//          Foto profil atau inisial nama.
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/app_store.dart';

/// Avatar pengguna: menampilkan foto profil bila ada, jika tidak tampil inisial nama.
/// Cukup beri [name] dan (opsional) [email] agar foto bisa dicari dari data akun.
class UserAvatar extends StatelessWidget {
  final String name;
  final String? email;
  final double r;
  final bool online;
  final Color? bg;
  const UserAvatar(this.name, {super.key, this.email, this.r = 16, this.online = false, this.bg});

  String get _initials => name.trim().split(' ').where((e) => e.isNotEmpty).take(2).map((e) => e[0]).join().toUpperCase();

  @override
  Widget build(BuildContext context) {
    final photo = email == null ? null : AppStore.I.photoOf(email!);
    final avatar = CircleAvatar(
      radius: r,
      backgroundColor: bg ?? C.primary,
      backgroundImage: photo == null ? null : MemoryImage(photo),
      child: photo == null ? Text(_initials, style: TextStyle(color: Colors.white, fontSize: r * .65, fontWeight: FontWeight.w800)) : null,
    );
    if (!online) return avatar;
    return Stack(children: [
      avatar,
      Positioned(right: 0, bottom: 0, child: Container(width: r * .6, height: r * .6, decoration: BoxDecoration(color: C.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)))),
    ]);
  }
}
