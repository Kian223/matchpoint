// ============================================================
// FILE   : data/models/promo_banner.dart
// FUNGSI : Model banner promo
//          PromoBanner (gambar + teks, maks. 4).
// UBAH DI SINI UNTUK: —
// ============================================================

import 'dart:typed_data';

/// Banner promo di Home customer. Dikelola admin (maksimal 4 banner).
/// Bisa berupa gambar + teks, atau teks di atas warna gradasi.
class PromoBanner {
  String id, title, subtitle, code;
  int gradient; // indeks ke C.bannerGradients
  Uint8List? image; // gambar latar (opsional)
  bool active;

  PromoBanner({
    required this.id, required this.title, this.subtitle = '', this.code = '',
    this.gradient = 0, this.image, this.active = true,
  });

  /// Salinan untuk form edit (supaya batal edit tidak mengubah data asli).
  PromoBanner copy() => PromoBanner(id: id, title: title, subtitle: subtitle, code: code, gradient: gradient, image: image, active: active);
}
