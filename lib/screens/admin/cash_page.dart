// ============================================================
// FILE   : screens/admin/cash_page.dart
// FUNGSI : Kas & rental
//          Pendapatan hari ini + riwayat transaksi.
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/booking.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/live_builder.dart';

// ======================= KAS & RENTAL =======================
class CashPage extends StatelessWidget {
  const CashPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppStore.I;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          pageHeader(context, 'Kas & Rental'),
          Expanded(
            child: LiveBuilder((context) {
              final today = s.confirmedToday;
              final equip = today.fold(0, (a, b) => a + b.equipTotal);
              final history = s.bookings.where((b) => b.status == BookingStatus.confirmed).toList().reversed.toList();
              return ListView(padding: const EdgeInsets.all(16), children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF0B2E1F), Color(0xFF1F4F34)])),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('PENDAPATAN HARI INI (LUNAS)', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .5)),
                    const SizedBox(height: 6),
                    Text(rupiah(s.incomeToday), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('${today.length} transaksi • ${s.hoursToday} jam tersewa', style: const TextStyle(color: C.lime, fontSize: 10, fontWeight: FontWeight.w700)),
                  ]),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('SEWA LAPANGAN', style: TextStyle(fontSize: 8, color: C.muted, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(rupiah(s.incomeToday - equip), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))]))),
                  const SizedBox(width: 12),
                  Expanded(child: card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('SEWA ALAT', style: TextStyle(fontSize: 8, color: C.muted, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(rupiah(equip), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))]))),
                ]),
                const SizedBox(height: 16),
                sectionTitle('Riwayat Transaksi'),
                if (history.isEmpty) const Text('Belum ada transaksi lunas.', style: TextStyle(fontSize: 11, color: C.muted)),
                for (final b in history)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: card(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${b.title} • ${b.court.name}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          Text('${b.customerName} • ${tanggalPendek(b.start)} ${jam(b.start)}', style: const TextStyle(fontSize: 10, color: C.muted)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(rupiah(b.price), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: C.green)),
                          Text(b.method, style: const TextStyle(fontSize: 9, color: C.muted)),
                        ]),
                      ]),
                    ),
                  ),
              ]);
            }),
          ),
        ]),
      ),
    );
  }
}
