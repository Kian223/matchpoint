// ============================================================
// FILE   : screens/admin/manage_venue_page.dart
// FUNGSI : Kelola venue
//          Tab Lapangan & Alat Sewa (CRUD).
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/court.dart';
import '../../data/models/equipment.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/live_builder.dart';
import 'admin_widgets.dart';
import 'manage_venue_tabs.dart';

// ======================= KELOLA VENUE (LAPANGAN & ALAT) =======================
class ManageVenuePage extends StatelessWidget {
  const ManageVenuePage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppStore.I;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: SafeArea(
          child: Column(children: [
            pageHeader(context, 'Kelola Venue'),
            const TabBar(isScrollable: true, labelColor: C.primary, indicatorColor: C.primary, unselectedLabelColor: C.muted, tabs: [Tab(text: 'Lapangan'), Tab(text: 'Alat Sewa'), Tab(text: 'Jam'), Tab(text: 'Fasilitas')]),
            Expanded(
              child: TabBarView(children: [
                LiveBuilder((context) => ListView(padding: const EdgeInsets.all(16), children: [
                      const Text('Aman = bisa dipesan • Maintenance = rusak/perbaikan • Sudah Dipesan = ditutup manual oleh admin', style: TextStyle(fontSize: 10, color: C.muted)),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(onPressed: () => _courtDialog(context, s), style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white), icon: const Icon(Icons.add), label: const Text('Tambah Lapangan')),
                      const SizedBox(height: 12),
                      for (final c in s.courts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: card(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                CircleAvatar(radius: 12, backgroundColor: C.primary, child: Text('${c.no}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800))),
                                const SizedBox(width: 8),
                                Expanded(child: Text('${c.name} • ${c.type}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
                                IconButton(visualDensity: VisualDensity.compact, onPressed: () => _courtDialog(context, s, c), icon: const Icon(Icons.edit_outlined, size: 18)),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () async {
                                    if (!await confirmBox(context, 'Hapus ${c.name}?', 'Lapangan akan dihapus dari daftar.', ok: 'Hapus')) return;
                                    final err = s.deleteCourt(c);
                                    if (err != null && context.mounted) soon(context, err);
                                  },
                                  icon: const Icon(Icons.delete_outline, size: 18, color: C.red),
                                ),
                              ]),
                              Text('${rupiah(c.price)} / jam  •  ${courtInfo(s, c).tag}', style: const TextStyle(fontSize: 11, color: C.green, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 10),
                              statusChips(s, c),
                            ]),
                          ),
                        ),
                    ])),
                LiveBuilder((context) => ListView(padding: const EdgeInsets.all(16), children: [
                      ElevatedButton.icon(onPressed: () => _equipDialog(context, s), style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white), icon: const Icon(Icons.add), label: const Text('Tambah Alat Sewa')),
                      const SizedBox(height: 12),
                      if (s.equipment.isEmpty) const Text('Belum ada alat sewa.', style: TextStyle(fontSize: 11, color: C.muted)),
                      for (final e in s.equipment)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: card(
                            child: Row(children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(e.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                Text(e.desc, style: const TextStyle(fontSize: 10, color: C.muted)),
                                const SizedBox(height: 4),
                                Text('${rupiah(e.price)}/${e.unit}  •  stok ${e.stock}', style: const TextStyle(fontSize: 11, color: C.green, fontWeight: FontWeight.w700)),
                              ])),
                              Switch(value: e.active, activeTrackColor: C.green, onChanged: (v) => s.setEquipmentActive(e, v)),
                              IconButton(visualDensity: VisualDensity.compact, onPressed: () => _equipDialog(context, s, e), icon: const Icon(Icons.edit_outlined, size: 18)),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () async {
                                  if (await confirmBox(context, 'Hapus ${e.name}?', 'Alat tidak akan tampil lagi untuk customer.', ok: 'Hapus')) s.deleteEquipment(e);
                                },
                                icon: const Icon(Icons.delete_outline, size: 18, color: C.red),
                              ),
                            ]),
                          ),
                        ),
                    ])),
                const HoursTab(),
                const FacilitiesTab(),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _courtDialog(BuildContext context, AppStore s, [Court? c]) async {
    var type = c?.type ?? 'Karpet';
    final price = TextEditingController(text: '${c?.price ?? 60000}');
    await showDialog(
      context: context,
      builder: (d) => StatefulBuilder(
        builder: (d, set) => AlertDialog(
          title: Text(c == null ? 'Tambah Lapangan' : 'Edit ${c.name}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButton<String>(isExpanded: true, value: type, items: [for (final t in ['Karpet', 'Vinyl', 'Parquet']) DropdownMenuItem(value: t, child: Text('Lantai $t'))], onChanged: (v) => set(() => type = v ?? type)),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tarif per jam (Rp)')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
            TextButton(
              onPressed: () {
                final p = int.tryParse(price.text.replaceAll('.', '').trim()) ?? 0;
                if (p <= 0) return;
                if (c == null) {
                  s.addCourt(type, p);
                } else {
                  s.updateCourt(c, type, p);
                }
                Navigator.pop(d);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _equipDialog(BuildContext context, AppStore s, [Equipment? e]) async {
    final name = TextEditingController(text: e?.name ?? '');
    final desc = TextEditingController(text: e?.desc ?? '');
    final unit = TextEditingController(text: e?.unit ?? 'pcs');
    final price = TextEditingController(text: '${e?.price ?? 20000}');
    final stock = TextEditingController(text: '${e?.stock ?? 5}');
    await showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(e == null ? 'Tambah Alat Sewa' : 'Edit Alat Sewa'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama alat')),
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Deskripsi singkat')),
            TextField(controller: unit, decoration: const InputDecoration(labelText: 'Satuan (pcs / pasang / slop)')),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tarif sewa (Rp)')),
            TextField(controller: stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok tersedia')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              final p = int.tryParse(price.text.replaceAll('.', '').trim()) ?? 0;
              final st = int.tryParse(stock.text.trim()) ?? -1;
              if (name.text.trim().isEmpty || p <= 0 || st < 0) return;
              s.upsertEquipment(id: e?.id, name: name.text.trim(), desc: desc.text.trim(), unit: unit.text.trim().isEmpty ? 'pcs' : unit.text.trim(), price: p, stock: st);
              Navigator.pop(d);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
