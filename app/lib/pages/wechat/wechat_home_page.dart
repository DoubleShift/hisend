import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/pages/wechat/conversations_page.dart';
import 'package:localsend_app/pages/wechat/discover_page.dart';
import 'package:localsend_app/pages/wechat/me_page.dart';
import 'package:localsend_app/pages/wechat/contacts_page.dart';

enum WeChatTab {
  conversations(Icons.chat_bubble_outline, Icons.chat_bubble),
  contacts(Icons.people_outline, Icons.people),
  discover(Icons.explore_outlined, Icons.explore),
  me(Icons.person_outline, Icons.person);

  const WeChatTab(this.icon, this.activeIcon);

  final IconData icon;
  final IconData activeIcon;

  String get label {
    switch (this) {
      case WeChatTab.conversations:
        return '微信';
      case WeChatTab.contacts:
        return '通讯录';
      case WeChatTab.discover:
        return '发现';
      case WeChatTab.me:
        return '我的';
    }
  }
}

class WeChatHomePage extends StatefulWidget {
  const WeChatHomePage({super.key});

  @override
  State<WeChatHomePage> createState() => _WeChatHomePageState();
}

class _WeChatHomePageState extends State<WeChatHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ConversationsPage(),
    const ContactsPage(),
    const DiscoverPage(),
    const MePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: WeChatTab.values.map((tab) {
          return NavigationDestination(
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.activeIcon),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}
