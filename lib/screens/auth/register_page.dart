// ============================================================
// FILE   : screens/auth/register_page.dart
// FUNGSI : Registrasi
//          Membuat akun customer baru (validasi + simpan ke AppStore).
// UBAH DI SINI UNTUK: Ubah aturan validasi pendaftaran.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../data/app_store.dart';
import '../../widgets/animations.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/main_shell.dart';
import '../customer/customer_home.dart';

/// Registrasi akun customer baru. Data disimpan di AppStore (memori) lewat store.register().
/// Validasi: nama, format email, no. WA, sandi (min. 8 karakter huruf + angka), konfirmasi, persetujuan S&K.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final store = AppStore.I;
  final _name = TextEditingController(), _email = TextEditingController(), _phone = TextEditingController();
  final _pass = TextEditingController(), _conf = TextEditingController();
  String _level = 'Beginner';
  bool _agree = false, _hide = true;

  /// Mengembalikan pesan error pertama, atau null bila semua input valid.
  String? _validate() {
    if (_name.text.trim().length < 3) return 'Nama lengkap minimal 3 huruf';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim())) return 'Format email belum benar';
    if (!RegExp(r'^\d{9,14}$').hasMatch(AppStore.normalizePhone(_phone.text))) return 'Nomor WhatsApp belum benar (9-14 digit)';
    final p = _pass.text;
    if (p.length < 8 || !p.contains(RegExp(r'[A-Za-z]')) || !p.contains(RegExp(r'[0-9]'))) return 'Kata sandi minimal 8 karakter dan mengandung huruf + angka';
    if (p != _conf.text) return 'Konfirmasi kata sandi tidak sama';
    if (!_agree) return 'Centang persetujuan Syarat & Ketentuan dulu';
    return null;
  }

  void _submit() {
    final msg = _validate() ?? store.register(name: _name.text, email: _email.text, phone: _phone.text, password: _pass.text, level: _level);
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    // Berhasil: langsung login dan buka Home customer
    store.login(_email.text, _pass.text);
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell(home: CustomerHome())), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEECFF),
      body: SafeArea(
        child: Column(children: [
          pageHeader(context, 'Daftar Akun'),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 20), children: [
              FadeSlideIn(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(gradient: C.heroGradient, borderRadius: BorderRadius.circular(22)),
                  child: const Row(children: [
                    Icon(Icons.sports_tennis, color: C.lime, size: 34),
                    SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Gabung MatchPoint', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('Pesan lapangan & cari lawan mabar di Bandung.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ])),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delayMs: 120,
                child: card(
                  radius: 22,
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _label('Nama Lengkap'),
                    _field(_name, 'Nama sesuai identitas', Icons.person_outline),
                    _label('Email'),
                    _field(_email, 'email@domain.com', Icons.mail_outline, type: TextInputType.emailAddress),
                    _label('Nomor WhatsApp'),
                    _field(_phone, '0812-xxxx-xxxx', Icons.chat_outlined, type: TextInputType.phone),
                    _label('Level Bermain'),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final l in ['Beginner', 'Intermediate', 'Advanced', 'Pro'])
                        GestureDetector(
                          onTap: () => setState(() => _level = l),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(color: _level == l ? C.primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)),
                            child: Text(l, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _level == l ? Colors.white : Colors.black87)),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 12),
                    _label('Kata Sandi'),
                    _field(_pass, 'Minimal 8 karakter (huruf + angka)', Icons.lock_outline, hide: _hide, suffix: IconButton(icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20), onPressed: () => setState(() => _hide = !_hide))),
                    _label('Konfirmasi Kata Sandi'),
                    _field(_conf, 'Ulangi kata sandi', Icons.lock_outline, hide: _hide),
                    const SizedBox(height: 8),
                    Row(children: [
                      SizedBox(width: 24, child: Checkbox(value: _agree, activeColor: C.primary, onChanged: (v) => setState(() => _agree = v ?? false))),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi MatchPoint.', style: TextStyle(fontSize: 10, color: C.muted))),
                    ]),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: const Text('Buat Akun', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 14),
              Center(child: GestureDetector(onTap: () => Navigator.pop(context), child: const Text.rich(TextSpan(style: TextStyle(fontSize: 11, color: C.muted), children: [TextSpan(text: 'Sudah punya akun? '), TextSpan(text: 'Masuk', style: TextStyle(color: C.green, fontWeight: FontWeight.w800))])))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 6, top: 6), child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)));

  Widget _field(TextEditingController c, String hint, IconData icon, {bool hide = false, Widget? suffix, TextInputType? type}) => TextField(
        controller: c,
        obscureText: hide,
        keyboardType: type,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          prefixIcon: Icon(icon, size: 20, color: C.muted),
          suffixIcon: suffix,
          filled: true,
          fillColor: const Color(0xFFEEECFF),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      );
}
