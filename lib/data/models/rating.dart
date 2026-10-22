// ============================================================
// FILE   : data/models/rating.dart
// FUNGSI : Model rating
//          Rating & ulasan setelah sesi bermain.
// UBAH DI SINI UNTUK: —
// ============================================================

/// Ulasan dari customer setelah sesi bermain selesai (sewa privat maupun mabar).
class Rating {
  final String id, bookingId, raterEmail, raterName, targetName, comment;

  /// true = menilai room mabar (host), false = menilai pengalaman di GOR / lapangan.
  final bool isRoom;
  final String? hostEmail; // diisi bila yang dinilai adalah host room
  final int stars; // 1..5
  final DateTime at;

  Rating({
    required this.id, required this.bookingId, required this.raterEmail, required this.raterName,
    required this.targetName, required this.comment, required this.isRoom, this.hostEmail,
    required this.stars, required this.at,
  });
}
