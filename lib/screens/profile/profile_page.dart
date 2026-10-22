// ============================================================
// FILE   : screens/profile/profile_page.dart
// FUNGSI : Profil
//          Edit data diri, foto profil, media sosial (customer) / data staf (admin).
// UBAH DI SINI UNTUK: Tambah field profil.
// ============================================================

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_colors.dart';
import '../../data/app_store.dart';
import '../../data/models/booking.dart';
import '../../data/models/user.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/user_avatar.dart';
import '../auth/login_page.dart';
import 'change_password_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final store = AppStore.I;
  late final AppUser u = store.current!;
  late final name = TextEditingController(text: u.name);
  late final bio = TextEditingController(text: u.bio);
  late final phone = TextEditingController(text: u.phone);
  late final racket = TextEditingController(text: u.racket);
  late final shoe = TextEditingController(text: u.shoe);
  late final home = TextEditingController(text: u.homeBase);
  late final ig = TextEditingController(text: u.instagram);
  late final tw = TextEditingController(text: u.twitter);
  late final fb = TextEditingController(text: u.facebook);
  late String gender = u.gender, level = u.level, hand = u.hand;
  late Set<String> types = {...u.types};
  late List<bool> tg = [...u.toggles];

  bool get admin => u.role == Role.admin;

  void _save() {
    if (name.text.trim().isEmpty || phone.text.trim().isEmpty) {
      soon(context, 'Nama dan nomor WhatsApp tidak boleh kosong');
      return;
    }
    u.name = name.text.trim();
    u.bio = bio.text.trim();
    u.phone = phone.text.trim();
    u.gender = gender;
    u.level = level;
    u.hand = hand;
    u.racket = racket.text.trim();
    u.shoe = shoe.text.trim();
    u.homeBase = home.text.trim();
    u.instagram = ig.text.trim().replaceAll('@', '');
    u.twitter = tw.text.trim().replaceAll('@', '');
    u.facebook = fb.text.trim();
    u.types = {...types};
    u.toggles = [...tg];
    store.updateProfile();
    soon(context, 'Perubahan data tersimpan');
  }

  /// Pilih foto profil dari galeri (image_picker). Disimpan sebagai bytes di AppUser.photo.
  Future<void> _pickPhoto() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (x == null) return;
    u.photo = await x.readAsBytes();
    store.updateProfile();
    if (mounted) setState(() {});
  }

  void _logout() {
    store.logout();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  void _preview() => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            UserAvatar(name.text, email: u.email, r: 32),
            const SizedBox(height: 10),
            Text(name.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            chip('Level: $level', bg: const Color(0xFFE3EEFF), fg: const Color(0xFF1E5BB8)),
            const SizedBox(height: 10),
            Text(bio.text.isEmpty ? 'Belum ada bio.' : bio.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: C.muted)),
            const SizedBox(height: 10),
            Wrap(spacing: 6, children: [for (final t in types) chip(t)]),
            if (ig.text.isNotEmpty || tw.text.isNotEmpty || fb.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (ig.text.isNotEmpty) chip('@${ig.text.replaceAll('@', '')}', bg: const Color(0xFFEEECFF), fg: C.violet, icon: Icons.camera_alt_outlined),
                if (tw.text.isNotEmpty) chip('@${tw.text.replaceAll('@', '')}', bg: const Color(0xFFEEECFF), fg: C.violet, icon: Icons.alternate_email),
                if (fb.text.isNotEmpty) chip(fb.text, bg: const Color(0xFFEEECFF), fg: C.violet, icon: Icons.facebook),
              ]),
            ],
          ]),
        ),
      );

  // ---------- helpers UI ----------
  Widget _sec(IconData ic, String t, String sub, List<Widget> kids) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: card(
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(ic, size: 18), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800))]),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 10, color: C.muted)),
            const SizedBox(height: 14),
            ...kids,
          ]),
        ),
      );

  Widget _lbl(String t) => Padding(padding: const EdgeInsets.only(bottom: 6, top: 4), child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)));

  Widget _tf(TextEditingController c, {int lines = 1, bool enabled = true, IconData? icon, int? max, Widget? suffix}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          enabled: enabled,
          maxLines: lines,
          maxLength: max,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: icon == null ? null : Icon(icon, size: 18, color: C.muted),
            suffixIcon: suffix,
            counterStyle: const TextStyle(fontSize: 9),
            filled: true,
            fillColor: const Color(0xFFEEECFF),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      );

  Widget _opt(String t, bool on, VoidCallback f, {String? sub}) => GestureDetector(
        onTap: f,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: on ? const Color(0xFFEFFBD6) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: on ? C.green : C.border, width: on ? 1.5 : 1)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            if (sub != null) Text(sub, style: const TextStyle(fontSize: 9, color: C.muted)),
          ]),
        ),
      );

  Widget _toggle(String t, String s, int i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            Text(s, style: const TextStyle(fontSize: 9, color: C.muted)),
          ])),
          Switch(value: tg[i], activeTrackColor: C.green, onChanged: (v) => setState(() => tg[i] = v)),
        ]),
      );

  Widget _link(IconData ic, String t, String s, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF6F5FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)),
          child: Row(children: [
            Icon(ic, size: 18, color: const Color(0xFF1E5BB8)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              Text(s, style: const TextStyle(fontSize: 9, color: C.muted)),
            ])),
            const Icon(Icons.chevron_right, color: C.muted),
          ]),
        ),
      );

  Widget _stat(String v, String l) => Expanded(
        child: card(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          radius: 14,
          child: Column(children: [
            Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(l, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8, color: C.muted, fontWeight: FontWeight.w700)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final done = store.bookings.where((b) => b.status != BookingStatus.pending).length;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 20), children: [
      Row(children: [
        const Expanded(child: Text('Profil & Edit Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
        logoBox(size: 30),
      ]),
      const SizedBox(height: 14),
      card(
        radius: 22,
        child: Column(children: [
          Stack(children: [
            CircleAvatar(radius: 42, backgroundColor: C.green, child: UserAvatar(name.text, email: u.email, r: 39)),
            Positioned(right: 0, bottom: 0, child: GestureDetector(onTap: _pickPhoto, child: const CircleAvatar(radius: 13, backgroundColor: C.lime, child: Icon(Icons.photo_camera_outlined, size: 14, color: C.primary)))),
          ]),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(child: Text(name.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800))),
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 16, color: C.green),
          ]),
          const SizedBox(height: 4),
          Text(admin ? 'Admin GOR Bulutangkis Bandung' : 'Member Aktif GOR Bandung  •  ID: MP-2023/${(store.users.indexOf(u) + 15).toString().padLeft(5, '0')}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: C.muted)),
          const SizedBox(height: 10),
          if (admin)
            chip('Admin', icon: Icons.shield_outlined)
          else
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              OutlinedButton(onPressed: _preview, child: const Text('Pratinjau Publik', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: C.lime, foregroundColor: C.primary), child: const Text('Simpan Cepat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
            ]),
        ]),
      ),
      const SizedBox(height: 14),
      if (admin) ...[
        const Text('KINERJA HARI INI', style: TextStyle(fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w800, color: C.muted)),
        const SizedBox(height: 8),
        Row(children: [_stat('$done', 'Verifikasi\nSelesai'), const SizedBox(width: 8), _stat('1.8m', 'Respon CS Chat'), const SizedBox(width: 8), _stat('99.4%', 'Presensi Shift')]),
        const SizedBox(height: 14),
        _sec(Icons.badge_outlined, 'Data Staf & Kontak Operasional', 'Informasi staf pengelola GOR', [
          _lbl('Nama Lengkap Admin'),
          _tf(name, icon: Icons.person_outline),
          _lbl('NIP / ID Staf (Terkunci)'),
          _tf(TextEditingController(text: u.nip), enabled: false, icon: Icons.lock_outline),
          _lbl('Catatan / Bio Operasional Staf'),
          _tf(bio, lines: 3),
          _lbl('WhatsApp Siaga Customer Service'),
          _tf(phone, icon: Icons.phone_outlined),
          _lbl('Alamat Email Resmi GOR'),
          _tf(TextEditingController(text: u.email), enabled: false, icon: Icons.mail_outline),
        ]),
        _sec(Icons.notifications_active_outlined, 'Notifikasi & Keamanan Admin', 'Atur peringatan operasional', [
          _toggle('Notifikasi Booking Masuk', 'Push notif saat ada pesanan masuk yang perlu diverifikasi.', 0),
          _toggle('Alert Otomatis IoT Lampu', 'Pemberitahuan otomatis saat lampu court perlu dimatikan.', 1),
          _toggle('Pesan CS WhatsApp Gateway', 'Sinkronisasi pesan customer ke WhatsApp gateway.', 2),
          _link(Icons.menu_book_outlined, 'Buku SOP & Manual Operasional Lapangan', 'Panduan staf GOR', () => soon(context)),
          _link(Icons.lock_reset, 'Ubah Kata Sandi Akun Admin', 'Ganti kata sandi login', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()))),
        ]),
      ] else ...[
        _sec(Icons.contact_page_outlined, 'Data Diri & Kontak', 'Identitas dan penjelas di ekosistem mabar', [
          _lbl('Nama Lengkap'),
          _tf(name, icon: Icons.person_outline),
          _lbl('Bio & Deskripsi Main'),
          _tf(bio, lines: 3, max: 160),
          _lbl('Nomor WhatsApp'),
          _tf(phone, icon: Icons.phone_outlined, suffix: const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.verified_user, size: 16, color: C.green))),
          _lbl('Alamat Email'),
          _tf(TextEditingController(text: u.email), enabled: false, icon: Icons.mail_outline),
          _lbl('Instagram (tanpa @)'),
          _tf(ig, icon: Icons.camera_alt_outlined),
          _lbl('X / Twitter (tanpa @)'),
          _tf(tw, icon: Icons.alternate_email),
          _lbl('Facebook'),
          _tf(fb, icon: Icons.facebook),
          _lbl('Jenis Kelamin'),
          Row(children: [Expanded(child: _opt('Pria', gender == 'Pria', () => setState(() => gender = 'Pria'))), const SizedBox(width: 8), Expanded(child: _opt('Wanita', gender == 'Wanita', () => setState(() => gender = 'Wanita')))]),
        ]),
        _sec(Icons.sports_tennis, 'Preferensi Bermain', 'Karakteristik pemain untuk matchmaking mabar', [
          _lbl('Level Keahlian'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final l in const [('Beginner', 'Rally dasar & latihan'), ('Intermediate', 'Smash terarah & rotasi'), ('Advanced', 'Spesialis turnamen lokal'), ('Pro', 'Atlet / profesional')])
              SizedBox(width: (MediaQuery.of(context).size.width - 32 - 32 - 8) / 2, child: _opt(l.$1, level == l.$1, () => setState(() => level = l.$1), sub: l.$2)),
          ]),
          const SizedBox(height: 10),
          _lbl('Tipe Bermain Favorit'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in const ['Ganda Putra (MD)', 'Ganda Campuran (XD)', 'Tunggal Putra (MS)', 'Ganda Putri (WD)', 'Tunggal Putri (WS)'])
              _opt(t, types.contains(t), () => setState(() => types.contains(t) ? types.remove(t) : types.add(t))),
          ]),
          const SizedBox(height: 10),
          _lbl('Tangan Dominan'),
          Row(children: [Expanded(child: _opt('Kanan (Dominant)', hand == 'Kanan', () => setState(() => hand = 'Kanan'))), const SizedBox(width: 8), Expanded(child: _opt('Kidal (Kiri)', hand == 'Kidal', () => setState(() => hand = 'Kidal')))]),
          const SizedBox(height: 10),
          _lbl('Raket'),
          _tf(racket, icon: Icons.sports_tennis),
          _lbl('Sepatu'),
          _tf(shoe, icon: Icons.straighten),
        ]),
        _sec(Icons.shield_outlined, 'Pengaturan & Keamanan', 'Privasi dan notifikasi akun MatchPoint', [
          _toggle('Pengingat Jadwal Tanding', 'Push notif & WA 2 jam sebelum mabar dimulai.', 0),
          _toggle('Privasi Nomor WhatsApp', 'Sembunyikan nomor dari non-host yang tidak satu sesi.', 1),
          _link(Icons.lock_reset, 'Ubah PIN / Kata Sandi', 'Terakhir diganti 2 minggu yang lalu', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()))),
        ]),
      ],
      SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Simpan Perubahan Data', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: _logout,
          style: OutlinedButton.styleFrom(foregroundColor: C.red, side: const BorderSide(color: Color(0xFFFECACA)), backgroundColor: const Color(0xFFFEF2F2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          icon: const Icon(Icons.logout, size: 18),
          label: Text(admin ? 'Keluar dari Akun (Logout)' : 'Keluar dari Akun (Logout)', style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
      if (admin) ...[
        const SizedBox(height: 14),
        const Center(child: Text('MatchPoint Management System v4.12.0\nGOR Bulutangkis Bandung', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: C.muted))),
      ],
    ]);
  }
}
