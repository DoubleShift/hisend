import 'package:common/model/device.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/wechat_theme.dart';
import 'package:localsend_app/pages/wechat/chat_page.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/util/device_type_ext.dart';
import 'package:refena_flutter/refena_flutter.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalSend'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: const _ConversationsList(),
    );
  }
}

class _ConversationsList extends StatelessWidget {
  const _ConversationsList();

  @override
  Widget build(BuildContext context) {
    final nearbyDevices = context.watch(nearbyDevicesProvider);

    if (nearbyDevices.allDevices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂未发现附近设备',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '在同一局域网内的设备将自动显示',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    final devices = nearbyDevices.allDevices.values.toList();

    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return _ConversationTile(device: device);
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Device device;

  const _ConversationTile({required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: WeChatColors.primary,
        radius: 24,
        child: Icon(
          device.deviceType.toIcon(),
          color: Colors.white,
          size: 24,
        ),
      ),
      title: Text(
        device.alias,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        device.deviceModel ?? device.deviceType.name,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(device: device),
          ),
        );
      },
    );
  }
}
