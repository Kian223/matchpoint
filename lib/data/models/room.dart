// ============================================================
// FILE   : data/models/room.dart
// FUNGSI : Model room mabar
//          Room dan Player, termasuk hitungan patungan.
// UBAH DI SINI UNTUK: Ubah rumus patungan.
// ============================================================

import 'court.dart';

class Player {
  final String name, email, level;
  Player(this.name, this.email, this.level);
  String get initials =>
      name.trim().split(' ').take(2).map((e) => e[0]).join().toUpperCase();
}

class Room {
  final String id, title, format, level, note, hostName, hostEmail;
  final double rating;
  final int sessions, quota, courtFee, facilityFee;
  final Court court;
  final DateTime start, end;
  final List<String> facilities;
  final List<Player> players;
  Room({
    required this.id, required this.title, required this.format, required this.level,
    required this.note, required this.hostName, required this.hostEmail,
    this.rating = 4.8, this.sessions = 12, required this.quota,
    required this.courtFee, required this.facilityFee, required this.court,
    required this.start, required this.end, required this.facilities, required this.players,
  });
  static int split(int total, int q) => ((total / q) / 500).ceil() * 500;
  int get share => split(courtFee + facilityFee, quota);
  int get left => quota - players.length;
  int get hours => end.difference(start).inHours;
  bool has(String email) => players.any((p) => p.email == email);
}
