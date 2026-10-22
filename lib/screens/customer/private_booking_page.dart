// ============================================================
// FILE   : screens/customer/private_booking_page.dart
// FUNGSI : Booking lapangan privat
//          Pilih tanggal, court, jam, alat sewa lalu lanjut bayar.
// UBAH DI SINI UNTUK: Ubah alur booking privat.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/court.dart';
import '../../data/models/equipment.dart';
import '../../widgets/common_widgets.dart';
import 'payment_page.dart';

class PrivateBookingPage extends StatefulWidget {
  const PrivateBookingPage({super.key});
  @override
  State<PrivateBookingPage> createState() => _PrivateBookingPageState();
}

class _PrivateBookingPageState extends State<PrivateBookingPage> {
  final store = AppStore.I;
  late DateTime date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String type = 'Semua';
  Court? sel;
  Set<int> hours = {};
  final qty = <String, int>{};

  List<Equipment> get equip => store.equipment.where((e) => e.active).toList();
  Equipment? _eq(String id) => store.equipment.where((e) => e.id == id).firstOrNull;
  static const feature = {
    'Karpet': 'Lantai karpet anti-slip • Lampu 500 lux',
    'Vinyl': 'Vinyl standar BWF • Lampu anti-silau',
    'Parquet': 'Lantai kayu parquet • Sirkulasi udara terbaik',
  };

  void _tap(Court c, int h) {
    setState(() {
      if (sel?.no != c.no || hours.isEmpty) {
        sel = c;
        hours = {h};
      } else if (hours.contains(h)) {
        final lo = hours.reduce((a, b) => a < b ? a : b), hi = hours.reduce((a, b) => a > b ? a : b);
        if (h == lo || h == hi) {
          hours.remove(h);
        } else {
          hours = {h};
        }
      } else if (h == hours.reduce((a, b) => a < b ? a : b) - 1 || h == hours.reduce((a, b) => a > b ? a : b) + 1) {
        hours.add(h);
      } else {
        hours = {h};
      }
    });
  }

  int get equipFee => qty.entries.fold(0, (s, e) => s + e.value * (_eq(e.key)?.price ?? 0));
  int get courtFee => (sel?.price ?? 0) * hours.length;

  void _pay() {
    if (sel == null || hours.isEmpty) {
      soon(context, 'Pilih court dan jam main dulu');
      return;
    }
    final user = store.current!;
    final c = sel!;
    final hs = hours.toList()..sort();
    final start = DateTime(date.year, date.month, date.day, hs.first);
    final end = start.add(Duration(hours: hs.length));
    final lines = <(String, int)>[
      ('Sewa ${c.name} (${hs.length} jam × ${rupiah(c.price)})', courtFee),
      for (final e in qty.entries)
        if (e.value > 0 && _eq(e.key) != null) ('${_eq(e.key)!.name} ×${e.value}', e.value * _eq(e.key)!.price),
    ];
    Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentPage(Draft(
      title: 'Sewa Lapangan Privat',
      subtitle: '${c.name} • ${tanggalPendek(start)}, ${jam(start)} - ${jam(end)}',
      lines: lines,
      commit: (m, code) => store.bookPrivate(user, c, start, end, lines, code, m),
    ))));
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(5, (i) => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + i));
    final courts = store.courts.where((c) => type == 'Semua' || c.type == type).toList();
    final hs = hours.toList()..sort();
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) => Column(children: [
            pageHeader(context, 'MatchPoint'),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), children: [
                const Row(children: [Icon(Icons.circle, size: 7, color: C.green), SizedBox(width: 5), Text('PESAN LAPANGAN PRIVAT', style: TextStyle(fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w800, color: C.muted))]),
                const SizedBox(height: 8),
                card(
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('GOR Bulutangkis Bandung', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      SizedBox(height: 3),
                      Text('Jl. Jakarta No. 45, Coblong, Bandung', style: TextStyle(fontSize: 10, color: C.muted)),
                    ])),
                    const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Mulai dari', style: TextStyle(fontSize: 8, color: C.muted)),
                      Text('Rp60k/jam', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: C.green)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 14),
                const Text('PILIH TIPE LAPANGAN', style: TextStyle(fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w800, color: C.muted)),
                const SizedBox(height: 6),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                  for (final t in ['Semua', 'Karpet', 'Vinyl', 'Parquet']) _pill(t, type == t, () => setState(() => type = t)),
                ])),
                const SizedBox(height: 14),
                Row(children: [
                  const Text('PILIH TANGGAL', style: TextStyle(fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w800, color: C.muted)),
                  const Spacer(),
                  Text(bulanTahun(date), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  for (var i = 0; i < days.length; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() { date = days[i]; hours = {}; sel = null; }),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(color: sameDay(days[i], date) ? C.primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)),
                          child: Column(children: [
                            Text(i == 0 ? 'HARI INI' : hariSingkat(days[i]), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: sameDay(days[i], date) ? Colors.white70 : C.muted)),
                            const SizedBox(height: 2),
                            Text('${days[i].day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: sameDay(days[i], date) ? Colors.white : Colors.black)),
                          ]),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 14),
                for (final c in courts) Padding(padding: const EdgeInsets.only(bottom: 12), child: _court(c)),
                sectionTitle('Sewa Alat Tambahan'),
                for (final e in equip) Padding(padding: const EdgeInsets.only(bottom: 10), child: _equip(e)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.border))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Text(hs.isEmpty ? 'Belum ada jam dipilih' : '${sel!.name.replaceAll('Lapangan', 'Court')} (${hs.first.toString().padLeft(2, '0')}:00-${(hs.last + 1).toString().padLeft(2, '0')}:00)', style: const TextStyle(fontSize: 10, color: C.muted, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('${qty.values.fold(0, (a, b) => a + b)} Alat', style: const TextStyle(fontSize: 10, color: C.muted)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Total Pembayaran', style: TextStyle(fontSize: 9, color: C.muted)),
                    Text(rupiah(courtFee + equipFee), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ])),
                  ElevatedButton(
                    onPressed: _pay,
                    style: ElevatedButton.styleFrom(backgroundColor: C.lime, foregroundColor: C.primary, minimumSize: const Size(150, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('Lanjut Bayar →', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _pill(String t, bool on, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: on ? C.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
          child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: on ? Colors.white : Colors.black87)),
        ),
      );

  Widget _court(Court c) => card(
        radius: 18,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 11, backgroundColor: C.primary, child: Text('${c.no}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800))),
            const SizedBox(width: 8),
            Text('Court ${c.no}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const Spacer(),
            Text('${rupiah(c.price)}/jam', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.green)),
          ]),
          const SizedBox(height: 4),
          Text('${c.type} • ${feature[c.type] ?? 'Lapangan standar GOR'}', style: const TextStyle(fontSize: 10, color: C.muted)),
          const SizedBox(height: 10),
          if (c.status != CourtStatus.aman)
            Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)), child: Text(c.status == CourtStatus.maintenance ? 'Sedang maintenance — belum bisa dipesan' : 'Lapangan sedang ditutup / dipesan oleh admin', style: TextStyle(fontSize: 11, color: Color(0xFFB45309), fontWeight: FontWeight.w700)))
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.3,
              children: [for (final h in store.openHours) _slot(c, h)],
            ),
        ]),
      );

  Widget _slot(Court c, int h) {
    final slot = DateTime(date.year, date.month, date.day, h);
    final past = slot.add(const Duration(hours: 1)).isBefore(DateTime.now());
    final taken = store.slotTaken(c, slot);
    final on = sel?.no == c.no && hours.contains(h);
    final off = taken || past;
    return GestureDetector(
      onTap: off ? null : () => _tap(c, h),
      child: Container(
        decoration: BoxDecoration(
          color: on ? C.primary : off ? const Color(0xFFF1F1F4) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: on ? C.lime : C.border),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${h.toString().padLeft(2, '0')}:00', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: on ? Colors.white : off ? Colors.black38 : Colors.black87)),
          Text(on ? 'Dipilih' : taken ? 'Terisi' : past ? 'Lewat' : 'Tersedia', style: TextStyle(fontSize: 8, color: on ? C.lime : off ? Colors.black38 : C.green, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _equip(Equipment e) {
    final q = qty[e.id] ?? 0;
    Widget btn(IconData ic, VoidCallback f, bool fill) => GestureDetector(
          onTap: f,
          child: Container(width: 30, height: 30, decoration: BoxDecoration(color: fill ? C.primary : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.border)), child: Icon(ic, size: 16, color: fill ? Colors.white : Colors.black)),
        );
    final n = e.name.toLowerCase();
    return card(
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFEEECFF), borderRadius: BorderRadius.circular(12)), child: Icon(n.contains('sepatu') ? Icons.directions_run : n.contains('kok') ? Icons.sports : Icons.sports_tennis)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          Text(e.desc, style: const TextStyle(fontSize: 9, color: C.muted)),
          Text('+${rupiah(e.price)}/${e.unit} • stok ${e.stock}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.green)),
        ])),
        btn(Icons.remove, () => setState(() { if (q > 0) qty[e.id] = q - 1; }), false),
        SizedBox(width: 26, child: Center(child: Text('$q', style: const TextStyle(fontWeight: FontWeight.w800)))),
        btn(Icons.add, () {
          if (q >= e.stock) {
            soon(context, 'Stok ${e.name} hanya ${e.stock}');
          } else {
            setState(() => qty[e.id] = q + 1);
          }
        }, true),
      ]),
    );
  }
}
