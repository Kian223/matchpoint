🏸 MatchPoint - Aplikasi Sewa Lapangan Badminton & Mabar

MatchPoint adalah aplikasi mobile berbasis Flutter yang dirancang khusus untuk manajemen operasional dan pemesanan lapangan di GOR Bulutangkis Bandung. Aplikasi ini menghubungkan pengelola (Admin) dan pemain (Customer) secara real-time dalam satu ekosistem yang mulus.

✨ Fitur Utama

👥 Untuk Pemain (Customer)

Booking Privat Real-Time: Pesan lapangan dan pilih slot jam secara visual. Jam yang sudah lewat atau di-booking orang lain otomatis terkunci.

Open Match (Mabar) & Split Bill: Buat sesi mabar atau gabung dengan pemain selevel. Sistem akan menghitung patungan (biaya lapangan + alat) secara otomatis dibagi jumlah kuota pemain.

Room Chat Eksklusif: Ngobrol langsung dengan Host dan anggota mabar lain di room obrolan khusus setelah sukses bergabung.

Rental Peralatan Tambahan: Tambahkan sewa raket, sepatu, atau shuttlecock langsung saat booking.

E-Tiket QR Dinamis: Dapatkan bukti pesanan. QR Code akan aktif otomatis segera setelah Admin memverifikasi pembayaran.

Rating & Ulasan: Berikan penilaian (1-5 Bintang) untuk kondisi lapangan maupun performa Host Mabar.

💼 Untuk Pengelola GOR (Admin)

Dashboard Operasional: Pantau pendapatan harian, okupansi (tingkat keterisian lapangan), dan pesanan masuk dari satu layar.

Live Monitor Timer & Audio Alert: Awasi sisa waktu main customer. Saat waktu tersisa 5 menit atau habis, alarm otomatis berbunyi (alert.mp3) mengingatkan staf untuk bersiap. Dilengkapi fitur tekan tombol untuk Mute/Unmute.

Manajemen Venue Lengkap (CRUD): Atur status fisik lapangan (Maintenance/Tersedia), tambah stok alat sewa, buka/tutup jam operasional, dan perbarui fasilitas GOR.

Verifikasi Cepat: Terima, tolak, atau batalkan pesanan pelanggan dengan satu ketukan.

Inbox Chat: Layani pertanyaan pelanggan langsung dari dalam aplikasi dengan fitur saran balasan cepat (Auto-Chips).

🛠 Tech Stack & Dependencies

Framework: Flutter (Dart)

State Management: Reactive Store (Singleton / ChangeNotifier berbasis memori untuk dummy data / rapid prototyping)

Audio / Sound: audioplayers (Untuk alert Monitor Timer Admin)

Image / Media: image_picker (Untuk mengubah foto profil dari galeri)

UI Components: Custom Widgets (Animations, Bottom Sheets, Dynamic QR Painter)

📂 Struktur Direktori (Folder Structure)

lib/
├── main.dart                  # Entry point (AppTheme & Splash Page routing)
├── core/                      # Fondasi aplikasi
│   ├── app_colors.dart        # Palet warna
│   ├── facility_icons.dart    # Mapping nama fasilitas -> IconData
│   ├── feedback_service.dart  # Haptic, system click, & alarm.mp3 controller
│   ├── formatters.dart        # Format rupiah, tanggal, jam
│   └── theme.dart             # Konfigurasi ThemeData global
├── data/
│   ├── app_store.dart         # Core State Management (Singleton Data Center)
│   ├── dummy_data.dart        # Inisialisasi awal (User, Lapangan, Room)
│   └── models/                # Struktur data (Booking, Room, User, Promo, dll)
├── screens/
│   ├── admin/                 # Seluruh antarmuka Pengelola GOR
│   ├── auth/                  # Splash Screen, Login, & Register (Validasi)
│   ├── chat/                  # Inbox Admin & Chat Room Personal
│   ├── customer/              # Seluruh antarmuka Pemain (Home, Booking, Mabar)
│   └── profile/               # Edit Data Diri, Image Picker, Ubah Sandi (Admin/Cust)
└── widgets/                   # Komponen Reusable UI
    ├── animations.dart        # FadeSlideIn, Pressable
    ├── banner_carousel.dart   # Promo geser otomatis
    ├── live_builder.dart      # Real-time state rebuilder (Untuk Timer)
    └── main_shell.dart        # Bottom Navigation Kerangka Utama


🚀 Cara Menjalankan Project (Getting Started)

Pastikan Flutter ter-install di komputermu (versi yang mendukung null safety).

Clone / Download repositori ini.

Buka terminal di dalam folder project dan jalankan perintah:

flutter pub get


Catatan Aset Audio & Gambar:
Aplikasi ini membutuhkan file audio untuk fitur alarm Admin. Pastikan struktur foldernya sudah benar, sejajar dengan folder lib:

assets/
  └── sounds/
      └── alert.mp3


Pastikan assets/sounds/ sudah terdaftar dan di-uncomment pada file pubspec.yaml.

Jalankan Aplikasi:

flutter run


(Catatan Demo: Aplikasi saat ini berjalan menggunakan data di dalam memori (Dummy Data). Seluruh perubahan data, akun baru, dan transaksi berjalan sempurna selama aplikasi tidak di-close/restart penuh. Sangat ideal untuk demo UI/UX dan alur bisnis!)
