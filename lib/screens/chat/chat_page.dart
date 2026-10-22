// ============================================================
// FILE   : screens/chat/chat_page.dart
// FUNGSI : Chat customer ↔ admin
//          Dipakai kedua role; pesan tersimpan di AppStore.
// UBAH DI SINI UNTUK: Ubah tampilan chat.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/booking.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/user.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/user_avatar.dart';
import '../customer/receipt_page.dart';

/// Ruang chat antara satu customer dan admin GOR (dipakai oleh kedua role).
class ChatPage extends StatefulWidget {
  final String customerEmail;
  final bool embedded; // true = dipakai sebagai tab (tanpa tombol back)
  const ChatPage({super.key, required this.customerEmail, this.embedded = false});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final store = AppStore.I;
  final ctrl = TextEditingController();
  final sc = ScrollController();
  int _n = -1;

  bool get admin => store.current?.role == Role.admin;

  /// Email lawan bicara (untuk foto profil di chat).
  String get _peerEmail => admin ? widget.customerEmail : store.users.firstWhere((u) => u.role == Role.admin).email;

  void _send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    store.sendChat(widget.customerEmail, t, fromAdmin: admin);
    ctrl.clear();
  }

  @override
  void dispose() {
    ctrl.dispose();
    sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customer = store.users.firstWhere((u) => u.email == widget.customerEmail);
    final peerName = admin ? customer.name : 'Pak Asep Suherman';
    final peerSub = admin ? 'Customer • ${customer.level}' : 'Supervisor Lapangan';
    final chips = admin
        ? ['Pembayaran Diterima', 'Lapangan Siap', 'Mohon Ditunggu']
        : ['Tambah Sewa Kok', 'Reschedule Jadwal', 'Tanya Ketersediaan'];
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final msgs = store.thread(widget.customerEmail);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              store.readChat(widget.customerEmail, byAdmin: admin);
              if (msgs.length != _n) {
                _n = msgs.length;
                if (sc.hasClients) sc.jumpTo(sc.position.maxScrollExtent);
              }
            });
            final items = <Widget>[];
            DateTime? prev;
            for (final m in msgs) {
              if (prev == null || !sameDay(prev, m.at)) {
                items.add(Center(child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE4E1FA), borderRadius: BorderRadius.circular(20)),
                  child: Text(sameDay(m.at, DateTime.now()) ? 'Hari ini, ${tanggal(m.at).split(', ').last}' : tanggal(m.at), style: const TextStyle(fontSize: 10, color: C.muted, fontWeight: FontWeight.w700)),
                )));
              }
              prev = m.at;
              items.add(_bubble(m, peerName));
            }
            if (msgs.isEmpty) {
              items.add(const Padding(padding: EdgeInsets.only(top: 60), child: Center(child: Text('Belum ada pesan. Mulai percakapan!', style: TextStyle(color: C.muted, fontSize: 12)))));
            }
            return Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                child: Row(children: [
                  if (widget.embedded) const SizedBox(width: 12) else IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                  Expanded(child: Text(admin ? 'Chat dengan ${customer.name}' : 'Chat Customer & Admin GOR', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
                  const CircleAvatar(radius: 16, backgroundColor: C.primary, child: Icon(Icons.person, size: 18, color: Colors.white)),
                ]),
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _bookingCard(context)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(children: [
                  UserAvatar(peerName, email: _peerEmail, r: 14, online: true),
                  const SizedBox(width: 8),
                  Text(peerName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  Text('  •  $peerSub', style: const TextStyle(fontSize: 10, color: C.muted)),
                ]),
              ),
              Expanded(child: ListView(controller: sc, padding: const EdgeInsets.fromLTRB(16, 4, 16, 8), children: items)),
              SizedBox(
                height: 36,
                child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
                  for (final c in chips)
                    GestureDetector(
                      onTap: () => _send(c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
                        child: Text(c, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ]),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Row(children: [
                  GestureDetector(onTap: () => soon(context), child: const CircleAvatar(radius: 18, backgroundColor: C.primary, child: Icon(Icons.add, color: Colors.white, size: 20))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      onSubmitted: _send,
                      textInputAction: TextInputAction.send,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: admin ? 'Ketik balasan untuk ${customer.name}...' : 'Ketik pesan untuk Admin GOR...',
                        hintStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        suffixIcon: const Icon(Icons.mic_none, size: 20, color: C.muted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: C.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: C.border)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: () => _send(ctrl.text), child: const CircleAvatar(radius: 20, backgroundColor: C.primary, child: Icon(Icons.send_rounded, color: Colors.white, size: 18))),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _bookingCard(BuildContext context) {
    final list = store.bookingsOf(widget.customerEmail);
    if (list.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now();
    final b = list.firstWhere((x) => x.end.isAfter(now), orElse: () => list.last);
    final tag = b.isLive ? 'ACTIVE' : b.status == BookingStatus.confirmed ? 'TERJADWAL' : 'MENUNGGU';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptPage(b))),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xFF0B2E1F), Color(0xFF1F4F34)])),
        child: Row(children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: C.lime, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.sports_tennis, size: 18, color: C.primary)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('COURT 0${b.court.no} $tag', style: const TextStyle(color: C.lime, fontSize: 9, fontWeight: FontWeight.w800)),
            Text('${tanggalPendek(b.start)} • ${jam(b.start)} - ${jam(b.end)} WIB', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ])),
          const Text('Detail ›', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _bubble(ChatMsg m, String peerName) {
    final mine = m.fromAdmin == admin;
    final time = Text(jam(m.at), style: TextStyle(fontSize: 9, color: mine ? Colors.white70 : C.muted, fontWeight: FontWeight.w600));
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .68),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: mine ? C.primary : Colors.white,
        borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(mine ? 16 : 4), bottomRight: Radius.circular(mine ? 4 : 16)),
        border: mine ? null : Border.all(color: C.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(m.text, style: TextStyle(fontSize: 12, height: 1.35, color: mine ? Colors.white : Colors.black87)),
        const SizedBox(height: 4),
        Row(mainAxisSize: MainAxisSize.min, children: [
          time,
          if (mine) ...[const SizedBox(width: 4), Icon(Icons.done_all, size: 12, color: m.read ? C.lime : Colors.white54)],
        ]),
      ]),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[UserAvatar(peerName, email: _peerEmail, r: 13), const SizedBox(width: 6)],
          bubble,
        ],
      ),
    );
  }
}
