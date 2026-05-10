import 'package:flutter/material.dart';
import 'package:localsend_app/config/wechat_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/pages/about/about_page.dart';
import 'package:localsend_app/pages/changelog_page.dart';
import 'package:localsend_app/pages/debug/debug_page.dart';
import 'package:localsend_app/pages/troubleshoot_page.dart';
import 'package:localsend_app/provider/device_info_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 16),
          _buildSettingsSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final deviceInfo = context.watch(deviceInfoProvider);
    final settings = context.watch(settingsProvider);

    return Container(
      color: WeChatColors.chatBackground,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: WeChatColors.primary,
            radius: 36,
            child: const Icon(
              Icons.devices,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.alias,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '设备型号: ${deviceInfo.deviceModel ?? "未知"}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      children: [
        _buildSettingsItem(
          icon: Icons.settings,
          title: '设置',
          onTap: () async {
            await context.push(() => const DebugPage());
          },
        ),
        _buildDivider(),
        _buildSettingsItem(
          icon: Icons.help_outline,
          title: '帮助与反馈',
          onTap: () async {
            await context.push(() => const TroubleshootPage());
          },
        ),
        _buildDivider(),
        _buildSettingsItem(
          icon: Icons.info_outline,
          title: '关于 LocalSend',
          onTap: () async {
            await context.push(() => const AboutPage());
          },
        ),
        _buildDivider(),
        _buildSettingsItem(
          icon: Icons.update,
          title: '更新日志',
          onTap: () async {
            await context.push(() => const ChangelogPage());
          },
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: WeChatColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      color: Colors.grey[300],
    );
  }
}
