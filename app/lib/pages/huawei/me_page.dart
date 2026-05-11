import 'package:common/model/device_info_result.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/state/settings_state.dart';
import 'package:localsend_app/pages/huawei/about_page.dart';
import 'package:localsend_app/pages/huawei/changelog_page.dart';
import 'package:localsend_app/pages/huawei/receive_history_page.dart';
import 'package:localsend_app/pages/huawei/settings_page.dart';
import 'package:localsend_app/pages/huawei/troubleshoot_page.dart';
import 'package:localsend_app/provider/device_info_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch(settingsProvider);
    final deviceInfo = context.watch(deviceInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildProfileCard(context, settings, deviceInfo),
          const SizedBox(height: 12),
          _buildFeatureSection(context),
          const SizedBox(height: 8),
          _buildSettingsSection(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, SettingsState settings, DeviceInfoResult deviceInfo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showAliasEditDialog(context, settings.alias),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: HuaweiColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.devices, color: HuaweiColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(settings.alias, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '${deviceInfo.deviceModel ?? "未知设备"} · 点击修改描述',
                      style: TextStyle(color: HuaweiColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, color: HuaweiColors.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showAliasEditDialog(BuildContext context, String currentAlias) {
    final controller = TextEditingController(text: currentAlias);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改设备描述'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: '输入设备描述')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              final newAlias = controller.text.trim();
              if (newAlias.isNotEmpty) {
                await context.ref.notifier(settingsProvider).setAlias(newAlias);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.history,
            iconColor: HuaweiColors.success,
            title: '传输历史',
            subtitle: '查看文件传输记录',
            onTap: () async => await context.push(() => const HuaweiReceiveHistoryPage()),
          ),
          Divider(height: 1, indent: 56, endIndent: 16, color: Theme.of(context).dividerColor),
          _buildMenuItem(
            icon: Icons.help_outline,
            iconColor: HuaweiColors.primary,
            title: '帮助与反馈',
            subtitle: '常见问题与故障排除',
            onTap: () async => await context.push(() => const HuaweiTroubleshootPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.settings_outlined,
            iconColor: Colors.grey[600]!,
            title: '设置',
            subtitle: '外观、接收、网络等设置',
            onTap: () async => await context.push(() => const HuaweiSettingsPage()),
          ),
          Divider(height: 1, indent: 56, endIndent: 16, color: Theme.of(context).dividerColor),
          _buildMenuItem(
            icon: Icons.info_outline,
            iconColor: HuaweiColors.primary,
            title: '关于 HiSend',
            onTap: () async => await context.push(() => const HuaweiAboutPage()),
          ),
          Divider(height: 1, indent: 56, endIndent: 16, color: Theme.of(context).dividerColor),
          _buildMenuItem(
            icon: Icons.update,
            iconColor: HuaweiColors.success,
            title: '更新日志',
            onTap: () async => await context.push(() => const HuaweiChangelogPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  if (subtitle != null) Text(subtitle, style: TextStyle(color: HuaweiColors.textTertiary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: HuaweiColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
