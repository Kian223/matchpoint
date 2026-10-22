// ============================================================
// FILE   : screens/customer/rating_page.dart
// FUNGSI : Beri rating
//          Bintang + komentar setelah sesi selesai.
// UBAH DI SINI UNTUK: Ubah form rating.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/feedback_service.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/booking.dart';
import '../../widgets/animations.dart';
import '../../widgets/common_widgets.dart';

/// Memberi rating setelah sesi selesai.
/// Sewa privat -> menilai lapangan/GOR. Mabar -> menilai room (host). Hasilnya masuk ke store.ratings
/// dan terlihat admin di menu "Ulasan".
class RatingPage extends StatefulWidget {
  final Booking booking;
  const RatingPage(this.booking, {super.key});
  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final store = AppStore.I;
  final _comment = TextEditingController();
  final _tags = <String>{};
  int _stars = 0;

  bool get _isRoom => widget.booking.type == BookingType.mabar;
  static const _labels = ['Ketuk bintang untuk menilai', 'Kurang puas', 'Cukup', 'Bagus', 'Sangat bagus', 'Luar biasa!'];

  void _submit() {
    final text = [if (_tags.isNotEmpty) _tags.join(', '), if (_comment.text.trim().isNotEmpty) _comment.text.trim()].join(' • ');
    store.addRating(widget.booking, _stars, text);
    Navigator.pop(context);
    soon(context, 'Terima kasih atas ratingmu!');
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final tagOptions = _isRoom ? ['Host seru', 'Partner seimbang', 'Patungan transparan', 'Tepat waktu'] : ['Lapangan bersih', 'Pelayanan ramah', 'Lampu terang', 'Alat sewa bagus'];
    final target = _isRoom ? (b.roomTitle.isEmpty ? 'Room Mabar' : b.roomTitle) : '${b.court.name} • GOR Bulutangkis Bandung';
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          pageHeader(context, 'Beri Rating'),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              FadeSlideIn(
                child: card(
                  radius: 22,
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    chip(_isRoom ? 'Sesi Mabar' : 'Sewa Privat', bg: const Color(0xFFEFFBD6), fg: const Color(0xFF3F6212)),
                    const SizedBox(height: 10),
                    Text(target, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('${tanggalPendek(b.start)} • ${jam(b.start)} - ${jam(b.end)}', style: const TextStyle(fontSize: 11, color: C.muted)),
                    const SizedBox(height: 18),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      for (var i = 1; i <= 5; i++)
                        GestureDetector(
                          onTap: () {
                            FeedbackService.tap();
                            setState(() => _stars = i);
                          },
                          child: AnimatedScale(
                            scale: i <= _stars ? 1.15 : 1,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
                            child: Icon(i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded, size: 44, color: i <= _stars ? C.amber : const Color(0xFFD1D5DB)),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: Text(_labels[_stars], key: ValueKey(_stars), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: C.muted))),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delayMs: 120,
                child: card(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Apa yang kamu suka?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final t in tagOptions)
                        GestureDetector(
                          onTap: () => setState(() => _tags.contains(t) ? _tags.remove(t) : _tags.add(t)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: _tags.contains(t) ? C.primary : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
                            child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _tags.contains(t) ? Colors.white : Colors.black87)),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _comment,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(hintText: 'Tulis ulasan singkat (opsional)', hintStyle: const TextStyle(fontSize: 12), filled: true, fillColor: const Color(0xFFEEECFF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _stars == 0 ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, disabledBackgroundColor: const Color(0xFFD1D5DB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Kirim Rating', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
