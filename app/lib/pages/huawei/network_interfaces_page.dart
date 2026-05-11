import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

class HuaweiNetworkInterfacesPage extends StatefulWidget {
  const HuaweiNetworkInterfacesPage({super.key});

  @override
  State<HuaweiNetworkInterfacesPage> createState() => _HuaweiNetworkInterfacesPageState();
}

class _HuaweiNetworkInterfacesPageState extends State<HuaweiNetworkInterfacesPage> {
  final _whitelistController = TextEditingController();
  final _blacklistController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = context.ref.read(settingsProvider);
    if (settings.networkWhitelist != null) {
      _whitelistController.text = settings.networkWhitelist!;
    }
    if (settings.networkBlacklist != null) {
      _blacklistController.text = settings.networkBlacklist!;
    }
  }

  @override
  void dispose() {
    _whitelistController.dispose();
    _blacklistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.settingsTab.network.network),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Whitelist',
                    style: TextStyle(color: HuaweiColors.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _whitelistController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter network addresses (one per line)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await context.ref.notifier(settingsProvider).setNetworkWhitelist(null);
                          _whitelistController.clear();
                        },
                        child: Text(t.general.clear),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final text = _whitelistController.text.trim();
                          await context.ref.notifier(settingsProvider).setNetworkWhitelist(text.isEmpty ? null : text);
                        },
                        child: Text(t.general.ok),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blacklist',
                    style: TextStyle(color: HuaweiColors.error, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _blacklistController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter network addresses (one per line)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await context.ref.notifier(settingsProvider).setNetworkBlacklist(null);
                          _blacklistController.clear();
                        },
                        child: Text(t.general.clear),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final text = _blacklistController.text.trim();
                          await context.ref.notifier(settingsProvider).setNetworkBlacklist(text.isEmpty ? null : text);
                        },
                        child: Text(t.general.ok),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
