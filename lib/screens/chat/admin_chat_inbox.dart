// ============================================================
// FILE   : screens/chat/admin_chat_inbox.dart
// FUNGSI : Inbox chat admin
//          Daftar customer + pesan terakhir + badge belum dibaca.
// UBAH DI SINI UNTUK: —
// ============================================================

import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/formatters.dart';
import '../../data/app_store.dart';
import '../../data/models/user.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/user_avatar.dart';
import 'chat_page.dart';

/// Inbox admin: daftar customer + pesan terakhir + badge belum dibaca.
class AdminChatInbox extends StatelessWidget {
  const AdminChatInbox({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppStore.I;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final customers = s.users.where((u) => u.role == Role.customer).toList();
        DateTime last(AppUser u) {
          final t = s.thread(u.email);
          return t.isEmpty ? DateTime.fromMillisecondsSinceEpoch(0) : t.last.at;
        }
        customers.sort((a, b) => last(b).compareTo(last(a)));
        return Column(children: [
          const Padding(padding: EdgeInsets.fromLTRB(16, 14, 16, 8), child: Row(children: [Text('Chat Customer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))])),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), children: [
              for (final u in customers)
                Builder(builder: (_) {
                  final t = s.thread(u.email);
                  final unread = t.where((m) => !m.fromAdmin && !m.read).length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(customerEmail: u.email))),
                      child: card(
                        child: Row(children: [
                          UserAvatar(u.name, email: u.email, r: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(u.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(t.isEmpty ? 'Belum ada percakapan' : '${t.last.fromAdmin ? 'Kamu: ' : ''}${t.last.text}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: unread > 0 ? Colors.black87 : C.muted, fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w500)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            if (t.isNotEmpty) Text(jam(t.last.at), style: const TextStyle(fontSize: 9, color: C.muted)),
                            const SizedBox(height: 4),
                            if (unread > 0) CircleAvatar(radius: 9, backgroundColor: C.red, child: Text('$unread', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800))),
                          ]),
                        ]),
                      ),
                    ),
                  );
                }),
            ]),
          ),
        ]);
      },
    );
  }
}
