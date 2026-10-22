// ============================================================
// FILE   : screens/admin/manage_banner_page.dart
// FUNGSI : Kelola banner promo
//          Tambah / edit / hapus banner (maks. 4, gambar + teks).
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_colors.dart';
import '../../data/app_store.dart';
import '../../data/models/promo_banner.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/live_builder.dart';
import 'admin_widgets.dart';

/// Admin: kelola banner promo (gambar + teks) yang tampil menggeser di Home customer.
/// Maksimal 4 banner (AppStore.maxBanners). Banner bisa dimatikan sementara tanpa dihapus.
class ManageBannerPage extends StatelessWidget {
  const ManageBannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStore.I;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          pageHeader(context, 'Banner Promo'),
          Expanded(
            child: LiveBuilder((context) => ListView(padding: const EdgeInsets.all(16), children: [
                  card(
                    color: const Color(0xFFEFFBD6),
                    child: const Row(children: [
                      Icon(Icons.info_outline, color: C.green),
                      SizedBox(width: 10),
                      Expanded(child: Text('Maksimal 4 banner. Banner aktif tampil menggeser otomatis di Home customer.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: s.canAddBanner ? () => _openForm(context, s) : null,
                    style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white),
                    icon: const Icon(Icons.add),
                    label: Text('Tambah Banner (${s.banners.length}/${AppStore.maxBanners})'),
                  ),
                  const SizedBox(height: 14),
                  for (final b in s.banners)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(children: [
                        BannerCard(b),
                        Row(children: [
                          Switch(value: b.active, activeTrackColor: C.green, onChanged: (v) => s.setBannerActive(b, v)),
                          Text(b.active ? 'Ditampilkan' : 'Disembunyikan', style: const TextStyle(fontSize: 11, color: C.muted, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          IconButton(onPressed: () => _openForm(context, s, b), icon: const Icon(Icons.edit_outlined, size: 20)),
                          IconButton(
                            onPressed: () async {
                              if (await confirmBox(context, 'Hapus banner?', '"${b.title}" akan dihapus dari Home customer.', ok: 'Hapus')) s.deleteBanner(b);
                            },
                            icon: const Icon(Icons.delete_outline, size: 20, color: C.red),
                          ),
                        ]),
                      ]),
                    ),
                ])),
          ),
        ]),
      ),
    );
  }

  /// Form tambah / edit banner (bottom sheet) dengan pratinjau langsung.
  Future<void> _openForm(BuildContext context, AppStore s, [PromoBanner? existing]) async {
    final draft = existing?.copy() ?? PromoBanner(id: 'B${DateTime.now().microsecondsSinceEpoch}', title: '');
    final title = TextEditingController(text: draft.title);
    final sub = TextEditingController(text: draft.subtitle);
    final code = TextEditingController(text: draft.code);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, set) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(sheet).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(existing == null ? 'Tambah Banner' : 'Edit Banner', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              BannerCard(draft..title = title.text..subtitle = sub.text..code = code.text),
              const SizedBox(height: 12),
              TextField(controller: title, onChanged: (_) => set(() {}), decoration: const InputDecoration(labelText: 'Judul')),
              TextField(controller: sub, onChanged: (_) => set(() {}), decoration: const InputDecoration(labelText: 'Deskripsi singkat')),
              TextField(controller: code, onChanged: (_) => set(() {}), decoration: const InputDecoration(labelText: 'Kode promo (opsional)')),
              const SizedBox(height: 12),
              const Text('Warna latar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Row(children: [
                for (var i = 0; i < C.bannerGradients.length; i++)
                  GestureDetector(
                    onTap: () => set(() => draft.gradient = i),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(gradient: C.bannerGradients[i], borderRadius: BorderRadius.circular(12), border: Border.all(color: draft.gradient == i ? C.amber : Colors.transparent, width: 3)),
                    ),
                  ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
                    if (x == null) return;
                    final bytes = await x.readAsBytes();
                    set(() => draft.image = bytes);
                  },
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: Text(draft.image == null ? 'Pilih Gambar' : 'Ganti Gambar'),
                ),
                if (draft.image != null) TextButton(onPressed: () => set(() => draft.image = null), child: const Text('Hapus gambar')),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, minimumSize: const Size(0, 48)),
                  onPressed: () {
                    if (title.text.trim().isEmpty) return;
                    draft
                      ..title = title.text.trim()
                      ..subtitle = sub.text.trim()
                      ..code = code.text.trim();
                    s.saveBanner(draft);
                    Navigator.pop(sheet);
                  },
                  child: const Text('Simpan Banner', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
