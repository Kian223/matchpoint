// ============================================================
// FILE   : widgets/banner_carousel.dart
// FUNGSI : Banner promo geser
//          BannerCard dan BannerCarousel (auto-slide 4 detik).
// UBAH DI SINI UNTUK: Ubah tampilan / kecepatan geser banner.
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/app_store.dart';
import '../data/models/promo_banner.dart';
import 'common_widgets.dart';

/// Banner promo di Home customer: bisa digeser (maks. 4) dan berpindah otomatis tiap 4 detik.
/// Isi banner dikelola admin di menu "Banner Promo".

/// Satu kartu banner. Dipakai juga sebagai pratinjau di halaman admin.
class BannerCard extends StatelessWidget {
  final PromoBanner b;
  final VoidCallback? onClaim;
  const BannerCard(this.b, {super.key, this.onClaim});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 172,
        decoration: BoxDecoration(gradient: C.bannerGradients[b.gradient % C.bannerGradients.length]),
        child: Stack(children: [
          if (b.image != null) ...[
            Positioned.fill(child: Image.memory(b.image!, fit: BoxFit.cover)),
            const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xDD000000), Color(0x33000000)])))),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              chip('PROMO', bg: C.lime, fg: C.primary, icon: Icons.local_offer_outlined),
              const SizedBox(height: 8),
              Text(b.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, height: 1.15)),
              const SizedBox(height: 4),
              Text(b.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const Spacer(),
              Row(children: [
                if (b.code.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
                    child: Text('KODE: ${b.code}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                const Spacer(),
                if (onClaim != null)
                  ElevatedButton(
                    onPressed: onClaim,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Klaim', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});
  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _pc = PageController(viewportFraction: .94);
  int _i = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    // Geser otomatis ke banner berikutnya tiap 4 detik
    _t = Timer.periodic(const Duration(seconds: 4), (_) {
      final n = AppStore.I.activeBanners.length;
      if (n < 2 || !_pc.hasClients) return;
      _pc.animateToPage((_i + 1) % n, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.I,
      builder: (context, _) {
        final list = AppStore.I.activeBanners;
        if (list.isEmpty) return const SizedBox.shrink();
        if (_i >= list.length) _i = 0;
        return Column(children: [
          SizedBox(
            height: 172,
            child: PageView.builder(
              controller: _pc,
              itemCount: list.length,
              onPageChanged: (i) => setState(() => _i = i),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: BannerCard(list[i], onClaim: () => soon(context, 'Kode ${list[i].code} berhasil diklaim')),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < list.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _i ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(color: i == _i ? C.primary : const Color(0xFFCFCBEA), borderRadius: BorderRadius.circular(4)),
              ),
          ]),
        ]);
      },
    );
  }
}
