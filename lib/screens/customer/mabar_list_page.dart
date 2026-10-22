// ============================================================
// FILE   : screens/customer/mabar_list_page.dart
// FUNGSI : Daftar room mabar
//          Filter hari/level, kartu room, tombol gabung.
// UBAH DI SINI UNTUK: Ubah tampilan daftar room.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/room.dart';
import '../../data/models/user.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/user_avatar.dart';
import 'create_room_page.dart';
import 'room_detail_page.dart';

Widget _pills(List<String> opts, String cur, ValueChanged<String> f) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final t in opts)
          GestureDetector(
            onTap: () => f(t),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: cur == t ? C.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
              child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cur == t ? Colors.white : Colors.black87)),
            ),
          ),
      ]),
    );

// ======================= DAFTAR MABAR =======================
class MabarListPage extends StatefulWidget {
  const MabarListPage({super.key});
  @override
  State<MabarListPage> createState() => _MabarListPageState();
}

class _MabarListPageState extends State<MabarListPage> {
  String day = 'Semua Jadwal', lvl = 'Semua';

  @override
  Widget build(BuildContext context) {
    final store = AppStore.I;
    final me = store.current!;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final now = DateTime.now();
            final tomorrow = DateTime(now.year, now.month, now.day + 1);
            final rooms = store.rooms.where((r) {
              if (!r.end.isAfter(now)) return false;
              final d = day == 'Hari Ini' ? sameDay(r.start, now) : day == 'Besok' ? sameDay(r.start, tomorrow) : day == 'Weekend Ini' ? r.start.weekday >= 6 : true;
              return d && (lvl == 'Semua' || r.level == lvl || r.level == 'Semua Level');
            }).toList()
              ..sort((a, b) => a.start.compareTo(b.start));
            return Column(children: [
              pageHeader(context, 'MatchPoint'),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 20), children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF0B2E1F), Color(0xFF1F4F34)])),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('KOMUNITAS MABAR BANDUNG', style: TextStyle(color: C.lime, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .5)),
                      const SizedBox(height: 6),
                      const Text('Main Bareng, Sehat Bareng, Patungan Hemat!', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      const Text('Temukan sparring partner selevel di Bandung tanpa repot cari pemain cadangan dan tagih kas lapangan.', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomPage())),
                          style: ElevatedButton.styleFrom(backgroundColor: C.lime, foregroundColor: C.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('+ Buat Sesi Mabar Baru (Host)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  _pills(['Hari Ini', 'Besok', 'Weekend Ini', 'Semua Jadwal'], day, (v) => setState(() => day = v)),
                  const SizedBox(height: 8),
                  _pills(['Semua', 'Beginner', 'Intermediate', 'Advanced'], lvl, (v) => setState(() => lvl = v)),
                  const SizedBox(height: 14),
                  Row(children: [
                    const Text('Room ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    chip('${rooms.length} Buka'),
                    const Spacer(),
                    const Text('Bandung Area', style: TextStyle(fontSize: 10, color: C.muted)),
                  ]),
                  const SizedBox(height: 10),
                  if (rooms.isEmpty) card(child: const Text('Belum ada room untuk filter ini. Jadilah host pertama!', style: TextStyle(fontSize: 12, color: C.muted))),
                  for (final r in rooms) Padding(padding: const EdgeInsets.only(bottom: 14), child: _roomCard(context, r, me)),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _roomCard(BuildContext context, Room r, AppUser me) {
    final joined = r.has(me.email), full = r.left <= 0;
    void open() => Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailPage(r)));
    return GestureDetector(
      onTap: open,
      child: card(
        radius: 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            chip(r.level, bg: const Color(0xFFE3EEFF), fg: const Color(0xFF1E5BB8)),
            const SizedBox(width: 6),
            chip(r.format, bg: const Color(0xFFEEECFF), fg: C.muted),
          ]),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('GOR Bulutangkis • ${r.court.name} (${r.court.type})', style: const TextStyle(fontSize: 10, color: C.muted)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(hariLabel(r.start), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.green)),
              Text('${jam(r.start)} - ${jam(r.end)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              Text('(${r.hours} Jam)', style: const TextStyle(fontSize: 9, color: C.muted)),
            ]),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF1EFFC), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              UserAvatar(r.players.first.name, email: r.players.first.email, r: 15),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${r.hostName}  ★ ${AppStore.I.hostRating(r).toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                Text('Host Terverifikasi • ${r.sessions} Mabar', style: const TextStyle(fontSize: 9, color: C.muted)),
              ])),
              chip(r.facilities.first, bg: const Color(0xFFEFFBD6), fg: const Color(0xFF3F6212)),
            ]),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Text('${r.players.length}/${r.quota} Pemain Terisi', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
            const Spacer(),
            Text(full ? 'Penuh' : 'Sisa ${r.left} Slot Lagi!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: full ? C.muted : C.red)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: r.players.length / r.quota, minHeight: 7, backgroundColor: const Color(0xFFE5E7EB), color: C.primary)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Kalkulasi Patungan', style: TextStyle(fontSize: 8, color: C.muted)),
              Text('${rupiah(r.share)} / orang', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              Text('Total Biaya ${rupiah(r.courtFee + r.facilityFee)} / ${r.quota} pemain', style: const TextStyle(fontSize: 8, color: C.muted)),
            ])),
            ElevatedButton(
              onPressed: open,
              style: ElevatedButton.styleFrom(backgroundColor: joined ? Colors.white : C.lime, foregroundColor: C.primary, elevation: 0, side: joined ? const BorderSide(color: C.primary) : null, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(130, 44)),
              child: Text(joined ? 'Lihat Room' : full ? 'Lihat Detail' : 'Gabung Mabar →', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ]),
        ]),
      ),
    );
  }
}
