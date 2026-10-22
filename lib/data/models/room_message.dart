// ============================================================
// FILE   : data/models/room_message.dart
// FUNGSI : Model chat room mabar
//          RoomMsg (pesan grup room).
// UBAH DI SINI UNTUK: —
// ============================================================

/// Pesan di chat room mabar (grup: semua pemain yang sudah join).
class RoomMsg {
  final String roomId, senderEmail, senderName, text;
  final DateTime at;

  /// true = pesan sistem (mis. "Deffa bergabung ke room").
  final bool system;
  RoomMsg({required this.roomId, required this.senderEmail, required this.senderName, required this.text, required this.at, this.system = false});
}
