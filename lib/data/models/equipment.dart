// ============================================================
// FILE   : data/models/equipment.dart
// FUNGSI : Model alat sewa
//          Equipment (nama, tarif, stok).
// UBAH DI SINI UNTUK: Tambah atribut alat.
// ============================================================

class Equipment {
  String id, name, desc, unit;
  int price, stock;
  bool active;
  Equipment(this.id, this.name, this.desc, this.unit, this.price, this.stock, [this.active = true]);
}
