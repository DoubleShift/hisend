import 'package:flutter/material.dart';
import 'package:localsend_app/config/wechat_theme.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
      ),
      body: ListView(
        children: [
          _buildDiscoverItem(
            icon: Icons.radar,
            title: '附近设备',
            subtitle: '自动发现局域网内的设备',
            onTap: () {},
          ),
          _buildDivider(),
          _buildDiscoverItem(
            icon: Icons.history,
            title: '传输历史',
            subtitle: '查看文件传输记录',
            onTap: () {},
          ),
          _buildDivider(),
          _buildDiscoverItem(
            icon: Icons.share,
            title: '共享文件',
            subtitle: '分享文件给身边的朋友',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: WeChatColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: WeChatColors.primary,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      color: Colors.grey[300],
    );
  }
}
