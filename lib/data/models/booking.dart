// ============================================================
// FILE   : data/models/booking.dart
// FUNGSI : Model pesanan
//          Booking, status, dan getter waktu (isLive, isEnded, isOverdue).
// UBAH DI SINI UNTUK: Ubah alur status pesanan.
// ============================================================

import 'court.dart';

enum BookingStatus { pending, confirmed, rejected, cancelled }

enum BookingType { private, mabar }

class Booking {
  final String id, customerEmail, customerName, method, title;
  final Court court;
  final DateTime start, end;
  final int price, code;
  final BookingType type;
  final bool isShare; // true = pembayaran patungan pemain yang join (bukan sewa lapangan)
  final String? roomId;
  final String roomTitle; // judul room mabar (dipakai saat memberi rating)
  final List<(String, int)> lines;
  BookingStatus status;
  bool finished = false, warnedBefore = false, warnedAfter = false, ratingAsked = false;
  DateTime? endedAt;
  Booking(this.id, this.customerEmail, this.customerName, this.court, this.start,
      this.end, this.price,
      {required this.title, this.type = BookingType.private, this.isShare = false,
      this.roomId, this.roomTitle = '', this.lines = const [], this.code = 0, this.method = '',
      this.status = BookingStatus.pending});
  int get hours => end.difference(start).inHours;
  int get total => price + code;
  String get kode =>
      '#MP-${start.year}${start.month.toString().padLeft(2, '0')}${start.day.toString().padLeft(2, '0')}-${id.substring(4)}';
  /// Sesi sudah selesai (diakhiri admin atau jam sewa lewat) -> customer bisa memberi rating.
  bool get isEnded => status == BookingStatus.confirmed && (finished || !DateTime.now().isBefore(end));
  bool get dead => status == BookingStatus.rejected || status == BookingStatus.cancelled;
  bool get isLive {
    final n = DateTime.now();
    return status == BookingStatus.confirmed && !isShare && !finished && !n.isBefore(start) && n.isBefore(end);
  }

  /// Waktu sewa sudah habis tapi sesi belum diakhiri admin (maks. 30 menit ditampilkan).
  bool get isOverdue {
    final n = DateTime.now();
    return status == BookingStatus.confirmed && !isShare && !finished && !n.isBefore(end) && n.isBefore(end.add(const Duration(minutes: 30)));
  }

  /// Pendapatan sewa alat dalam transaksi ini (baris selain sewa lapangan / patungan).
  int get equipTotal => lines.where((l) => !l.$1.startsWith('Sewa') && !l.$1.startsWith('Patungan')).fold(0, (a, l) => a + l.$2);
}
