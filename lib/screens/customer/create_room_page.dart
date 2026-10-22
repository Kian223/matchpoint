// ============================================================
// FILE   : screens/customer/create_room_page.dart
// FUNGSI : Buat room (host)
//          Form pembuatan room + kalkulasi patungan otomatis.
// UBAH DI SINI UNTUK: Ubah form host.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/court.dart';
import '../../data/models/room.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/user_avatar.dart';
import 'payment_page.dart';

// ======================= BUAT ROOM (HOST) =======================
class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});
  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final store = AppStore.I;
  final title = TextEditingController();
  final note = TextEditingController();
  String format = 'Game Bebas', level = 'Semua Level';
  late Court court = store.courts.firstWhere((c) => c.status == CourtStatus.aman);
  int dayOffset = 0, dur = 1, quota = 4;
  int? startH;
  final fac = <int>{};

  static const presets = ['Ganda Bebas', 'Ganda Putra', 'Ganda Putri', 'Fun Sparring'];
  static const facs = [('Sediakan Kok Bulutangkis', 60000), ('Wasit / Pencatat Skor GOR', 40000), ('Air Mineral & Handuk Bersama', 35000)];

  DateTime get day {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day + dayOffset);
  }

  bool _free(int h) {
    for (var k = 0; k < dur; k++) {
      final s = DateTime(day.year, day.month, day.day, h + k);
      if (!store.openHours.contains(h + k) || store.slotTaken(court, s) || s.add(const Duration(hours: 1)).isBefore(DateTime.now())) return false;
    }
    return true;
  }

  int get courtFee => court.price * dur;
  int get facFee => fac.fold(0, (s, i) => s + facs[i].$2);
  int get share => Room.split(courtFee + facFee, quota);

  void _submit() {
    if (title.text.trim().isEmpty || startH == null) {
      soon(context, 'Isi nama sesi dan pilih jam mulai dulu');
      return;
    }
    final me = store.current!;
    final start = DateTime(day.year, day.month, day.day, startH!);
    final room = Room(
      id: 'R${store.rooms.length + 1}${DateTime.now().millisecond}', title: title.text.trim(), format: format, level: level,
      note: note.text.trim().isEmpty ? 'Ayo main bareng, santai dan seru!' : note.text.trim(),
      hostName: me.name, hostEmail: me.email, quota: quota, courtFee: courtFee, facilityFee: facFee, court: court,
      start: start, end: start.add(Duration(hours: dur)),
      facilities: fac.isEmpty ? ['Bawa Raket Sendiri'] : [for (final i in fac) facs[i].$1],
      players: [Player(me.name, me.email, me.level)],
    );
    final lines = <(String, int)>[('Patungan Host: ${room.title}', room.share)];
    Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentPage(Draft(
      title: 'Publikasi Room & Bayar Bagian Host',
      subtitle: '${court.name} • ${tanggalPendek(start)}, ${jam(start)} - ${jam(room.end)}',
      lines: lines,
      commit: (m, code) => store.createRoom(me, room, lines, code, m),
    ))));
  }

  Widget _sec(String t) => Padding(padding: const EdgeInsets.only(top: 16, bottom: 8), child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)));

  Widget _chipSel(String t, bool on, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: on ? C.primary : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
          child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: on ? Colors.white : Colors.black87)),
        ),
      );

  InputDecoration _dec(String h) => InputDecoration(hintText: h, filled: true, fillColor: const Color(0xFFEEECFF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), hintStyle: const TextStyle(fontSize: 12));

  @override
  Widget build(BuildContext context) {
    final me = store.current!;
    final hoursFree = [for (final h in store.openHours) if (_free(h)) h];
    if (startH != null && !hoursFree.contains(startH)) startH = null;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          pageHeader(context, 'Buat Sesi Mabar'),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), children: [
              card(child: Row(children: [
                UserAvatar(me.name, email: me.email, r: 20),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(me.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  const Text('★ 4.8 • 42 Sesi Sukses', style: TextStyle(fontSize: 9, color: C.muted)),
                ])),
                chip('Host Terverifikasi'),
              ])),
              _sec('1. Judul & Format Sesi'),
              TextField(controller: title, decoration: _dec('Mabar Ganda Gore / Sparring Santai')),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [for (final p in presets) _chipSel(p, title.text == p, () => setState(() => title.text = p))]),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [for (final f in ['Game Bebas', 'Tunggal', 'Drill / Latihan']) _chipSel(f, format == f, () => setState(() => format = f))]),
              _sec('2. Lapangan & Jadwal'),
              Wrap(spacing: 8, runSpacing: 8, children: [for (final c in store.courts.where((c) => c.status == CourtStatus.aman)) _chipSel('${c.name} • ${c.type} ${rupiah(c.price)}/jam', court.no == c.no, () => setState(() => court = c))]),
              const SizedBox(height: 10),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                for (var i = 0; i < 5; i++)
                  Padding(padding: const EdgeInsets.only(right: 8), child: _chipSel('${i == 0 ? 'Hari Ini' : hariSingkat(DateTime.now().add(Duration(days: i)))} ${DateTime.now().add(Duration(days: i)).day}', dayOffset == i, () => setState(() => dayOffset = i))),
              ])),
              const SizedBox(height: 10),
              Row(children: [for (final d in [1, 2, 3]) Padding(padding: const EdgeInsets.only(right: 8), child: _chipSel('$d Jam', dur == d, () => setState(() => dur = d)))]),
              const SizedBox(height: 10),
              const Text('Jam mulai tersedia', style: TextStyle(fontSize: 10, color: C.muted)),
              const SizedBox(height: 6),
              if (hoursFree.isEmpty) const Text('Tidak ada slot kosong untuk pilihan ini.', style: TextStyle(fontSize: 11, color: C.red)),
              Wrap(spacing: 8, runSpacing: 8, children: [for (final h in hoursFree) _chipSel('${h.toString().padLeft(2, '0')}:00', startH == h, () => setState(() => startH = h))]),
              _sec('3. Kuota & Syarat Pemain'),
              card(child: Row(children: [
                const Expanded(child: Text('Target Kuota Pemain', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                IconButton(onPressed: () => setState(() { if (quota > 2) quota--; }), icon: const Icon(Icons.remove_circle_outline)),
                Text('$quota', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                IconButton(onPressed: () => setState(() { if (quota < 12) quota++; }), icon: const Icon(Icons.add_circle_outline)),
              ])),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [for (final l in ['Semua Level', 'Beginner', 'Intermediate', 'Advanced']) _chipSel(l, level == l, () => setState(() => level = l))]),
              _sec('4. Fasilitas & Perlengkapan'),
              for (var i = 0; i < facs.length; i++)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: C.primary,
                  value: fac.contains(i),
                  onChanged: (v) => setState(() => v == true ? fac.add(i) : fac.remove(i)),
                  title: Text(facs[i].$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  secondary: Text('+${rupiah(facs[i].$2)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.green)),
                ),
              const SizedBox(height: 6),
              TextField(controller: note, maxLines: 2, decoration: _dec('Catatan khusus dari host (opsional)')),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(18)),
                child: Column(children: [
                  Row(children: [const Text('Kalkulasi Patungan Otomatis', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)), const Spacer(), chip('Live System', bg: C.lime, fg: C.primary)]),
                  const SizedBox(height: 8),
                  _dark('Biaya Lapangan ($dur jam)', rupiah(courtFee)),
                  _dark('Fasilitas', rupiah(facFee)),
                  const Divider(color: Colors.white24),
                  _dark('Total Biaya Sesi', rupiah(courtFee + facFee)),
                  _dark('Dibagi Kuota', '$quota Pemain'),
                  const SizedBox(height: 6),
                  Row(children: [const Text('Patungan / orang', style: TextStyle(color: C.lime, fontSize: 11, fontWeight: FontWeight.w800)), const Spacer(), Text(rupiah(share), style: const TextStyle(color: C.lime, fontSize: 18, fontWeight: FontWeight.w800))]),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: C.lime, foregroundColor: C.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Publikasi & Bayar Bagian Host', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _dark(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [Expanded(child: Text(l, style: const TextStyle(color: Colors.white70, fontSize: 10))), Text(v, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))]),
      );
}
