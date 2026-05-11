import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

class HuaweiAboutPage extends StatelessWidget {
  const HuaweiAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.aboutPage.title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: HuaweiColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.share, color: HuaweiColors.primary, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'HiSend',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'v1.0',
              style: TextStyle(color: HuaweiColors.textTertiary, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _buildInfoRow(Icons.person_outline, '作者', 'Trae'),
                Divider(height: 1, indent: 56, endIndent: 16, color: Theme.of(context).dividerColor),
                _buildInfoRow(Icons.email_outlined, '邮箱', 'ai@ai.com'),
                Divider(height: 1, indent: 56, endIndent: 16, color: Theme.of(context).dividerColor),
                _buildInfoRow(Icons.code, '协议', 'MIT License'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _buildLinkRow(
                  context,
                  Icons.open_in_new,
                  'GitHub',
                  '查看源代码',
                  () async {
                    await launchUrl(Uri.parse('https://github.com/DoubleShift/hisend'), mode: LaunchMode.externalApplication);
                  },
                ),
                Divider(height: 1, indent: 56, endIndent: 16, color: Theme.of(context).dividerColor),
                _buildLinkRow(
                  context,
                  Icons.description_outlined,
                  '隐私政策',
                  '查看隐私政策',
                  () async {
                    await launchUrl(Uri.parse('https://localsend.org/privacy'), mode: LaunchMode.externalApplication);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _buildLinkRow(
                  context,
                  Icons.copyright,
                  '基于 LocalSend',
                  'LocalSend by Tien Do Nam',
                  () async {
                    await launchUrl(Uri.parse('https://localsend.org'), mode: LaunchMode.externalApplication);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: HuaweiColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: HuaweiColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                Text(value, style: TextStyle(color: HuaweiColors.textTertiary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: HuaweiColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: HuaweiColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: TextStyle(color: HuaweiColors.textTertiary, fontSize: 12)),
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
