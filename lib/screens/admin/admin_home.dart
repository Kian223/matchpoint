// ============================================================
// FILE   : screens/admin/admin_home.dart
// FUNGSI : Dashboard admin
//          Statistik, status lapangan realtime, menu operasional, verifikasi cepat.
// UBAH DI SINI UNTUK: Ubah susunan dashboard.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/court.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/live_builder.dart';
import 'admin_widgets.dart';
import 'cash_page.dart';
import 'manage_banner_page.dart';
import 'manage_venue_page.dart';
import 'monitor_timer_page.dart';
import 'orders_page.dart';
import 'reviews_page.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  void _go(BuildContext c, Widget p) => Navigator.push(c, MaterialPageRoute(builder: (_) => p));

  @override
  Widget build(BuildContext context) {
    final store = AppStore.I;
    final admin = store.current!;
    return LiveBuilder((context) {
      final pending = store.pending;
      final n = store.courts.length;
      return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 20), children: [
        const AppTopBar(),
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerLeft, child: chip('ADMIN-GOR BANDUNG', bg: const Color(0xFFE3EEFF), fg: const Color(0xFF1E5BB8))),
        const SizedBox(height: 10),
        card(
          child: Row(children: [
            const CircleAvatar(radius: 24, backgroundColor: Color(0xFFF2C9A0), child: Icon(Icons.person, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(admin.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text(admin.title, style: const TextStyle(fontSize: 10, color: C.muted)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Hari Ini', style: TextStyle(fontSize: 9, color: C.muted)),
              Text(tanggalPendek(DateTime.now()), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: card(
              gradient: const LinearGradient(colors: [Color(0xFF0B2E1F), Color(0xFF1F4F34)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('PENDAPATAN HARI INI', style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .5)),
                const SizedBox(height: 8),
                Text(rupiah(store.incomeToday), style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(store.incomeToday == 0 ? 'Belum ada transaksi' : '↗ dari ${store.confirmedToday.length} booking lunas', style: const TextStyle(color: C.lime, fontSize: 9, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          const SizedBox(width: 12),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _mini('PESANAN MASUK', '${pending.length} Menunggu', pending.isEmpty ? 'Tidak ada antrean' : 'Butuh verifikasi bukti bayar', pending.isEmpty ? C.muted : C.red)),
          const SizedBox(width: 12),
          Expanded(child: _mini('TOTAL JAM', '${store.hoursToday} Jam', 'Dari ${store.sessionsToday.length} sesi terjadwal', C.muted)),
        ]),
        const SizedBox(height: 14),
        alertBanners(context, store),
        Row(children: [
          Expanded(child: Text('Status Fisik $n Lapangan', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))),
          const Icon(Icons.circle, size: 7, color: C.green),
          const SizedBox(width: 4),
          const Text('Dasar Realtime', style: TextStyle(fontSize: 9, color: C.green, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [for (final c in store.courts) _court(context, store, c)],
        ),
        const SizedBox(height: 18),
        const Text('Menu Operasional', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.9,
          children: [
            _menu(Icons.timer_outlined, 'Monitor Timer', 'Alarm habis sewa', C.orange, () => _go(context, const MonitorTimerPage())),
            _menu(Icons.storefront_outlined, 'Kelola Venue', 'Lapangan, alat, jam, fasilitas', C.teal, () => _go(context, const ManageVenuePage())),
            _menu(Icons.fact_check_outlined, 'Verifikasi Bayar', '${pending.length} Menunggu', C.violet, () => _go(context, const AdminOrdersPage())),
            _menu(Icons.point_of_sale, 'Kas & Rental', 'Pendapatan & riwayat', C.sky, () => _go(context, const CashPage())),
            _menu(Icons.campaign_outlined, 'Banner Promo', '${store.banners.length}/${AppStore.maxBanners} banner', C.pink, () => _go(context, const ManageBannerPage())),
            _menu(Icons.star_rate_rounded, 'Ulasan', '${store.ratingCount} rating', C.amber, () => _go(context, const ReviewsPage())),
          ],
        ),
        const SizedBox(height: 18),
        Row(children: [
          const Text('Verifikasi Cepat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          if (pending.isNotEmpty) CircleAvatar(radius: 8, backgroundColor: C.red, child: Text('${pending.length}', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800))),
          const Spacer(),
          GestureDetector(onTap: () => _go(context, const AdminOrdersPage(initial: 'Semua')), child: const Text('Semua Pesanan', style: TextStyle(fontSize: 10, color: C.green, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 10),
        if (pending.isEmpty)
          card(child: const Row(children: [Icon(Icons.inbox_outlined, color: C.muted), SizedBox(width: 12), Expanded(child: Text('Belum ada pesanan masuk dari customer.', style: TextStyle(fontSize: 12, color: C.muted)))]))
        else
          for (final b in pending) Padding(padding: const EdgeInsets.only(bottom: 10), child: orderCard(context, store, b)),
      ]);
    });
  }

  Widget _mini(String l, String v, String s, Color sc) => card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: const TextStyle(color: C.muted, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .5)),
          const SizedBox(height: 6),
          Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(s, style: TextStyle(color: sc, fontSize: 9, fontWeight: FontWeight.w700)),
        ]),
      );

  Widget _court(BuildContext context, AppStore store, Court c) {
    final i = courtInfo(store, c);
    final hot = i.tag == 'Live' || i.tag == 'Segera Habis' || i.tag == 'Waktu Habis';
    return GestureDetector(
      onTap: () => courtSheet(context, store, c),
      child: card(
        radius: 16,
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Lap. ${c.no < 10 ? '0${c.no}' : c.no} (${c.type})', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
            chip(i.tag, bg: i.bg, fg: i.fg),
          ]),
          const Spacer(),
          Text(i.big, style: TextStyle(fontSize: hot ? 18 : 15, fontWeight: FontWeight.w800, color: hot ? i.fg : Colors.black87)),
          const SizedBox(height: 2),
          Text(i.sub, style: const TextStyle(fontSize: 9, color: C.muted), overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  Widget _menu(IconData i, String t, String s, Color accent, VoidCallback f) => Pressable(
        onTap: f,
        child: card(
          radius: 16,
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: accent.withValues(alpha: .15), borderRadius: BorderRadius.circular(10)), child: Icon(i, size: 18, color: accent)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                Text(s, style: const TextStyle(fontSize: 9, color: C.muted)),
              ]),
            ),
          ]),
        ),
      );
}
