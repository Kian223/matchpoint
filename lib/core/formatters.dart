// ============================================================
// FILE   : core/formatters.dart
// FUNGSI : Fungsi format
//          rupiah(), tanggal(), jam(), countdown(), dll.
// UBAH DI SINI UNTUK: Ubah format tampilan uang / tanggal / waktu.
// ============================================================

// ====== HELPER FORMAT ======
String rupiah(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp $buf';
}

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

const _bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

String tanggal(DateTime d) => '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]} ${d.year}';

String tanggalPendek(DateTime d) => '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]}';

String hariSingkat(DateTime d) => _hari[d.weekday - 1].substring(0, 3).toUpperCase();

String bulanTahun(DateTime d) => '${_bulan[d.month - 1]} ${d.year}';

String jam(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String hariLabel(DateTime d) {
  final n = DateTime.now();
  if (sameDay(d, n)) return 'Hari Ini';
  if (sameDay(d, DateTime(n.year, n.month, n.day + 1))) return 'Besok';
  return tanggalPendek(d);
}

String countdown(Duration d) {
  if (d.isNegative) d = Duration.zero;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
}
