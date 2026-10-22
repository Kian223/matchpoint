// ============================================================
// FILE   : screens/customer/payment_page.dart
// FUNGSI : Pembayaran
//          Draft transaksi + pilih metode bayar.
// UBAH DI SINI UNTUK: Ubah metode / alur pembayaran.
// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/feedback_service.dart';
import '../../core/formatters.dart';
import '../../data/models/booking.dart';
import '../../widgets/common_widgets.dart';
import 'receipt_page.dart';

class Draft {
  final String title, subtitle;
  final List<(String, int)> lines;
  final Booking Function(String method, int code) commit;
  final int code = 100 + Random().nextInt(900);
  Draft({required this.title, required this.subtitle, required this.lines, required this.commit});
  int get subtotal => lines.fold(0, (a, l) => a + l.$2);
  int get total => subtotal + code;
}

class PaymentPage extends StatefulWidget {
  final Draft d;
  const PaymentPage(this.d, {super.key});
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int m = 0;
  static const methods = [
    ('Transfer BCA', '1234 5678 90 a.n. GOR Bulutangkis Bandung', Icons.account_balance),
    ('QRIS', 'Scan dengan e-wallet / m-banking apa pun', Icons.qr_code_2),
    ('GoPay', '0812-0000-1111 a.n. MatchPoint Bandung', Icons.account_balance_wallet_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          pageHeader(context, 'Pembayaran'),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              card(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(d.subtitle, style: const TextStyle(fontSize: 11, color: C.muted)),
                  const Divider(height: 22),
                  for (final l in d.lines) summaryRow(l.$1, rupiah(l.$2)),
                  summaryRow('Kode Unik Verifikasi', '+${d.code}', c: C.green),
                  const Divider(height: 22),
                  summaryRow('TOTAL DITRANSFER', rupiah(d.total), bold: true),
                ]),
              ),
              const SizedBox(height: 16),
              sectionTitle('Metode Pembayaran'),
              for (var i = 0; i < methods.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => m = i),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: m == i ? C.primary : C.border, width: m == i ? 1.6 : 1)),
                      child: Row(children: [
                        Icon(methods[i].$3),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(methods[i].$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          Text(methods[i].$2, style: const TextStyle(fontSize: 10, color: C.muted)),
                        ])),
                        Icon(m == i ? Icons.radio_button_checked : Icons.radio_button_off, color: C.primary, size: 20),
                      ]),
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              const Text('Transfer sesuai total (termasuk kode unik). Admin akan memverifikasi pembayaranmu setelah kamu menekan tombol di bawah.', style: TextStyle(fontSize: 10, color: C.muted)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: C.lime, foregroundColor: C.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  final b = d.commit(methods[m].$1, d.code);
                  FeedbackService.booking(); // getar + bunyi saat pemesanan dibuat
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ReceiptPage(b)));
                },
                child: Text('Saya Sudah Bayar • ${rupiah(d.total)}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
