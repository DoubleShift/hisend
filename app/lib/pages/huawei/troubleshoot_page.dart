import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';

class HuaweiTroubleshootPage extends StatelessWidget {
  const HuaweiTroubleshootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.troubleshootPage.title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildTipCard(
            context,
            Icons.wifi_off_outlined,
            HuaweiColors.primary,
            '无法发现设备',
            '确保双方设备连接到同一 Wi-Fi 网络，并关闭 VPN 和防火墙。',
          ),
          _buildTipCard(
            context,
            Icons.send_outlined,
            Colors.orange,
            '无法发送文件',
            '确保接收方已启动 HiSend 并处于接收模式。检查对方是否需要输入 PIN 码。',
          ),
          _buildTipCard(
            context,
            Icons.speed_outlined,
            HuaweiColors.success,
            '传输速度慢',
            '尝试关闭加密（设置 > 网络 > 加密）以提升速度。确保路由器性能良好。',
          ),
          _buildTipCard(
            context,
            Icons.security_outlined,
            Colors.purple,
            '连接被拒绝',
            '检查接收方是否设置了 PIN 码保护。确保发送到正确的设备。',
          ),
          _buildTipCard(
            context,
            Icons.phonelink_outlined,
            Colors.teal,
            '端口问题',
            'HiSend 默认使用端口 53317。如果被占用，可在设置中修改端口号。',
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context,
    IconData icon,
    Color color,
    String title,
    String description,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: HuaweiColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
