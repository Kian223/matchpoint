// ============================================================
// FILE   : widgets/main_shell.dart
// FUNGSI : Kerangka navigasi bawah
//          Tab Beranda / Chat / Profil untuk admin dan customer.
// UBAH DI SINI UNTUK: Tambah / ubah tab navigasi.
// ============================================================

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../data/app_store.dart';
import '../data/models/user.dart';
import '../screens/chat/admin_chat_inbox.dart';
import '../screens/chat/chat_page.dart';
import '../screens/profile/profile_page.dart';

/// Shell dengan bottom bar Beranda / Chat / Profil (dipakai Admin & Customer).
class MainShell extends StatefulWidget {
  final Widget home;
  const MainShell({super.key, required this.home});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final s = AppStore.I;
    final admin = s.current?.role == Role.admin;
    final Widget page = i == 0
        ? widget.home
        : i == 1
            ? (admin ? const AdminChatInbox() : ChatPage(customerEmail: s.current!.email, embedded: true))
            : const ProfilePage();
    const items = [
      (Icons.sports_tennis, 'Beranda'),
      (Icons.chat_bubble_outline_rounded, 'Chat'),
      (Icons.person_outline_rounded, 'Profil'),
    ];
    return Scaffold(
      body: SafeArea(child: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: KeyedSubtree(key: ValueKey(i), child: page))),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.border))),
        child: SafeArea(
          child: Row(
            children: [
              for (var k = 0; k < items.length; k++)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => i = k),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        k == 1
                            ? ListenableBuilder(
                                listenable: s,
                                builder: (_, __) => Badge(
                                  isLabelVisible: s.chatUnread > 0,
                                  label: Text('${s.chatUnread}'),
                                  child: Icon(items[k].$1, color: i == k ? C.primary : C.muted),
                                ),
                              )
                            : Icon(items[k].$1, color: i == k ? C.primary : C.muted),
                        const SizedBox(height: 2),
                        Text(items[k].$2, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: i == k ? C.primary : C.muted)),
                      ]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
