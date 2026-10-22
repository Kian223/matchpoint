// ============================================================
// FILE   : data/models/app_notification.dart
// FUNGSI : Model notifikasi
//          Notif (lonceng notifikasi).
// UBAH DI SINI UNTUK: —
// ============================================================

class Notif {
  final String to, text;
  final DateTime at = DateTime.now();
  bool read = false;
  Notif(this.to, this.text);
}
