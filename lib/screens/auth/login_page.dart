// ============================================================
// FILE   : screens/auth/login_page.dart
// FUNGSI : Login
//          Masuk dengan email / no. WA. Role (admin/customer) dikenali otomatis dari akun.
// UBAH DI SINI UNTUK: Ubah tampilan / validasi login.
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../data/app_store.dart';
import '../../data/models/user.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/main_shell.dart';
import '../admin/admin_home.dart';
import '../customer/customer_home.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _id = TextEditingController();
  final _pw = TextEditingController();
  bool _obscure = true, _remember = true, _register = false;

  /// Buka halaman registrasi akun baru.
  void _openRegister() => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));

  void _submit() {
    final u = AppStore.I.login(_id.text, _pw.text);
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email/No. WA atau kata sandi salah')));
      return;
    }
    // Role otomatis dari akun: admin -> dashboard admin, customer -> home customer.
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => MainShell(home: u.role == Role.admin ? const AdminHome() : const CustomerHome()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEECFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
          child: Column(children: [
            Row(children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
              logoBox(size: 28),
              const SizedBox(width: 8),
              const Text('Login', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 10),
            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(colors: [Color(0xFF0B2E1F), Color(0xFF2F5D3B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24)),
                  child: const Icon(Icons.sports_tennis, color: C.lime, size: 32),
                ),
                const SizedBox(height: 12),
                const Text('MatchPoint Bandung', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('GOR Bulutangkis Premium & Komunitas', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ]),
            ),
            const SizedBox(height: 18),
            // Form card
            card(
              radius: 22,
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: const Color(0xFFEEECFF), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    _tab('Masuk', !_register, () => setState(() => _register = false)),
                    _tab('Daftar Baru', _register, _openRegister),
                  ]),
                ),
                const SizedBox(height: 18),
                Row(children: [
                  const Text('Nomor WhatsApp / Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  const Text('Verifikasi Instan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.green)),
                ]),
                const SizedBox(height: 8),
                _field(_id, '0812-xxxx-xxxx atau email@domain.com', Icons.chat_outlined, keyboard: TextInputType.emailAddress),
                const SizedBox(height: 16),
                const Text('Kata Sandi / PIN Keamanan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                _field(_pw, '', Icons.lock_outline, obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )),
                const SizedBox(height: 10),
                Row(children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(value: _remember, activeColor: C.primary, onChanged: (v) => setState(() => _remember = v ?? false)),
                  ),
                  const SizedBox(width: 6),
                  const Text('Ingat saya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  GestureDetector(onTap: () => soon(context), child: const Text('Lupa Kata Sandi?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.green))),
                ]),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Masuk ke MatchPoint', style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ]),
                  ),
                ),
                const SizedBox(height: 14),
                Row(children: const [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('ATAU LANJUT DENGAN', style: TextStyle(fontSize: 8, letterSpacing: 1, color: C.muted, fontWeight: FontWeight.w700))),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => soon(context),
                    style: OutlinedButton.styleFrom(backgroundColor: const Color(0xFFF3F1FF), side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('G', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF4285F4), fontSize: 18)),
                      SizedBox(width: 8),
                      Text('Lanjutkan dengan Google', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Container(height: 40, decoration: BoxDecoration(color: const Color(0xFFE4E1FA), borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 18),
            GestureDetector(onTap: _openRegister, child: const Text.rich(
              TextSpan(style: TextStyle(fontSize: 11, color: C.muted), children: [
                TextSpan(text: 'Belum punya akun MatchPoint? '),
                TextSpan(text: 'Daftar Sekarang', style: TextStyle(color: C.green, fontWeight: FontWeight.w800)),
              ]),
            )),
            const SizedBox(height: 8),
            const Text(
              'Dengan masuk, Anda menyetujui Syarat & Ketentuan serta\nKebijakan Privasi MatchPoint GOR Bulutangkis Bandung.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: C.muted, fontWeight: FontWeight.w600),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _tab(String t, bool on, VoidCallback f) => Expanded(
        child: GestureDetector(
          onTap: f,
          child: Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: on ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(11)),
            child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: on ? Colors.black : C.muted)),
          ),
        ),
      );

  Widget _field(TextEditingController c, String hint, IconData icon, {bool obscure = false, Widget? suffix, TextInputType? keyboard}) =>
      TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
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
