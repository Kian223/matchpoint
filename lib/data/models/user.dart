// ============================================================
// FILE   : data/models/user.dart
// FUNGSI : Model akun
//          Role dan AppUser (profil, foto, media sosial).
// UBAH DI SINI UNTUK: Tambah field profil baru.
// ============================================================

import 'dart:typed_data';

/// Peran pengguna: menentukan halaman yang dibuka setelah login.
enum Role { admin, customer }

/// Data akun (customer maupun admin).
/// Semua field dibuat mutable supaya bisa diedit dari halaman Profil.
class AppUser {
  String name, email, phone, password, level, title;
  final Role role;
  String bio, gender, hand, racket, shoe, homeBase, nip;

  /// Akun media sosial (diisi dari halaman Profil).
  String instagram, twitter, facebook;

  /// Foto profil (bytes hasil image picker). null = tampilkan inisial nama.
  Uint8List? photo;

  Set<String> types; // tipe bermain favorit
  List<bool> toggles; // pengaturan notifikasi / privasi

  AppUser(this.name, this.email, this.phone, this.password, this.role,
      {this.level = 'Beginner', this.title = '', this.bio = '', this.gender = 'Pria',
      this.hand = 'Kanan', this.racket = '', this.shoe = '', this.homeBase = 'GOR Bulutangkis Bandung',
      this.nip = '', this.instagram = '', this.twitter = '', this.facebook = '', this.photo,
      Set<String>? types, List<bool>? toggles})
      : types = types ?? {},
        toggles = toggles ?? [true, true, true];
}
