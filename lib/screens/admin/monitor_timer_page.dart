// ============================================================
// FILE   : screens/admin/monitor_timer_page.dart
// FUNGSI : Monitor timer
//          Countdown semua lapangan + antrean hari ini.
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/booking.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/live_builder.dart';
import 'admin_widgets.dart';

// ======================= MONITOR TIMER =======================
class MonitorTimerPage extends StatelessWidget {
  const MonitorTimerPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppStore.I;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          pageHeader(context, 'Monitor Timer'),
          Expanded(
            child: LiveBuilder((context) {
              final now = DateTime.now();
              final queue = s.bookings.where((b) => !b.isShare && (b.status == BookingStatus.pending || b.status == BookingStatus.confirmed) && !b.finished && b.end.isAfter(now) && sameDay(b.start, now)).toList()
                ..sort((a, b) => a.start.compareTo(b.start));
              return ListView(padding: const EdgeInsets.all(16), children: [
                card(
                  color: const Color(0xFFEFFBD6),
                  child: const Row(children: [
                    Icon(Icons.alarm_on, color: C.green),
                    SizedBox(width: 10),
                    Expanded(child: Text('Alarm otomatis aktif: peringatan 5 menit sebelum dan 5 menit sesudah waktu sewa habis.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                  ]),
                ),
                const SizedBox(height: 10),
                // ---- MODE UJI: buat sesi dengan sisa waktu tertentu agar alarm bisa dites cepat ----
                card(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Mode Uji (demo)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    const Text('Buat sesi di lapangan kosong untuk mengetes countdown & alarm tanpa menunggu.', style: TextStyle(fontSize: 10, color: C.muted)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final t in [
                        ('Sisa 5 dtk', const Duration(seconds: 5)),
                        ('Lewat 4 mnt 50 dtk', const Duration(minutes: -4, seconds: -50))
                      ])
                        OutlinedButton(
                          onPressed: () {
                            final err = s.createTestSession(t.$2);
                            if (err != null) soon(context, err);
                          },
                          child: Text(t.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                    ]),
                  ]),
                ),
                const SizedBox(height: 12),
                alertBanners(context, s),
                for (final c in s.courts)
                  Builder(builder: (_) {
                    final i = courtInfo(s, c);
                    final ses = i.session;
                    final running = ses != null && ses.status == BookingStatus.confirmed && (ses.isLive || ses.isOverdue);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => courtSheet(context, s, c),
                        child: card(
                          child: Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${c.name} • ${c.type}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(i.big, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: i.tag == 'Live' || i.tag == 'Segera Habis' || i.tag == 'Waktu Habis' ? i.fg : Colors.black87)),
                              Text(i.sub, style: const TextStyle(fontSize: 10, color: C.muted)),
                            ])),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              chip(i.tag, bg: i.bg, fg: i.fg),
                              if (running)
                                TextButton(
                                  onPressed: () async {
                                    if (await confirmBox(context, 'Akhiri sesi?', '${c.name} milik ${ses.customerName} akan dinyatakan selesai.', ok: 'Akhiri')) s.endEarly(ses);
                                  },
                                  child: const Text('Akhiri Sesi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                ),
                            ]),
                          ]),
                        ),
                      ),
                    );
                  }),
                sectionTitle('Antrean Hari Ini'),
                if (queue.isEmpty) const Text('Belum ada antrean pesanan hari ini.', style: TextStyle(fontSize: 11, color: C.muted)),
                for (final b in queue) Padding(padding: const EdgeInsets.only(bottom: 10), child: orderCard(context, s, b)),
              ]);
            }),
          ),
        ]),
      ),
    );
  }
}