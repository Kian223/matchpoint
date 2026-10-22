// ============================================================
// FILE   : screens/customer/receipt_page.dart
// FUNGSI : Bukti booking
//          E-tiket QR, rincian biaya, status verifikasi.
// UBAH DI SINI UNTUK: Ubah tampilan tiket.
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/booking.dart';
import '../../widgets/common_widgets.dart';
import '../chat/chat_page.dart';

/// Bukti ringkasan booking + tiket QR. Status ikut berubah saat admin memverifikasi.
class ReceiptPage extends StatelessWidget {
  final Booking b;
  const ReceiptPage(this.b, {super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.I;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final ok = b.status == BookingStatus.confirmed;
        final no = b.dead;
        final phone = store.users.where((u) => u.email == b.customerEmail).map((u) => u.phone).firstOrNull ?? '-';
        final (tag, tagBg, tagFg) = ok
            ? ('Pembayaran Terverifikasi & Lunas', const Color(0xFFDCFCE7), C.green)
            : no
                ? (b.status == BookingStatus.cancelled ? 'Pesanan Dibatalkan' : 'Pesanan Ditolak', const Color(0xFFFEE2E2), C.red)
                : ('Menunggu Verifikasi Admin', const Color(0xFFFEF3C7), const Color(0xFFB45309));
        return Scaffold(
          body: SafeArea(
            child: Column(children: [
              pageHeader(context, 'Pembayaran'),
              Expanded(
                child: ListView(padding: const EdgeInsets.all(16), children: [
                  Center(child: chip(tag, bg: tagBg, fg: tagFg)),
                  const SizedBox(height: 10),
                  Center(child: Text(ok ? 'Booking Siap Digunakan!' : no ? 'Booking Dibatalkan' : 'Booking Diterima!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
                  const SizedBox(height: 4),
                  Center(child: Text(ok ? 'Tunjukkan e-tiket ini ke petugas GOR Bulutangkis Bandung saat tiba di lokasi.' : no ? 'Hubungi petugas GOR untuk info lebih lanjut.' : 'Admin sedang memeriksa pembayaranmu. Tiket aktif setelah disetujui.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: C.muted))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('KODE BOOKING  ', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700)),
                      Text(b.kode, style: const TextStyle(color: C.lime, fontWeight: FontWeight.w800, fontSize: 13)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  card(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        chip(b.type == BookingType.mabar ? 'Open Match' : 'Privat', bg: const Color(0xFFEFFBD6), fg: const Color(0xFF3F6212)),
                        const SizedBox(width: 6),
                        chip('Non-Smoking', bg: const Color(0xFFEEECFF), fg: C.muted),
                      ]),
                      const SizedBox(height: 8),
                      const Text('GOR Bulutangkis Bandung', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                      const Text('Jl. Jakarta No. 45, Bandung', style: TextStyle(fontSize: 10, color: C.muted)),
                      const Divider(height: 20),
                      Row(children: [
                        Expanded(child: _info('LAPANGAN', b.court.name, '${b.court.type} Pro BWF Standard')),
                        Expanded(child: _info('JADWAL MAIN', tanggal(b.start), '${jam(b.start)} - ${jam(b.end)} WIB')),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  card(
                    child: Column(children: [
                      const Text('SCAN DATA PASS MASUK', style: TextStyle(fontSize: 9, letterSpacing: 1, color: C.muted, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      SizedBox(width: 160, height: 160, child: CustomPaint(painter: _QrPainter(b.id.hashCode, ok))),
                      const SizedBox(height: 8),
                      Text('TICKET ID: ${b.id}-${b.court.no}${b.start.day}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                      Text(ok ? 'Validitas: ${tanggalPendek(b.start)}, ${jam(b.start)} - ${jam(b.end)}' : 'QR aktif setelah admin menyetujui pesanan', style: const TextStyle(fontSize: 9, color: C.muted)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  card(child: Row(children: [
                    Expanded(child: _info('PEMESAN', b.customerName, b.title)),
                    Expanded(child: _info('KONTAK', phone, b.method)),
                  ])),
                  const SizedBox(height: 12),
                  card(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Rincian Pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      for (final l in b.lines) summaryRow(l.$1, rupiah(l.$2)),
                      summaryRow('Kode Unik Verifikasi', '+${b.code}', c: C.green),
                      const Divider(height: 18),
                      summaryRow('TOTAL DITRANSFER', rupiah(b.total), bold: true),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  card(
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Ketentuan Bermain GOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      SizedBox(height: 6),
                      Text('• Wajib sepatu non-marking.\n• Hadir 10 menit sebelum jadwal.\n• Shuttlecock & perlengkapan tidak dibawa pulang tanpa izin petugas.', style: TextStyle(fontSize: 10, color: C.muted, height: 1.5)),
                    ]),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(customerEmail: b.customerEmail))), icon: const Icon(Icons.chat_bubble_outline, size: 16), label: const Text('Chat Petugas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white),
                    onPressed: () {
                      final m = ScaffoldMessenger.of(context);
                      final fresh = b.status == BookingStatus.pending;
                      Navigator.of(context).popUntil((r) => r.isFirst);
                      if (fresh) m.showSnackBar(const SnackBar(duration: Duration(seconds: 4), content: Text('Terima kasih telah melakukan penyewaan lapangan di GOR Bandung. Untuk informasi lebih lanjut, dapat dilihat di menu Home.')));
                    },
                    icon: const Icon(Icons.home_outlined, size: 16),
                    label: const Text('Menu Utama', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  )),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _info(String l, String v, String s) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l, style: const TextStyle(fontSize: 8, color: C.muted, fontWeight: FontWeight.w800, letterSpacing: .5)),
        const SizedBox(height: 3),
        Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        Text(s, style: const TextStyle(fontSize: 9, color: C.muted)),
      ]);
}

class _QrPainter extends CustomPainter {
  final int seed;
  final bool active;
  _QrPainter(this.seed, this.active);
  @override
  void paint(Canvas canvas, Size size) {
    const n = 25;
    final cell = size.width / n;
    final p = Paint()..color = active ? Colors.black : Colors.black26;
    final r = Random(seed);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        final tl = x < 7 && y < 7, tr = x >= n - 7 && y < 7, bl = x < 7 && y >= n - 7;
        bool on;
        if (tl || tr || bl) {
          final lx = tr ? x - (n - 7) : x, ly = bl ? y - (n - 7) : y;
          on = lx == 0 || lx == 6 || ly == 0 || ly == 6 || (lx >= 2 && lx <= 4 && ly >= 2 && ly <= 4);
        } else {
          on = r.nextBool();
        }
        if (on) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), p);
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter o) => o.active != active;
}
