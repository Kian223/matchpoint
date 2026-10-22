// ============================================================
// FILE   : data/models/facility.dart
// FUNGSI : Model fasilitas GOR
//          Facility (nama + ikon).
// UBAH DI SINI UNTUK: —
// ============================================================

/// Fasilitas GOR yang ditampilkan di Home (Mushola, Parkir, dll). Dikelola admin.
class Facility {
  final String id;
  String name;

  /// Kunci ikon, lihat core/facility_icons.dart.
  String iconKey;
  Facility(this.id, this.name, this.iconKey);
}
