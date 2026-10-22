// ============================================================
// FILE   : screens/admin/manage_venue_tabs.dart
// FUNGSI : Tab venue tambahan
//          Jam operasional & fasilitas GOR.
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/facility_icons.dart';
import '../../data/app_store.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/live_builder.dart';

/// Tab tambahan di Kelola Venue: Jam operasional dan Fasilitas GOR.

/// Admin menambah / menghapus jam mulai yang bisa dipesan (chip hijau = buka).
class HoursTab extends StatelessWidget {
  const HoursTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppStore.I;
    return LiveBuilder((context) => ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Ketuk jam untuk membuka atau menutup slot. Slot yang ditutup tidak muncul di halaman booking customer dan pembuatan room mabar.', style: TextStyle(fontSize: 11, color: C.muted)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final h in AppStore.allHours)
              GestureDetector(
                onTap: () => s.toggleHour(h),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 74,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: s.openHours.contains(h) ? C.primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: s.openHours.contains(h) ? C.lime : C.border)),
                  child: Column(children: [
                    Text('${h.toString().padLeft(2, '0')}:00', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: s.openHours.contains(h) ? Colors.white : Colors.black45)),
                    Text(s.openHours.contains(h) ? 'Buka' : 'Tutup', style: TextStyle(fontSize: 8, color: s.openHours.contains(h) ? C.lime : C.muted, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
          ]),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: s.resetHours, icon: const Icon(Icons.restore, size: 18), label: const Text('Kembalikan 08:00 - 23:00')),
        ]));
  }
}

/// Admin menambah / menghapus fasilitas GOR (tampil di Home customer).
class FacilitiesTab extends StatefulWidget {
  const FacilitiesTab({super.key});
  @override
  State<FacilitiesTab> createState() => _FacilitiesTabState();
}

class _FacilitiesTabState extends State<FacilitiesTab> {
  final _name = TextEditingController();
  String _icon = facilityIcons.keys.first;

  @override
  Widget build(BuildContext context) {
    final s = AppStore.I;
    return LiveBuilder((context) => ListView(padding: const EdgeInsets.all(16), children: [
          card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tambah Fasilitas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nama fasilitas (mis. Ruang Ganti)')),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final e in facilityIcons.entries)
                  GestureDetector(
                    onTap: () => setState(() => _icon = e.key),
                    child: CircleAvatar(radius: 20, backgroundColor: _icon == e.key ? C.primary : const Color(0xFFEEECFF), child: Icon(e.value, size: 20, color: _icon == e.key ? C.lime : C.muted)),
                  ),
              ]),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white),
                onPressed: () {
                  if (_name.text.trim().isEmpty) return;
                  s.addFacility(_name.text.trim(), _icon);
                  _name.clear();
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < s.facilities.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: card(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(children: [
                  CircleAvatar(radius: 18, backgroundColor: C.accents[i % C.accents.length].withValues(alpha: .15), child: Icon(facilityIcons[s.facilities[i].iconKey] ?? Icons.apartment, size: 18, color: C.accents[i % C.accents.length])),
                  const SizedBox(width: 12),
                  Expanded(child: Text(s.facilities[i].name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
                  IconButton(onPressed: () => s.deleteFacility(s.facilities[i]), icon: const Icon(Icons.delete_outline, size: 20, color: C.red)),
                ]),
              ),
            ),
        ]));
  }
}
