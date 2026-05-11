import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/config/init.dart';
import 'package:localsend_app/pages/huawei/devices_page.dart';
import 'package:localsend_app/pages/huawei/me_page.dart';
import 'package:refena_flutter/refena_flutter.dart';

enum HuaweiTab {
  devices(Icons.devices_outlined, Icons.devices),
  me(Icons.person_outline, Icons.person);

  const HuaweiTab(this.icon, this.activeIcon);

  final IconData icon;
  final IconData activeIcon;

  String get label {
    switch (this) {
      case HuaweiTab.devices:
        return '设备';
      case HuaweiTab.me:
        return '我的';
    }
  }
}

class HuaweiTabVm {
  final HuaweiTab currentTab;
  final void Function(HuaweiTab) changeTab;

  HuaweiTabVm({
    required this.currentTab,
    required this.changeTab,
  });
}

final huaweiTabControllerProvider = ReduxProvider<HuaweiTabController, HuaweiTabVm>(
  (ref) => HuaweiTabController(),
);

class HuaweiTabController extends ReduxNotifier<HuaweiTabVm> {
  @override
  HuaweiTabVm init() {
    return HuaweiTabVm(
      currentTab: HuaweiTab.devices,
      changeTab: (tab) => redux.dispatch(HuaweiChangeTabAction(tab)),
    );
  }
}

class HuaweiChangeTabAction extends ReduxAction<HuaweiTabController, HuaweiTabVm> {
  final HuaweiTab tab;

  HuaweiChangeTabAction(this.tab);

  @override
  HuaweiTabVm reduce() {
    return HuaweiTabVm(
      currentTab: tab,
      changeTab: state.changeTab,
    );
  }
}

class HuaweiHomePage extends StatefulWidget {
  const HuaweiHomePage({super.key});

  @override
  State<HuaweiHomePage> createState() => _HuaweiHomePageState();
}

class _HuaweiHomePageState extends State<HuaweiHomePage> with Refena {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DevicesPage(),
    MePage(),
  ];

  @override
  void initState() {
    super.initState();
    ensureRef((ref) async {
      ref.listen(huaweiTabControllerProvider, (prev, next) {
        if (prev?.currentTab != next.currentTab) {
          setState(() {
            _currentIndex = next.currentTab.index;
          });
        }
      });
      await postInit(context, ref, true);
    });
  }

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
          context.ref.redux(huaweiTabControllerProvider).dispatch(
            HuaweiChangeTabAction(HuaweiTab.values[index]),
          );
        },
        destinations: HuaweiTab.values.map((tab) {
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
