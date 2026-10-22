// ============================================================
// FILE   : screens/customer/customer_home.dart
// FUNGSI : Beranda customer
//          Sapaan, banner, mode bermain, jadwal, fasilitas.
// UBAH DI SINI UNTUK: Ubah susunan Home customer.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/facility_icons.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/booking.dart';
import '../../data/models/user.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/user_avatar.dart';
import '../chat/chat_page.dart';
import 'mabar_list_page.dart';
import 'private_booking_page.dart';
import 'rating_page.dart';
import 'receipt_page.dart';
import 'room_chat_page.dart';

/// Beranda customer: sapaan, banner promo (geser), pilihan mode bermain, jadwal tanding,
/// fasilitas GOR, dan pintasan alat sewa / chat admin.
/// Semua data dibaca dari AppStore sehingga ikut berubah saat admin mengubah banner, fasilitas, atau status pesanan.
class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  void _go(BuildContext c, Widget p) => Navigator.push(c, MaterialPageRoute(builder: (_) => p));

  @override
  Widget build(BuildContext context) {
    final store = AppStore.I;
    final user = store.current!;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final mine = store.bookingsOf(user.email);
        return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), children: [
          const AppTopBar(),
          const SizedBox(height: 14),
          FadeSlideIn(child: _greeting(user, store)),
          const SizedBox(height: 14),
          const FadeSlideIn(delayMs: 100, child: BannerCarousel()),
          const SizedBox(height: 18),
          FadeSlideIn(delayMs: 180, child: sectionTitle('Pilih Mode Bermain')),
          FadeSlideIn(
            delayMs: 220,
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: _mode(icon: Icons.calendar_month_outlined, title: 'Sewa Privat', sub: 'Pilih lapangan & rental raket / shuttlecock.', cta: 'Pesan Slot', colors: const [Color(0xFF0B2E1F), Color(0xFF14B8A6)], dark: true, onTap: () => _go(context, const PrivateBookingPage()))),
                const SizedBox(width: 12),
                Expanded(child: _mode(icon: Icons.groups_outlined, title: 'Open Match', badge: 'Split Bill Otomatis', sub: 'Join spar mabar atau bikin sesi komunitas.', cta: 'Cari Lawan', colors: const [Color(0xFFB7F24B), Color(0xFFF59E0B)], dark: false, onTap: () => _go(context, const MabarListPage()))),
              ]),
            ),
          ),
          const SizedBox(height: 18),
          sectionTitle('Jadwal Tanding Berikutnya'),
          if (mine.isEmpty) _emptyJadwal() else for (final b in mine.take(3)) Padding(padding: const EdgeInsets.only(bottom: 10), child: _jadwal(context, store, b)),
          const SizedBox(height: 8),
          _facilities(store),
          const SizedBox(height: 16),
          _tile(Icons.sports_tennis, 'Sewa Alat Tambahan', 'Raket, sepatu, kok — langsung pilih saat booking', C.orange, () => _go(context, const PrivateBookingPage())),
          const SizedBox(height: 10),
          _tile(Icons.support_agent, 'Hubungi Admin GOR', 'CS Siaga: Reschedule & konfirmasi bayar', C.sky, () => _go(context, ChatPage(customerEmail: user.email)), online: true),
        ]);
      },
    );
  }

  // ---------- Sapaan ----------
  Widget _greeting(AppUser user, AppStore store) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: C.heroGradient, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: C.primary.withValues(alpha: .25), blurRadius: 16, offset: const Offset(0, 6))]),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.circle, size: 7, color: C.lime),
                SizedBox(width: 5),
                Text('SIAP BERTANDING', style: TextStyle(fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w800, color: C.lime)),
              ]),
              const SizedBox(height: 4),
              Text('Halo, ${user.name}!', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                chip('Level: ${user.level}', bg: C.lime, fg: C.primary, icon: Icons.emoji_events_outlined),
                chip(store.ratingCount == 0 ? 'GOR: belum ada ulasan' : 'GOR ★ ${store.avgRating.toStringAsFixed(1)} (${store.ratingCount})', bg: Colors.white24, fg: Colors.white),
              ]),
            ]),
          ),
          const SizedBox(width: 12),
          Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: C.lime, shape: BoxShape.circle), child: UserAvatar(user.name, email: user.email, r: 30)),
        ]),
      );

  // ---------- Mode bermain ----------
  Widget _mode({required IconData icon, required String title, String? badge, required String sub, required String cta, required List<Color> colors, required bool dark, required VoidCallback onTap}) {
    final fg = dark ? Colors.white : C.primary;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: colors.last.withValues(alpha: .35), blurRadius: 12, offset: const Offset(0, 5))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .22), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: fg)),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fg)),
          if (badge != null) ...[const SizedBox(height: 3), chip(badge, bg: Colors.white, fg: const Color(0xFF3F6212))],
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 10, color: fg.withValues(alpha: .8), height: 1.3)),
          const Spacer(),
          const SizedBox(height: 10),
          Row(children: [Text(cta, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg)), const SizedBox(width: 4), Icon(Icons.arrow_forward, size: 13, color: fg)]),
        ]),
      ),
    );
  }

  // ---------- Jadwal ----------
  Widget _emptyJadwal() => card(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        child: const Row(children: [
          Icon(Icons.event_busy_outlined, color: C.muted),
          SizedBox(width: 12),
          Expanded(child: Text('Belum ada jadwal. Pesan lapangan atau gabung mabar untuk mulai bermain!', style: TextStyle(fontSize: 12, color: C.muted))),
        ]),
      );

  Widget _jadwal(BuildContext context, AppStore store, Booking b) {
    final confirmed = b.status == BookingStatus.confirmed;
    final until = b.start.difference(DateTime.now());
    final ended = b.isEnded;
    final rated = store.hasRated(b);
    final room = b.roomId == null ? null : store.rooms.where((r) => r.id == b.roomId).firstOrNull;
    final tag = ended ? 'Selesai' : !confirmed ? 'Menunggu Verifikasi' : b.isLive ? 'Sedang Main' : until.inHours > 0 ? 'Sisa ${until.inHours} Jam' : 'Sisa ${until.inMinutes.clamp(0, 999)} Menit';
    return card(
      radius: 20,
      child: Column(children: [
        Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEEECFF), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.sports_tennis, size: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('GOR Bulutangkis Bandung', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('● ${b.court.name} • ${b.court.type} • ${b.title}', style: const TextStyle(fontSize: 10, color: C.muted)),
            ]),
          ),
          chip(tag, bg: ended ? const Color(0xFFF1F1F4) : confirmed ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7), fg: ended ? C.muted : confirmed ? C.red : const Color(0xFFB45309), icon: Icons.timer_outlined),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF1EFFC), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(tanggal(b.start), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                Text('${jam(b.start)} - ${jam(b.end)} WIB (${b.hours} Jam)', style: const TextStyle(fontSize: 11, color: C.muted)),
              ]),
            ),
            const Icon(Icons.location_on_outlined, size: 13, color: C.green),
            const Text('Coblong', style: TextStyle(fontSize: 10, color: C.green, fontWeight: FontWeight.w800)),
          ]),
        ),
        const SizedBox(height: 12),
        Row(children: [
          // Chat grup room (hanya untuk sesi mabar)
          if (room != null) ...[
            Expanded(child: OutlinedButton.icon(onPressed: () => _go(context, RoomChatPage(room)), style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), icon: const Icon(Icons.forum_outlined, size: 16), label: const Text('Chat Room', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)))),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: ended
                ? ElevatedButton.icon(
                    onPressed: rated ? null : () => _go(context, RatingPage(b)),
                    style: ElevatedButton.styleFrom(backgroundColor: C.amber, foregroundColor: Colors.black, disabledBackgroundColor: const Color(0xFFE5E7EB), minimumSize: const Size(0, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    icon: Icon(rated ? Icons.check_circle_outline : Icons.star_rounded, size: 18),
                    label: Text(rated ? 'Sudah Dinilai' : 'Beri Rating', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  )
                : ElevatedButton.icon(
                    onPressed: () => _go(context, ReceiptPage(b)),
                    style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, minimumSize: const Size(0, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    icon: const Icon(Icons.qr_code_2, size: 18),
                    label: Text(confirmed ? 'Lihat Tiket / QR Masuk' : 'Lihat Status Pesanan', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
          ),
        ]),
      ]),
    );
  }

  // ---------- Fasilitas ----------
  Widget _facilities(AppStore store) {
    if (store.facilities.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      sectionTitle('Fasilitas GOR'),
      SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: store.facilities.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final f = store.facilities[i];
            final color = C.accents[i % C.accents.length];
            return FadeSlideIn(
              delayMs: 60 * i,
              child: Container(
                width: 86,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: C.border)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CircleAvatar(radius: 18, backgroundColor: color.withValues(alpha: .15), child: Icon(facilityIcons[f.iconKey] ?? Icons.apartment, size: 20, color: color)),
                  const SizedBox(height: 6),
                  Text(f.name, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, height: 1.2)),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // ---------- Pintasan ----------
  Widget _tile(IconData i, String t, String s, Color accent, VoidCallback f, {bool online = false}) => Pressable(
        onTap: f,
        child: card(
          radius: 16,
          child: Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: accent.withValues(alpha: .15), borderRadius: BorderRadius.circular(12)), child: Icon(i, size: 20, color: accent)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  if (online) ...[const SizedBox(width: 6), const Icon(Icons.circle, size: 7, color: C.green)],
                ]),
                Text(s, style: const TextStyle(fontSize: 10, color: C.muted)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: C.muted),
          ]),
        ),
      );
}
