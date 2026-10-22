// ============================================================
// FILE   : data/models/chat_message.dart
// FUNGSI : Model chat customer-admin
//          ChatMsg.
// UBAH DI SINI UNTUK: —
// ============================================================

class ChatMsg {
  final String customerEmail, text;
  final bool fromAdmin;
  final DateTime at;
  bool read;
  ChatMsg(this.customerEmail, this.text, this.fromAdmin, this.at, {this.read = false});
}
