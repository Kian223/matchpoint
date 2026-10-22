// ============================================================
// FILE   : screens/customer/room_detail_page.dart
// FUNGSI : Detail room mabar
//          Roster pemain, patungan, chat room, tombol bayar patungan.
// UBAH DI SINI UNTUK: Ubah detail room.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/room.dart';
import '../../widgets/animations.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/player_sheet.dart';
import '../../widgets/user_avatar.dart';
import 'payment_page.dart';
import 'room_chat_page.dart';

Widget _calc(String l, String v, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(child: Text(l, style: TextStyle(fontSize: 11, color: bold ? Colors.black : C.muted, fontWeight: bold ? FontWeight.w800 : FontWeight.w500))),
        Text(v, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
      ]),
    );

// ======================= DETAIL ROOM (JOIN) =======================
class RoomDetailPage extends StatelessWidget {
  final Room r;
  const RoomDetailPage(this.r, {super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.I;
    final me = store.current!;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final joined = r.has(me.email), full = r.left <= 0;
            final started = !r.end.isAfter(DateTime.now());
            return Column(children: [
              pageHeader(context, 'Detail Sesi Mabar'),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), children: [
                  Row(children: [
                    chip(full ? 'Room Penuh' : 'Room Aktif • Sisa ${r.left} Slot Lagi!', bg: full ? const Color(0xFFF1F1F4) : const Color(0xFFDCFCE7), fg: full ? C.muted : C.green),
                    const Spacer(),
                    chip(hariLabel(r.start), bg: const Color(0xFFEEECFF), fg: C.muted, icon: Icons.schedule),
                  ]),
                  const SizedBox(height: 10),
                  Text(r.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, children: [chip(r.format), chip('Level: ${r.level}', bg: const Color(0xFFE3EEFF), fg: const Color(0xFF1E5BB8)), chip('BWF ${r.court.type} Pro', bg: const Color(0xFFEEECFF), fg: C.muted)]),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF0B2E1F), Color(0xFF2F5D3B)])),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('COURT 0${r.court.no}', style: const TextStyle(color: C.lime, fontSize: 9, fontWeight: FontWeight.w800)),
                        const Text('GOR Bulutangkis\nBandung', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      ])),
                      Text('${r.court.type} Pro', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  card(child: Row(children: [
                    Container(width: 46, padding: const EdgeInsets.symmetric(vertical: 6), decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(10)), child: Column(children: [Text('${r.start.day}', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)), Text(hariSingkat(r.start), style: const TextStyle(color: C.lime, fontSize: 8))])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(tanggal(r.start), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      Text('${jam(r.start)} - ${jam(r.end)} WIB • ${r.hours} Jam Main', style: const TextStyle(fontSize: 10, color: C.muted)),
                    ])),
                  ])),
                  const SizedBox(height: 10),
                  _roomChatCard(context, store, r, joined),
                  const SizedBox(height: 10),
                  card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('FASILITAS TERMASUK GRATIS', style: TextStyle(fontSize: 8, letterSpacing: 1, color: C.muted, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    for (final f in r.facilities) Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [const Icon(Icons.check_circle, size: 14, color: C.green), const SizedBox(width: 8), Text(f, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))])),
                  ])),
                  const SizedBox(height: 10),
                  card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      UserAvatar(r.players.first.name, email: r.players.first.email, r: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [Text(r.hostName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)), const SizedBox(width: 6), chip('Host', bg: C.primary, fg: Colors.white)]),
                        Text('★ ${store.hostRating(r).toStringAsFixed(1)} • ${r.sessions} Sesi Sukses', style: const TextStyle(fontSize: 9, color: C.muted)),
                      ])),
                    ]),
                    const SizedBox(height: 8),
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF1EFFC), borderRadius: BorderRadius.circular(10)), child: Text('"${r.note}"', style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: C.muted))),
                  ])),
                  const SizedBox(height: 10),
                  card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('Roster Pemain ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                      chip('${r.players.length} Terisi'),
                      const Spacer(),
                      Text('Sisa ${r.left} Slot', style: const TextStyle(fontSize: 10, color: C.red, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 8),
                    for (var i = 0; i < r.players.length; i++)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onTap: () => showPlayerSheet(context, r.players[i]),
                        leading: UserAvatar(r.players[i].name, email: r.players[i].email, r: 16, bg: r.players[i].email == me.email ? C.green : C.primary),
                        title: Row(children: [Text(r.players[i].name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)), if (i == 0) ...[const SizedBox(width: 6), chip('Host', bg: C.primary, fg: Colors.white)]]),
                        subtitle: Text(r.players[i].level, style: const TextStyle(fontSize: 9)),
                        trailing: chip('LUNAS'),
                      ),
                    for (var i = 0; i < r.left; i++)
                      ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const CircleAvatar(radius: 16, backgroundColor: Color(0xFFE5E7EB), child: Icon(Icons.person_add_alt, size: 16, color: C.muted)), title: const Text('Slot Kosong', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), subtitle: const Text('Bisa ajak teman mabar', style: TextStyle(fontSize: 9))),
                  ])),
                  const SizedBox(height: 10),
                  card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Kalkulasi Patungan Transparan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    _calc('Sewa Lapangan (${r.hours} Jam)', rupiah(r.courtFee)),
                    _calc('Perlengkapan', rupiah(r.facilityFee)),
                    const Divider(height: 14),
                    _calc('Total Biaya Sesi', rupiah(r.courtFee + r.facilityFee), bold: true),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFEFFBD6), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Expanded(child: Text('BIAYA PER PEMAIN (NETT)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF3F6212)))),
                        Text('${rupiah(r.share)}/orang', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ])),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, disabledBackgroundColor: const Color(0xFFD1D5DB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: joined || full || started
                        ? null
                        : () {
                            final lines = <(String, int)>[('Patungan Mabar: ${r.title}', r.share)];
                            Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentPage(Draft(
                              title: 'Bayar Patungan Mabar',
                              subtitle: '${r.title} • ${tanggalPendek(r.start)}, ${jam(r.start)} - ${jam(r.end)}',
                              lines: lines,
                              commit: (m, code) => store.joinRoom(me, r, lines, code, m),
                            ))));
                          },
                    child: Text(joined ? 'Kamu Sudah Bergabung' : full ? 'Room Penuh' : started ? 'Sesi Sudah Selesai' : 'Konfirmasi & Bayar Patungan', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

/// Kartu akses Chat Room: aktif untuk pemain yang sudah join, terkunci untuk yang belum.
Widget _roomChatCard(BuildContext context, AppStore store, Room r, bool joined) {
  final last = store.roomThread(r.id).where((m) => !m.system).lastOrNull;
  return Pressable(
    onTap: joined ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomChatPage(r))) : () => soon(context, 'Gabung & bayar patungan dulu untuk ikut chat room'),
    child: card(
      child: Row(children: [
        CircleAvatar(radius: 20, backgroundColor: (joined ? C.green : C.muted).withValues(alpha: .15), child: Icon(joined ? Icons.forum_outlined : Icons.lock_outline, color: joined ? C.green : C.muted, size: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Chat Room Mabar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            Text(joined ? (last == null ? 'Belum ada pesan, sapa pemain lain!' : '${last.senderName}: ${last.text}') : 'Terbuka untuk pemain yang sudah bergabung', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: C.muted)),
          ]),
        ),
        const Icon(Icons.chevron_right, color: C.muted),
      ]),
    ),
  );
}
