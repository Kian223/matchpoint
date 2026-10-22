// ============================================================
// FILE   : data/app_store.dart
// FUNGSI : Pusat data & logika (AppStore)
//          Satu-satunya sumber data: akun, booking, room, chat, rating, banner, fasilitas, jam, notifikasi.
//           Admin dan customer membaca data yang sama, jadi perubahan langsung terlihat di kedua sisi.
// UBAH DI SINI UNTUK: Ubah aturan bisnis (harga, validasi, alur pesanan).
// ============================================================

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../core/feedback_service.dart';
import '../core/formatters.dart';
import 'dummy_data.dart';
import 'models/app_notification.dart';
import 'models/booking.dart';
import 'models/chat_message.dart';
import 'models/court.dart';
import 'models/equipment.dart';
import 'models/facility.dart';
import 'models/promo_banner.dart';
import 'models/rating.dart';
import 'models/room.dart';
import 'models/room_message.dart';
import 'models/user.dart';

/// Satu sumber data untuk Admin & Customer (nanti bisa diganti Firebase/API).
class AppStore extends ChangeNotifier {
  static final AppStore I = AppStore._();
  AppStore._() {
    Timer.periodic(const Duration(seconds: 5), (_) => _tick());
  }

  final users = DummyData.users();
  AppUser? current;

  final courts = DummyData.courts();

  /// Jam yang sudah terisi (booking offline/langganan) di setiap hari — data dummy.
  final blocked = DummyData.blockedHours;

  final bookings = <Booking>[];
  final notifs = <Notif>[];
  late final List<Room> rooms = DummyData.rooms(courts);


  // ====== AUTH ======
  AppUser? login(String id, String pass) {
    final key = id.trim().toLowerCase();
    for (final u in users) {
      if ((u.email == key || normalizePhone(u.phone) == normalizePhone(id)) && u.password == pass) {
        current = u;
        if (unread > 0) FeedbackService.notify();
        notifyListeners();
        return u;
      }
    }
    return null;
  }

  void logout() {
    current = null;
    notifyListeners();
  }

  // ====== CHAT ======
  late final List<ChatMsg> chats = DummyData.chats();

  List<ChatMsg> thread(String email) =>
      chats.where((m) => m.customerEmail == email).toList()..sort((a, b) => a.at.compareTo(b.at));

  void sendChat(String email, String text, {required bool fromAdmin}) {
    chats.add(ChatMsg(email, text, fromAdmin, DateTime.now()));
    notifyListeners();
  }

  /// Tandai pesan lawan bicara sebagai terbaca.
  void readChat(String email, {required bool byAdmin}) {
    var changed = false;
    for (final m in chats) {
      if (m.customerEmail == email && m.fromAdmin != byAdmin && !m.read) {
        m.read = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  int get chatUnread {
    final u = current;
    if (u == null) return 0;
    return u.role == Role.admin
        ? chats.where((m) => !m.fromAdmin && !m.read).length
        : chats.where((m) => m.customerEmail == u.email && m.fromAdmin && !m.read).length;
  }

  // ====== PROFIL ======
  void updateProfile() => notifyListeners();

  /// Mengembalikan pesan error, atau null bila berhasil.
  String? changePassword(String old, String neu) {
    final u = current;
    if (u == null) return 'Sesi berakhir, silakan login ulang';
    if (old != u.password) return 'Kata sandi lama salah';
    if (neu == old) return 'Kata sandi baru tidak boleh sama dengan yang lama';
    u.password = neu;
    notifyListeners();
    return null;
  }

  // ====== NOTIFIKASI ======
  String get inbox => current == null ? '' : (current!.role == Role.admin ? 'admin' : current!.email);
  List<Notif> get myNotifs => notifs.where((n) => n.to == inbox).toList().reversed.toList();
  int get unread => notifs.where((n) => n.to == inbox && !n.read).length;
  void markRead() {
    for (final n in notifs) {
      if (n.to == inbox) n.read = true;
    }
    notifyListeners();
  }

  /// Menambah notifikasi. Bila untuk akun yang sedang login, perangkat bergetar + berbunyi.
  void _notify(String to, String text) {
    notifs.add(Notif(to, text));
    if (to == inbox) FeedbackService.notify();
  }

  // ====== KETERSEDIAAN ======
  bool slotTaken(Court c, DateTime slot) {
    if (c.status != CourtStatus.aman || (blocked[c.no]?.contains(slot.hour) ?? false)) return true;
    bool inside(DateTime s, DateTime e) => !slot.isBefore(s) && slot.isBefore(e);
    for (final b in bookings) {
      if (!b.isShare && !b.dead && b.court.no == c.no && inside(b.start, b.end)) return true;
    }
    for (final r in rooms) {
      if (r.court.no == c.no && inside(r.start, r.end)) return true;
    }
    return false;
  }

  // ====== TRANSAKSI ======
  String _id() => 'BNP-${(bookings.length + 1).toString().padLeft(4, '0')}';

  Booking _add(Booking b, String what) {
    bookings.add(b);
    _notify('admin', 'Pesanan baru ${b.id} dari ${b.customerName}: $what (${rupiah(b.price)}) menunggu verifikasi.');
    _notify(b.customerEmail, 'Terima kasih telah melakukan penyewaan lapangan di GOR Bandung. Untuk informasi lebih lanjut, dapat dilihat di menu Home.');
    notifyListeners();
    return b;
  }

  int _sum(List<(String, int)> l) => l.fold(0, (a, e) => a + e.$2);

  Booking bookPrivate(AppUser u, Court c, DateTime s, DateTime e, List<(String, int)> lines, int code, String method) =>
      _add(Booking(_id(), u.email, u.name, c, s, e, _sum(lines), title: 'Sewa Privat', lines: lines, code: code, method: method),
          'Sewa Privat ${c.name} ${tanggalPendek(s)} ${jam(s)}-${jam(e)}');

  Booking createRoom(AppUser u, Room r, List<(String, int)> lines, int code, String method) {
    rooms.add(r);
    _roomSystemMsg(r, 'Room dibuat oleh ${u.name}. Selamat bermain!');
    return _add(
        Booking(_id(), u.email, u.name, r.court, r.start, r.end, _sum(lines), title: 'Mabar (Host)', type: BookingType.mabar, roomId: r.id, roomTitle: r.title, lines: lines, code: code, method: method),
        'Host room mabar "${r.title}" di ${r.court.name}');
  }

  Booking joinRoom(AppUser u, Room r, List<(String, int)> lines, int code, String method) {
    r.players.add(Player(u.name, u.email, u.level));
    _roomSystemMsg(r, '${u.name} bergabung ke room.');
    return _add(
        Booking(_id(), u.email, u.name, r.court, r.start, r.end, _sum(lines), title: 'Patungan Mabar', type: BookingType.mabar, isShare: true, roomId: r.id, roomTitle: r.title, lines: lines, code: code, method: method),
        'Patungan join room "${r.title}"');
  }

  void setStatus(Booking b, BookingStatus s) {
    b.status = s;
    if ((s == BookingStatus.rejected || s == BookingStatus.cancelled) && b.roomId != null) {
      for (final r in rooms.where((r) => r.id == b.roomId).toList()) {
        if (b.isShare) {
          r.players.removeWhere((p) => p.email == b.customerEmail);
        } else {
          rooms.remove(r);
        }
      }
    }
    _notify(b.customerEmail, switch (s) {
      BookingStatus.confirmed => 'Pesanan ${b.id} (${b.court.name}) disetujui admin. Tiket siap digunakan!',
      BookingStatus.cancelled => 'Pesanan ${b.id} dibatalkan oleh admin GOR. Hubungi petugas untuk info lebih lanjut.',
      _ => 'Pesanan ${b.id} ditolak admin. Hubungi petugas GOR untuk info lebih lanjut.',
    });
    notifyListeners();
  }

  // ====== REGISTRASI ======
  /// Merapikan nomor WA: buang spasi/tanda, ubah +62 / 62 menjadi 0.
  static String normalizePhone(String p) {
    var s = p.replaceAll(RegExp(r'[\s\-().]'), '');
    if (s.startsWith('+62')) {
      s = '0${s.substring(3)}';
    } else if (s.startsWith('62')) {
      s = '0${s.substring(2)}';
    }
    return s;
  }

  /// Membuat akun customer baru. Mengembalikan pesan error, atau null bila berhasil.
  String? register({required String name, required String email, required String phone, required String password, required String level}) {
    final e = email.trim().toLowerCase();
    final ph = normalizePhone(phone);
    if (users.any((u) => u.email == e)) return 'Email sudah terdaftar';
    if (users.any((u) => normalizePhone(u.phone) == ph)) return 'Nomor WhatsApp sudah terdaftar';
    users.add(AppUser(name.trim(), e, ph, password, Role.customer, level: level));
    chats.add(ChatMsg(e, 'Halo kak ${name.trim()}! Selamat datang di MatchPoint Bandung. Ada yang bisa kami bantu?', true, DateTime.now()));
    _notify(e, 'Selamat datang di MatchPoint Bandung, ${name.trim()}! Yuk pesan lapangan pertamamu.');
    notifyListeners();
    return null;
  }

  /// Foto profil milik email tertentu (null bila belum ada).
  Uint8List? photoOf(String email) => users.where((u) => u.email == email).firstOrNull?.photo;

  // ====== JAM OPERASIONAL ======
  /// Jam mulai (format 24 jam) yang bisa dipesan. Admin mengubahnya di Kelola Venue > Jam.
  final List<int> openHours = [for (var h = 8; h <= 22; h++) h];
  static final List<int> allHours = [for (var h = 6; h <= 23; h++) h];

  void toggleHour(int h) {
    if (openHours.contains(h)) {
      if (openHours.length > 1) openHours.remove(h); // minimal 1 jam tetap buka
    } else {
      openHours
        ..add(h)
        ..sort();
    }
    notifyListeners();
  }

  void resetHours() {
    openHours
      ..clear()
      ..addAll([for (var h = 8; h <= 22; h++) h]);
    notifyListeners();
  }

  // ====== BANNER PROMO (maksimal 4) ======
  static const maxBanners = 4;
  final banners = DummyData.banners();
  List<PromoBanner> get activeBanners => banners.where((b) => b.active).toList();
  bool get canAddBanner => banners.length < maxBanners;

  /// Simpan banner baru / hasil edit (dicocokkan lewat id).
  void saveBanner(PromoBanner b) {
    final i = banners.indexWhere((x) => x.id == b.id);
    if (i >= 0) {
      banners[i] = b;
    } else if (canAddBanner) {
      banners.add(b);
    }
    notifyListeners();
  }

  void deleteBanner(PromoBanner b) {
    banners.remove(b);
    notifyListeners();
  }

  void setBannerActive(PromoBanner b, bool v) {
    b.active = v;
    notifyListeners();
  }

  // ====== FASILITAS GOR ======
  final facilities = DummyData.facilities();

  void addFacility(String name, String iconKey) {
    facilities.add(Facility('F${DateTime.now().microsecondsSinceEpoch}', name, iconKey));
    notifyListeners();
  }

  void deleteFacility(Facility f) {
    facilities.remove(f);
    notifyListeners();
  }

  // ====== RATING & ULASAN ======
  final ratings = <Rating>[];

  bool hasRated(Booking b) => ratings.any((r) => r.bookingId == b.id);

  void addRating(Booking b, int stars, String comment) {
    final room = rooms.where((r) => r.id == b.roomId).firstOrNull;
    final isRoom = b.type == BookingType.mabar;
    final target = isRoom ? (b.roomTitle.isEmpty ? 'Room Mabar' : b.roomTitle) : b.court.name;
    ratings.add(Rating(
      id: 'RT${ratings.length + 1}', bookingId: b.id, raterEmail: b.customerEmail, raterName: b.customerName,
      targetName: target, comment: comment, isRoom: isRoom, hostEmail: room?.hostEmail, stars: stars, at: DateTime.now(),
    ));
    _notify('admin', 'Rating baru $stars bintang dari ${b.customerName} untuk $target.');
    notifyListeners();
  }

  int get ratingCount => ratings.length;
  double get avgRating => ratings.isEmpty ? 0 : ratings.fold(0, (a, r) => a + r.stars) / ratings.length;

  /// Rating host = rata-rata ulasan room miliknya; bila belum ada ulasan pakai nilai awal room.
  double hostRating(Room r) {
    final l = ratings.where((x) => x.isRoom && x.hostEmail == r.hostEmail).toList();
    return l.isEmpty ? r.rating : l.fold(0, (a, x) => a + x.stars) / l.length;
  }

  // ====== CHAT ROOM MABAR ======
  late final List<RoomMsg> roomMsgs = DummyData.roomMessages();

  List<RoomMsg> roomThread(String roomId) => roomMsgs.where((m) => m.roomId == roomId).toList()..sort((a, b) => a.at.compareTo(b.at));

  void sendRoomMsg(Room r, AppUser u, String text) {
    roomMsgs.add(RoomMsg(roomId: r.id, senderEmail: u.email, senderName: u.name, text: text, at: DateTime.now()));
    notifyListeners();
  }

  void _roomSystemMsg(Room r, String text) =>
      roomMsgs.add(RoomMsg(roomId: r.id, senderEmail: '', senderName: 'Sistem', text: text, at: DateTime.now(), system: true));

  // ====== ADMIN: PESANAN, TIMER, VENUE, ALAT ======
  void cancelBooking(Booking b) => setStatus(b, BookingStatus.cancelled);

  /// MODE UJI (untuk demo / pengetesan): langsung membuat sesi 1 jam yang sudah disetujui,
  /// dengan sisa waktu [remaining] dari sekarang. Nilai negatif = waktu sudah lewat.
  /// Dipakai tombol "Mode Uji" di Monitor Timer supaya alarm & countdown bisa dites tanpa menunggu berjam-jam.
  /// Hapus method ini + kartu "Mode Uji" di monitor_timer_page.dart bila tidak diperlukan.
  String? createTestSession(Duration remaining) {
    final court = courts.where((c) => c.status == CourtStatus.aman && liveOn(c) == null && overdueOn(c) == null).firstOrNull;
    if (court == null) return 'Tidak ada lapangan kosong untuk sesi uji. Akhiri sesi yang berjalan dulu.';
    final customer = users.firstWhere((u) => u.role == Role.customer);
    final end = DateTime.now().add(remaining);
    final b = Booking(_id(), customer.email, customer.name, court, end.subtract(const Duration(hours: 1)), end, court.price,
        title: 'Sesi Uji (Demo)', lines: [('Sewa ${court.name} (sesi uji)', court.price)], method: 'Transfer BCA');
    b.status = BookingStatus.confirmed;
    bookings.add(b);
    _notify(customer.email, 'Sesi uji dibuat di ${court.name}.');
    notifyListeners();
    return null;
  }

  void endEarly(Booking b) {
    b.finished = true;
    b.endedAt = DateTime.now();
    _notify(b.customerEmail, 'Sesi ${b.court.name} diakhiri oleh admin. Terima kasih sudah bermain di GOR Bandung!');
    notifyListeners();
  }

  /// Pengawasan otomatis: peringatan 5 menit sebelum dan 5 menit sesudah waktu sewa habis.
  void _tick() {
    final now = DateTime.now();
    var changed = false;
    for (final b in bookings) {
      if (b.status != BookingStatus.confirmed || b.isShare || b.finished) continue;
      
      // Peringatan sisa 5 menit
      if (!b.warnedBefore && !now.isBefore(b.end.subtract(const Duration(minutes: 5)))) {
        b.warnedBefore = true;
        if (now.isBefore(b.end)) {
          FeedbackService.alarm(); // <--- TAMBAHAN ALARM
          _notify('admin', 'PERINGATAN: ${b.court.name} sisa waktu 5 menit (${b.customerName}). Siapkan pergantian sesi.');
          _notify(b.customerEmail, 'Waktu sewa ${b.court.name} tersisa 5 menit. Terima kasih sudah bermain di GOR Bandung!');
          changed = true;
        }
      }
      
      // Peringatan waktu habis (lewat 5 menit)
      if (!b.warnedAfter && !now.isBefore(b.end.add(const Duration(minutes: 5)))) {
        b.warnedAfter = true;
        if (now.isBefore(b.end.add(const Duration(minutes: 60)))) {
          FeedbackService.alarm(); // <--- TAMBAHAN ALARM
          _notify('admin', 'WAKTU HABIS: ${b.court.name} sudah lewat 5 menit dari jadwal (${b.customerName}). Segera cek lapangan atau akhiri sesi.');
          _notify(b.customerEmail, 'Waktu sewa ${b.court.name} sudah habis. Mohon segera mengosongkan lapangan.');
          changed = true;
        }
      }
    }
    
    // ... (sisa kode ratingAsked dibiarkan sama seperti aslinya)
    // Sesi selesai -> ajak customer memberi rating (sekali saja per booking)
    for (final b in bookings) {
      if (b.ratingAsked || !b.isEnded) continue;
      b.ratingAsked = true;
      _notify(b.customerEmail, 'Sesi di ${b.court.name} sudah selesai. Yuk beri rating, lihat di menu Home!');
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Booking? overdueOn(Court c) {
    for (final b in bookings) {
      if (b.court.no == c.no && b.isOverdue) return b;
    }
    return null;
  }

  /// Pesanan (menunggu / disetujui) hari ini yang akan atau sedang memakai lapangan.
  Booking? nextOn(Court c) {
    final now = DateTime.now();
    Booking? best;
    for (final b in bookings) {
      if (b.court.no != c.no || b.isShare || b.dead || b.finished || !b.end.isAfter(now) || !_today(b.start)) continue;
      if (b.isLive) continue;
      if (best == null || b.start.isBefore(best.start)) best = b;
    }
    return best;
  }

  void setCourtStatus(Court c, CourtStatus st) {
    c.status = st;
    notifyListeners();
  }

  void updateCourt(Court c, String type, int price) {
    c.type = type;
    c.price = price;
    notifyListeners();
  }

  void addCourt(String type, int price) {
    final no = courts.fold(0, (m, c) => c.no > m ? c.no : m) + 1;
    courts.add(Court(no, type, price));
    notifyListeners();
  }

  String? deleteCourt(Court c) {
    final now = DateTime.now();
    if (bookings.any((b) => b.court.no == c.no && !b.dead && !b.finished && b.end.isAfter(now)) ||
        rooms.any((r) => r.court.no == c.no && r.end.isAfter(now))) {
      return 'Masih ada pesanan aktif di ${c.name}. Batalkan dulu pesanannya.';
    }
    courts.remove(c);
    notifyListeners();
    return null;
  }

  final equipment = DummyData.equipment();

  void upsertEquipment({String? id, required String name, required String desc, required String unit, required int price, required int stock}) {
    final i = equipment.indexWhere((e) => e.id == id);
    if (i >= 0) {
      equipment[i]
        ..name = name
        ..desc = desc
        ..unit = unit
        ..price = price
        ..stock = stock;
    } else {
      equipment.add(Equipment('E${DateTime.now().microsecondsSinceEpoch}', name, desc, unit, price, stock));
    }
    notifyListeners();
  }

  void setEquipmentActive(Equipment e, bool v) {
    e.active = v;
    notifyListeners();
  }

  void deleteEquipment(Equipment e) {
    equipment.remove(e);
    notifyListeners();
  }

  // ====== STATISTIK ADMIN ======
  bool _today(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  List<Booking> get pending => bookings.where((b) => b.status == BookingStatus.pending).toList();
  List<Booking> get confirmedToday => bookings.where((b) => b.status == BookingStatus.confirmed && _today(b.start)).toList();
  List<Booking> get sessionsToday => confirmedToday.where((b) => !b.isShare).toList();
  int get incomeToday => confirmedToday.fold(0, (s, b) => s + b.price);
  int get hoursToday => sessionsToday.fold(0, (s, b) => s + b.hours);
  int get courtsFilled => sessionsToday.map((b) => b.court.no).toSet().length;
  Booking? liveOn(Court c) {
    for (final b in bookings) {
      if (b.court.no == c.no && b.isLive) return b;
    }
    return null;
  }

  List<Booking> bookingsOf(String email) =>
      bookings.where((b) => b.customerEmail == email && !b.dead).toList()
        ..sort((a, b) => a.start.compareTo(b.start));
}