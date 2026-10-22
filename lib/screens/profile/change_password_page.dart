// ============================================================
// FILE   : screens/profile/change_password_page.dart
// FUNGSI : Ubah kata sandi
//          Validasi kata sandi lama, kekuatan sandi baru.
// UBAH DI SINI UNTUK: Ubah aturan kata sandi.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../data/app_store.dart';
import '../../widgets/common_widgets.dart';

// ======================= UBAH KATA SANDI =======================
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final store = AppStore.I;
  final oldC = TextEditingController(), newC = TextEditingController(), confC = TextEditingController();
  bool o1 = true, o2 = true, o3 = true, logoutOthers = true;

  String get pw => newC.text;
  bool get r1 => pw.length >= 8;
  bool get r2 => pw.contains(RegExp(r'[a-z]')) && pw.contains(RegExp(r'[A-Z]'));
  bool get r3 => pw.contains(RegExp(r'[0-9]'));
  bool get r4 => pw.contains(RegExp(r'[^A-Za-z0-9]'));
  int get score => [r1, r2, r3, r4].where((e) => e).length;

  void _save() {
    String? err;
    if (oldC.text.isEmpty) {
      err = 'Masukkan kata sandi lama';
    } else if (!(r1 && r2 && r3)) {
      err = 'Kata sandi baru belum memenuhi syarat (min. 8 karakter, huruf besar & kecil, angka)';
    } else if (newC.text != confC.text) {
      err = 'Konfirmasi kata sandi tidak sama';
    } else {
      err = store.changePassword(oldC.text, newC.text);
    }
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diubah. Gunakan yang baru saat login berikutnya.')));
    Navigator.pop(context);
  }

  Widget _pwField(TextEditingController c, String hint, bool obscure, VoidCallback toggle) => TextField(
        controller: c,
        obscureText: obscure,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12),
          prefixIcon: const Icon(Icons.lock_outline, size: 18, color: C.muted),
          suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18), onPressed: toggle),
          filled: true,
          fillColor: const Color(0xFFEEECFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );

  Widget _rule(String t, bool ok) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked, size: 14, color: ok ? C.green : C.muted),
          const SizedBox(width: 8),
          Text(t, style: TextStyle(fontSize: 10, color: ok ? Colors.black87 : C.muted, fontWeight: FontWeight.w600)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFFE5E7EB), C.red, Color(0xFFF59E0B), Color(0xFF84CC16), C.green];
    const labels = ['', 'Lemah', 'Cukup', 'Kuat', 'Sangat Kuat'];
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          pageHeader(context, 'Ubah Kata Sandi'),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), children: [
              Row(children: [
                Expanded(child: GestureDetector(onTap: () => soon(context, 'PIN transaksi dibuat di tahap berikutnya'), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: const Text('PIN Transaksi (6-Digit)', style: TextStyle(fontSize: 10, color: C.muted, fontWeight: FontWeight.w700))))),
                const SizedBox(width: 8),
                Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 12), alignment: Alignment.center, decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(12)), child: const Text('Kata Sandi Akun', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800)))),
              ]),
              const SizedBox(height: 14),
              card(
                radius: 20,
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Kata Sandi Akun', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  const Text('Gunakan kombinasi minimal 8 karakter dengan huruf besar, huruf kecil, angka, dan simbol untuk keamanan akun.', style: TextStyle(fontSize: 10, color: C.muted)),
                  const SizedBox(height: 14),
                  const Text('Kata Sandi Lama', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  _pwField(oldC, 'Masukkan kata sandi lama', o1, () => setState(() => o1 = !o1)),
                  Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => soon(context, 'Reset via WhatsApp/Email dibuat di tahap berikutnya'), child: const Text('Lupa Kata Sandi? Reset via WhatsApp/Email', style: TextStyle(fontSize: 9, color: C.green, fontWeight: FontWeight.w800)))),
                  const Text('Kata Sandi Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  _pwField(newC, 'Minimal 8 karakter', o2, () => setState(() => o2 = !o2)),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Text('Kekuatan Sandi', style: TextStyle(fontSize: 10, color: C.muted)),
                    const Spacer(),
                    Text(labels[score], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: colors[score == 0 ? 0 : score])),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [for (var i = 1; i <= 4; i++) Expanded(child: Container(height: 5, margin: const EdgeInsets.only(right: 4), decoration: BoxDecoration(color: i <= score ? colors[score] : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(4))))]),
                  const SizedBox(height: 8),
                  _rule('Minimal 8 karakter', r1),
                  _rule('Mengandung huruf besar (A-Z) dan kecil (a-z)', r2),
                  _rule('Mengandung angka (0-9)', r3),
                  _rule('Mengandung simbol khusus (@, #, \$, &)', r4),
                  const SizedBox(height: 12),
                  const Text('Konfirmasi Kata Sandi Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  _pwField(confC, 'Ulangi kata sandi baru', o3, () => setState(() => o3 = !o3)),
                  if (confC.text.isNotEmpty && confC.text != newC.text) const Padding(padding: EdgeInsets.only(top: 4), child: Text('Konfirmasi belum sama', style: TextStyle(fontSize: 10, color: C.red))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFEEECFF), borderRadius: BorderRadius.circular(12)),
                    child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.shield_outlined, size: 16, color: Color(0xFF4F46E5)),
                      SizedBox(width: 8),
                      Expanded(child: Text('Tips Keamanan: jangan gunakan kata sandi yang sama dengan akun lain dan jangan bagikan ke siapa pun, termasuk admin.', style: TextStyle(fontSize: 9, color: C.muted))),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    SizedBox(width: 24, child: Checkbox(value: logoutOthers, activeColor: C.primary, onChanged: (v) => setState(() => logoutOthers = v ?? false))),
                    const SizedBox(width: 6),
                    const Expanded(child: Text('Keluarkan dari semua perangkat lain setelah kata sandi diganti.', style: TextStyle(fontSize: 9, color: C.muted))),
                  ]),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), icon: const Icon(Icons.check_circle_outline, size: 18), label: const Text('Simpan Kata Sandi Baru', style: TextStyle(fontWeight: FontWeight.w800)))),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batalkan dan Kembali', style: TextStyle(fontSize: 11, color: C.muted, fontWeight: FontWeight.w700))),
            ]),
          ),
        ]),
      ),
    );
  }
}
