import 'package:common/model/device_info_result.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/pages/about/about_page.dart';
import 'package:localsend_app/pages/changelog_page.dart';
import 'package:localsend_app/pages/debug/debug_page.dart';
import 'package:localsend_app/pages/receive_history_page.dart';
import 'package:localsend_app/pages/troubleshoot_page.dart';
import 'package:localsend_app/provider/device_info_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class MePage extends ConsumerWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context, Refena ref) {
    final settings = ref.watch(settingsProvider);
    final deviceInfo = ref.watch(deviceInfoProvider);
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
                child: const Icon(
                  Icons.devices,
                  color: HuaweiColors.primary,
                  size: 28,
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deviceInfo.deviceModel ?? "未知设备"} · 点击修改描述',
                      style: TextStyle(
                        color: HuaweiColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                color: HuaweiColors.primary,
                size: 20,
              ),
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
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入设备描述',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAlias = controller.text.trim();
              if (newAlias.isNotEmpty) {
                await ref.notifier(settingsProvider).setAlias(newAlias);
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
            icon: Icons.radar,
            iconColor: HuaweiColors.primary,
            title: '附近设备',
            subtitle: '自动发现局域网内的设备',
            onTap: () {},
          ),
          Divider(height: 1, indent: 56, endIndent: 16, color: Theme.of(context).dividerColor),
          _buildMenuItem(
            icon: Icons.history,
            iconColor: HuaweiColors.success,
            title: '传输历史',
            subtitle: '查看文件传输记录',
            onTap: () async {
              await context.push(() => const ReceiveHistoryPage());
            },
          ),
          Divider(height: 1, indent: 56, endIndent: 16, color: Theme.of(context).dividerColor),
          _buildMenuItem(
            icon: Icons.share,
            iconColor: Colors.orange,
            title: '共享文件',
            subtitle: '分享文件给身边的朋友',
            onTap: () {},
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
            onTap: () async {
              await context.push(() => const DebugPage());
            },
          ),
          Divider(height: 1, indent: 56, endIndent: 16, color: Theme.of(context).dividerColor),
          _buildMenuItem(
            icon: Icons.help_outline,
            iconColor: HuaweiColors.primary,
            title: '帮助与反馈',
            onTap: () async {
              await context.push(() => const TroubleshootPage());
            },
          ),
          Divider(height: 1, indent: 56, endIndent: 16, color: Theme.of(context).dividerColor),
          _buildMenuItem(
            icon: Icons.info_outline,
            iconColor: HuaweiColors.primary,
            title: '关于 HiSend',
            onTap: () async {
              await context.push(() => const AboutPage());
            },
          ),
          Divider(height: 1, indent: 56, endIndent: 16, color: Theme.of(context).dividerColor),
          _buildMenuItem(
            icon: Icons.update,
            iconColor: HuaweiColors.success,
            title: '更新日志',
            onTap: () async {
              await context.push(() => const ChangelogPage());
            },
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
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: HuaweiColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
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
