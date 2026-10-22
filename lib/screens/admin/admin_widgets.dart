// ============================================================
// FILE   : screens/admin/admin_widgets.dart
// FUNGSI : Widget bersama admin
//          Status lapangan (courtInfo), kartu pesanan, banner peringatan.
// UBAH DI SINI UNTUK: Ubah warna / teks status lapangan.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/booking.dart';
import '../../data/models/court.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/live_builder.dart';
import '../../core/feedback_service.dart';

const _blueBg = Color(0xFFE3EEFF), _blueFg = Color(0xFF1E5BB8);

const _amberBg = Color(0xFFFEF3C7), _amberFg = Color(0xFFB45309);

const _greenBg = Color(0xFFDCFCE7), _redBg = Color(0xFFFEE2E2);

const _violBg = Color(0xFFEDE9FE), _violFg = Color(0xFF6D28D9);

const _greyBg = Color(0xFFF1F1F4);

// ======================= STATUS LAPANGAN =======================
class CourtInfo {
  final String tag, big, sub;
  final Color bg, fg;
  final Booking? session;
  const CourtInfo(this.tag, this.big, this.sub, this.bg, this.fg, [this.session]);
}

CourtInfo courtInfo(AppStore s, Court c) {
  final now = DateTime.now();
  if (c.status == CourtStatus.maintenance) return const CourtInfo('Maintenance', 'Perbaikan', 'Rusak / sedang perawatan', _amberBg, _amberFg);
  final live = s.liveOn(c);
  if (live != null) {
    final left = live.end.difference(now);
    final warn = left <= const Duration(minutes: 5);
    return CourtInfo(warn ? 'Segera Habis' : 'Live', countdown(left), live.customerName, warn ? _amberBg : _greenBg, warn ? _amberFg : C.green, live);
  }
  final over = s.overdueOn(c);
  if (over != null) return CourtInfo('Waktu Habis', '+${countdown(now.difference(over.end))}', over.customerName, _redBg, C.red, over);
  final next = s.nextOn(c);
  if (next != null) {
    return CourtInfo('Dipesan', '${jam(next.start)} - ${jam(next.end)}', '${next.customerName}${next.status == BookingStatus.pending ? ' • menunggu verifikasi' : ''}', _violBg, _violFg, next);
  }
  if (c.status == CourtStatus.dipesan) return const CourtInfo('Dipesan', 'Ditutup', 'Dipesan manual oleh admin', _violBg, _violFg);
  return const CourtInfo('Siap', 'Kosong', 'Siap digunakan', _blueBg, _blueFg);
}

Future<bool> confirmBox(BuildContext context, String title, String msg, {String ok = 'Ya'}) async =>
    await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(d, true), child: Text(ok)),
        ],
      ),
    ) ??
    false;

Widget statusChips(AppStore s, Court c) => Wrap(spacing: 8, runSpacing: 8, children: [
      for (final (st, label) in [(CourtStatus.aman, 'Aman'), (CourtStatus.maintenance, 'Maintenance (Rusak)'), (CourtStatus.dipesan, 'Sudah Dipesan')])
        GestureDetector(
          onTap: () => s.setCourtStatus(c, st),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: c.status == st ? C.primary : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
            child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.status == st ? Colors.white : Colors.black87)),
          ),
        ),
    ]);

void courtSheet(BuildContext context, AppStore s, Court c) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (sheet) => LiveBuilder((_) {
      final i = courtInfo(s, c);
      final ses = i.session;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('${c.name} • ${c.type}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Spacer(),
            chip(i.tag, bg: i.bg, fg: i.fg),
          ]),
          const SizedBox(height: 6),
          Text('${i.big} • ${i.sub}', style: const TextStyle(fontSize: 12, color: C.muted)),
          const SizedBox(height: 14),
          const Text('Ubah Status Fisik', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          statusChips(s, c),
          if (ses != null && ses.status == BookingStatus.confirmed && (ses.isLive || ses.isOverdue)) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  if (await confirmBox(context, 'Akhiri sesi lebih cepat?', '${c.name} milik ${ses.customerName} akan dinyatakan selesai sekarang.', ok: 'Akhiri')) {
                    s.endEarly(ses);
                    if (sheet.mounted) Navigator.pop(sheet);
                  }
                },
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Akhiri Sesi Lebih Cepat'),
              ),
            ),
          ],
        ]),
      );
    }),
  );
}

// ======================= KARTU PESANAN =======================
String orderState(Booking b) {
  if (b.status == BookingStatus.rejected) return 'Ditolak';
  if (b.status == BookingStatus.cancelled) return 'Dibatalkan';
  if (b.status == BookingStatus.pending) return 'Menunggu';
  if (b.finished) return 'Selesai';
  if (b.isLive) return 'Berjalan';
  if (b.isOverdue) return 'Waktu Habis';
  return b.start.isAfter(DateTime.now()) ? 'Terjadwal' : 'Selesai';
}

Widget orderCard(BuildContext context, AppStore s, Booking b) {
  final st = orderState(b);
  final colors = <String, (Color, Color)>{
    'Menunggu': (_amberBg, _amberFg),
    'Terjadwal': (_blueBg, _blueFg),
    'Berjalan': (_greenBg, C.green),
    'Waktu Habis': (_redBg, C.red),
    'Ditolak': (_redBg, C.red),
  };
  final (bg, fg) = colors[st] ?? (_greyBg, C.muted);
  Widget? action;
  if (b.status == BookingStatus.pending) {
    action = Row(children: [
      Expanded(flex: 2, child: OutlinedButton.icon(onPressed: () => s.setStatus(b, BookingStatus.rejected), style: OutlinedButton.styleFrom(foregroundColor: C.red, minimumSize: const Size(0, 42), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), icon: const Icon(Icons.close, size: 16), label: const Text('Tolak', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)))),
      const SizedBox(width: 10),
      Expanded(flex: 3, child: ElevatedButton.icon(onPressed: () => s.setStatus(b, BookingStatus.confirmed), style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, minimumSize: const Size(0, 42), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), icon: const Icon(Icons.check_circle_outline, size: 16), label: const Text('Terima Pesanan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)))),
    ]);
  } else if (b.status == BookingStatus.confirmed && !b.finished && (b.isLive || b.isOverdue)) {
    action = SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          if (await confirmBox(context, 'Akhiri sesi lebih cepat?', '${b.court.name} milik ${b.customerName} akan dinyatakan selesai sekarang.', ok: 'Akhiri')) s.endEarly(b);
        },
        icon: const Icon(Icons.stop_circle_outlined, size: 16),
        label: const Text('Akhiri Lebih Cepat', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ),
    );
  } else if (b.status == BookingStatus.confirmed && !b.finished && b.start.isAfter(DateTime.now())) {
    action = SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(foregroundColor: C.red),
        onPressed: () async {
          if (await confirmBox(context, 'Batalkan pesanan?', 'Pesanan ${b.id} milik ${b.customerName} akan dibatalkan dan customer diberi tahu.', ok: 'Batalkan')) s.cancelBooking(b);
        },
        icon: const Icon(Icons.cancel_outlined, size: 16),
        label: const Text('Batalkan Pesanan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      ),
    );
  }
  return card(
    radius: 18,
    child: Column(children: [
      Row(children: [
        const CircleAvatar(radius: 18, backgroundColor: Color(0xFFF2C9A0), child: Icon(Icons.person, size: 18, color: Colors.white)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(b.customerName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
              const SizedBox(width: 6),
              chip(b.id, bg: const Color(0xFFEEECFF), fg: C.muted),
            ]),
            Text('${b.title} • ${b.court.name}', style: const TextStyle(fontSize: 10, color: C.muted)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(rupiah(b.price), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          Text(b.method, style: const TextStyle(fontSize: 9, color: C.muted)),
        ]),
      ]),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF1EFFC), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 14),
          const SizedBox(width: 8),
          Expanded(child: Text('${tanggalPendek(b.start)}, ${jam(b.start)} - ${jam(b.end)} WIB', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
          chip(st, bg: bg, fg: fg),
        ]),
      ),
      if (action != null) ...[const SizedBox(height: 10), action],
    ]),
  );
}

/// Banner peringatan: sisa <= 5 menit (oranye) atau waktu sudah habis (merah).
Widget alertBanners(BuildContext context, AppStore s) {
  final now = DateTime.now();
  final out = <Widget>[];
  for (final b in s.bookings) {
    if (b.status != BookingStatus.confirmed || b.isShare || b.finished) continue;
    final left = b.end.difference(now);
    final warn = b.isLive && left <= const Duration(minutes: 5);
    if (!warn && !b.isOverdue) continue;
    final over = b.isOverdue;
    out.add(Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: over ? _redBg : _amberBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: over ? C.red : _amberFg)),
      child: Row(children: [
        Icon(over ? Icons.alarm_off : Icons.alarm, color: over ? C.red : _amberFg),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${b.court.name} • ${b.customerName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          Text(over ? 'Waktu habis +${countdown(now.difference(b.end))} — segera cek lapangan' : 'Sisa ${countdown(left)} — siapkan pergantian sesi', style: const TextStyle(fontSize: 10)),
        ])),
        // --- TAMBAHAN TOMBOL MATIKAN ALARM ---
        IconButton(
          icon: const Icon(Icons.volume_off, size: 20),
          color: over ? C.red : _amberFg,
          onPressed: () => FeedbackService.stopAlarm(),
          tooltip: 'Matikan Suara Alarm',
        ),
        TextButton(
          onPressed: () async {
            if (await confirmBox(context, 'Akhiri sesi?', '${b.court.name} milik ${b.customerName} akan dinyatakan selesai.', ok: 'Akhiri')) {
              s.endEarly(b);
              FeedbackService.stopAlarm(); // Otomatis matikan alarm saat sesi diakhiri
            }
          },
          child: const Text('Akhiri', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ]),
    ));
  }
  return Column(children: out);
}
