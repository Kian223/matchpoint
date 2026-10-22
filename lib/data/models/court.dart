// ============================================================
// FILE   : data/models/court.dart
// FUNGSI : Model lapangan
//          Court dan CourtStatus (aman / maintenance / dipesan).
// UBAH DI SINI UNTUK: Tambah atribut lapangan.
// ============================================================

enum CourtStatus { aman, maintenance, dipesan }

class Court {
  final int no;
  int price;
  String type;
  CourtStatus status;
  Court(this.no, this.type, this.price, {bool maintenance = false})
      : status = maintenance ? CourtStatus.maintenance : CourtStatus.aman;
  bool get maintenance => status == CourtStatus.maintenance;
  String get name => 'Lapangan ${no < 10 ? '0$no' : '$no'}';
}
