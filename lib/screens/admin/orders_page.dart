// ============================================================
// FILE   : screens/admin/orders_page.dart
// FUNGSI : Pesanan masuk
//          Filter + terima / tolak / batalkan / akhiri lebih cepat.
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../data/app_store.dart';
import '../../data/models/booking.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/live_builder.dart';
import 'admin_widgets.dart';

// ======================= PESANAN MASUK / VERIFIKASI =======================
class AdminOrdersPage extends StatefulWidget {
  final String initial;
  const AdminOrdersPage({super.key, this.initial = 'Menunggu'});
  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late String f = widget.initial;

  bool _match(Booking b) {
    final now = DateTime.now();
    final active = b.status == BookingStatus.confirmed && !b.finished && b.end.add(const Duration(minutes: 30)).isAfter(now);
    switch (f) {
      case 'Menunggu':
        return b.status == BookingStatus.pending;
      case 'Aktif':
        return active;
      case 'Riwayat':
        return b.status != BookingStatus.pending && !active;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStore.I;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          pageHeader(context, 'Pesanan Masuk'),
          SizedBox(
            height: 40,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
              for (final t in ['Menunggu', 'Aktif', 'Riwayat', 'Semua'])
                GestureDetector(
                  onTap: () => setState(() => f = t),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: f == t ? C.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
                    child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: f == t ? Colors.white : Colors.black87)),
                  ),
                ),
            ]),
          ),
          Expanded(
            child: LiveBuilder((context) {
              final list = s.bookings.reversed.where(_match).toList();
              if (list.isEmpty) return const Center(child: Text('Tidak ada pesanan', style: TextStyle(color: C.muted, fontSize: 12)));
              return ListView(padding: const EdgeInsets.all(16), children: [for (final b in list) Padding(padding: const EdgeInsets.only(bottom: 10), child: orderCard(context, s, b))]);
            }),
          ),
        ]),
      ),
    );
  }
}
