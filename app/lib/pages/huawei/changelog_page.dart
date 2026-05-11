import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/version_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';

class HuaweiChangelogPage extends StatelessWidget {
  const HuaweiChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final versionAsync = context.watch(versionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.changelogPage.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: HuaweiColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.new_releases_outlined, color: HuaweiColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HiSend v1.0',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            versionAsync.maybeWhen(
                              data: (v) => Text('Build: $v', style: TextStyle(color: HuaweiColors.textTertiary, fontSize: 12)),
                              orElse: () => const SizedBox(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildChangeItem(Icons.design_services_outlined, '全新华为风格 UI 设计'),
                  _buildChangeItem(Icons.tab_outlined, '简化为 2 个 Tab：设备 + 我的'),
                  _buildChangeItem(Icons.send_outlined, '聊天式文件发送界面'),
                  _buildChangeItem(Icons.security_outlined, '仅编译 arm64-v8a 架构'),
                  _buildChangeItem(Icons.delete_outline, '移除广告和统计 SDK'),
                  _buildChangeItem(Icons.label_outline, '重命名为 HiSend'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: HuaweiColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
