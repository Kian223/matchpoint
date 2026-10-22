// ============================================================
// FILE   : screens/customer/room_chat_page.dart
// FUNGSI : Chat room mabar
//          Chat grup untuk pemain yang sudah join.
// UBAH DI SINI UNTUK: Ubah tampilan chat grup.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/room.dart';
import '../../data/models/room_message.dart';
import '../../data/models/user.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/user_avatar.dart';

/// Chat grup room mabar. Hanya pemain yang sudah join (termasuk host) yang bisa masuk.
/// Pesan sistem ("X bergabung ke room") dibuat otomatis oleh store saat ada yang join.
class RoomChatPage extends StatefulWidget {
  final Room room;
  const RoomChatPage(this.room, {super.key});
  @override
  State<RoomChatPage> createState() => _RoomChatPageState();
}

class _RoomChatPageState extends State<RoomChatPage> {
  final store = AppStore.I;
  final _ctrl = TextEditingController();
  final _sc = ScrollController();
  int _n = -1;

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    store.sendRoomMsg(widget.room, store.current!, t);
    _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.room;
    final me = store.current!;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final msgs = store.roomThread(r.id);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && msgs.length != _n) {
                _n = msgs.length;
                if (_sc.hasClients) _sc.jumpTo(_sc.position.maxScrollExtent);
              }
            });
            if (!r.has(me.email)) {
              return Column(children: [pageHeader(context, 'Chat Room'), const Expanded(child: Center(child: Text('Gabung ke room dulu untuk ikut chat.', style: TextStyle(color: C.muted))))]);
            }
            return Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                child: Row(children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    Text('${r.players.length} pemain • ${hariLabel(r.start)} ${jam(r.start)} • ${r.court.name}', style: const TextStyle(fontSize: 10, color: C.muted)),
                  ])),
                  SizedBox(
                    width: 74,
                    height: 32,
                    child: Stack(children: [
                      for (var i = 0; i < r.players.length && i < 3; i++) Positioned(left: i * 18.0, child: UserAvatar(r.players[i].name, email: r.players[i].email, r: 15, bg: C.accents[i % C.accents.length])),
                    ]),
                  ),
                ]),
              ),
              Expanded(
                child: ListView(controller: _sc, padding: const EdgeInsets.fromLTRB(16, 4, 16, 8), children: [
                  for (final m in msgs) _bubble(m, me),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      onSubmitted: (_) => _send(),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(hintText: 'Ketik pesan untuk room...', hintStyle: const TextStyle(fontSize: 12), filled: true, fillColor: Colors.white, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: C.border))),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: _send, child: const CircleAvatar(radius: 20, backgroundColor: C.primary, child: Icon(Icons.send_rounded, color: Colors.white, size: 18))),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _bubble(RoomMsg m, AppUser me) {
    if (m.system) {
      return Center(child: Container(margin: const EdgeInsets.symmetric(vertical: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE4E1FA), borderRadius: BorderRadius.circular(20)), child: Text(m.text, style: const TextStyle(fontSize: 10, color: C.muted, fontWeight: FontWeight.w700))));
    }
    final mine = m.senderEmail == me.email;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[UserAvatar(m.senderName, email: m.senderEmail, r: 13), const SizedBox(width: 6)],
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .66),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            decoration: BoxDecoration(
              color: mine ? C.primary : Colors.white,
              borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(mine ? 16 : 4), bottomRight: Radius.circular(mine ? 4 : 16)),
              border: mine ? null : Border.all(color: C.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!mine) Text(m.senderName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.green)),
              Text(m.text, style: TextStyle(fontSize: 12, height: 1.35, color: mine ? Colors.white : Colors.black87)),
              const SizedBox(height: 2),
              Text(jam(m.at), style: TextStyle(fontSize: 9, color: mine ? Colors.white70 : C.muted)),
            ]),
          ),
        ],
      ),
    );
  }
}
