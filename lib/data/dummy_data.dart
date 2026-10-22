// ============================================================
// FILE   : data/dummy_data.dart
// FUNGSI : Data dummy
//          Data awal pengganti database (akun demo, lapangan, alat, room, banner, fasilitas).
// UBAH DI SINI UNTUK: Ganti akun demo / tarif / data awal.
// ============================================================

import 'models/chat_message.dart';
import 'models/court.dart';
import 'models/equipment.dart';
import 'models/facility.dart';
import 'models/promo_banner.dart';
import 'models/room.dart';
import 'models/room_message.dart';
import 'models/user.dart';

/// DATA DUMMY (pengganti database sementara).
/// Semua data awal aplikasi ada di sini: akun, lapangan, alat sewa, room mabar, banner, fasilitas, chat.
/// Saat nanti pindah ke Firebase/API, bagian ini yang diganti dengan pengambilan data dari server.
class DummyData {
  /// Akun demo. Customer: deffa / budi (sandi 123456). Admin: admin (sandi admin123).
  static List<AppUser> users() => [
        AppUser('Deffa Kiane', 'deffa@gmail.com', '0812', '123', Role.customer,
            level: 'Intermediate',
            bio: 'Pemain ganda campuran & ganda putra santai di Bandung. Suka main rally cepat dan fun sparring tiap weekend malam!',
            racket: 'Yonex Astrox 77 Pro / Victor Thruster K',
            shoe: '42 (Non-marking Court Shoes)',
            homeBase: 'GOR Bulutangkis Bandung (Court 1 & 2 Vinyl)',
            instagram: 'deffa.kiane',
            types: {'Ganda Putra (MD)', 'Ganda Campuran (XD)'}),
        AppUser('Budi', 'budi@gmail.com', '0813', '123', Role.customer,
            level: 'Beginner', bio: 'Baru belajar badminton, cari teman mabar santai.', shoe: '41', racket: 'Li-Ning Windstorm'),
        AppUser('Suherman', 'admin@gmail.com', '0814', '123', Role.admin,
            title: 'Supervisor Operasional Lapangan', nip: 'STF-GOR005-004',
            bio: 'Supervisor operasional GOR Bulutangkis Bandung sejak 2021. Bertanggung jawab atas keluhan karpet court, kelistrikan IoT.'),
      ];

  /// 4 lapangan: no, tipe lantai, tarif per jam. Court 4 sedang maintenance.
  static List<Court> courts() => [
        Court(1, 'Karpet', 60000),
        Court(2, 'Vinyl', 75000),
        Court(3, 'Parquet', 80000),
        Court(4, 'Karpet', 60000, maintenance: true),
      ];

  /// Jam yang sudah terisi (booking offline/langganan) tiap hari: nomor court -> jam mulai.
  static const Map<int, Set<int>> blockedHours = {1: {8, 10, 15}, 2: {9, 16}, 3: {12, 13}, 4: <int>{}};

  static List<Equipment> equipment() => [
        Equipment('E1', 'Yonex Astrox 77 Play', 'Tahan 28-38 lbs • Berat 83gr', 'pcs', 25000, 10),
        Equipment('E2', 'Sepatu Badminton Mizuno', 'Ukuran 38-44 (pilih di resepsionis)', 'pasang', 20000, 8),
        Equipment('E3', 'Kok Slazenger Pro Tournament', '1 Slop (12 pcs) bulu angsa', 'slop', 90000, 15),
      ];

  /// 3 room mabar contoh dari host lain (tanggal dihitung dari hari ini).
  static List<Room> rooms(List<Court> courts) {
    final n = DateTime.now();
    final d0 = n.hour < 18 ? DateTime(n.year, n.month, n.day) : DateTime(n.year, n.month, n.day + 1);
    DateTime at(int plus, int h) => DateTime(d0.year, d0.month, d0.day + plus, h);
    Player p(String name, String lv) => Player(name, '${name.toLowerCase().replaceAll(' ', '.')}@mail.com', lv);
    return [
      Room(id: 'R1', title: 'Mabar Ganda Putra/Campuran', format: 'Game Bebas', level: 'Intermediate',
          note: 'Wajib bawa sepatu non-marking. Main santai tapi kompetitif, rolling partner tiap game.',
          hostName: 'Kevin S.', hostEmail: 'kevin.s@mail.com', rating: 4.9, sessions: 24, quota: 8,
          courtFee: 225000, facilityFee: 55000, court: courts[1], start: at(0, 19), end: at(0, 22),
          facilities: ['Kok Baru Gratis', 'Wasit & Skor GOR'],
          players: [p('Kevin S.', 'Advanced'), p('Hendra Setiawan', 'Advanced'), p('Rina Aulia', 'Intermediate'), p('Doni Pratama', 'Intermediate'), p('Siska Maharani', 'Beginner'), p('Bayu Tri', 'Intermediate')]),
      Room(id: 'R2', title: 'Morning Smash Fun Beginner', format: 'Fun Sparring', level: 'Beginner',
          note: 'Cocok untuk yang baru mulai, santai dan seru!',
          hostName: 'Siti Rahma', hostEmail: 'siti.rahma@mail.com', rating: 4.8, sessions: 18, quota: 4,
          courtFee: 160000, facilityFee: 0, court: courts[2], start: at(1, 8), end: at(1, 10),
          facilities: ['Bawa Raket Sendiri'],
          players: [p('Siti Rahma', 'Beginner'), p('Intan Permata', 'Beginner'), p('Rafi Alamsyah', 'Beginner')]),
      Room(id: 'R3', title: 'Rally Night Advanced Doubles', format: 'Ganda Putra', level: 'Advanced',
          note: 'Intensitas tinggi, minimal paham rotasi ganda.',
          hostName: 'Andre W.', hostEmail: 'andre.w@mail.com', rating: 4.7, sessions: 31, quota: 6,
          courtFee: 120000, facilityFee: 40000, court: courts[0], start: at(2, 20), end: at(2, 22),
          facilities: ['Kok Baru Gratis'],
          players: [p('Andre W.', 'Advanced'), p('Yoga Pratama', 'Advanced'), p('Fajar Nugroho', 'Advanced'), p('Lukas H.', 'Advanced')]),
    ];
  }

  /// Pesan awal di chat room (supaya chat room tidak kosong saat demo).
  static List<RoomMsg> roomMessages() {
    final n = DateTime.now();
    RoomMsg m(String room, String name, String text, int minAgo) => RoomMsg(
        roomId: room, senderEmail: '${name.toLowerCase().replaceAll(' ', '.')}@mail.com', senderName: name, text: text, at: n.subtract(Duration(minutes: minAgo)));
    return [
      m('R1', 'Kevin S.', 'Halo semua! Jangan lupa bawa sepatu non-marking ya.', 55),
      m('R1', 'Hendra Setiawan', 'Siap bang, nanti rolling partner tiap game kan?', 40),
      m('R1', 'Kevin S.', 'Betul, santai tapi tetap kompetitif.', 35),
      m('R2', 'Siti Rahma', 'Selamat datang di Morning Smash! Kita mulai tepat waktu ya.', 120),
    ];
  }

  /// Sapaan awal admin di chat customer.
  static List<ChatMsg> chats() => [
        ChatMsg('deffa@matchpoint.com', 'Halo kak Deffa! Selamat datang di MatchPoint Bandung. Ada yang bisa kami bantu?', true, DateTime.now().subtract(const Duration(minutes: 30))),
        ChatMsg('budi@matchpoint.com', 'Halo kak Budi! Kalau ada pertanyaan soal sewa lapangan atau mabar, chat kami di sini ya.', true, DateTime.now().subtract(const Duration(hours: 2))),
      ];

  /// Banner promo awal (maksimal 4, dikelola admin).
  static List<PromoBanner> banners() => [
        PromoBanner(id: 'B1', title: 'Promo Weekend Smashing', subtitle: 'Diskon 20% Lapangan Vinyl Pro standar BWF untuk sesi malam.', code: 'SMASHBDG', gradient: 0),
        PromoBanner(id: 'B2', title: 'Gratis Kok untuk Mabar Pertama', subtitle: 'Buat room mabar pertamamu dan dapatkan 1 slop kok gratis.', code: 'MABARBARU', gradient: 1),
      ];

  /// Fasilitas GOR awal (iconKey lihat core/facility_icons.dart).
  static List<Facility> facilities() => [
        Facility('F1', 'Mushola', 'mushola'),
        Facility('F2', 'Parkir Luas', 'parkir'),
        Facility('F3', 'Toilet & Ganti', 'toilet'),
        Facility('F4', 'Kantin & Kafe', 'kantin'),
        Facility('F5', 'WiFi Gratis', 'wifi'),
        Facility('F6', 'Locker', 'locker'),
      ];
}
