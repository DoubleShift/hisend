import 'package:common/model/device.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/wechat_theme.dart';
import 'package:localsend_app/pages/wechat/chat_page.dart';
import 'package:localsend_app/provider/favorites_provider.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/util/device_type_ext.dart';
import 'package:refena_flutter/refena_flutter.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通讯录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {},
          ),
        ],
      ),
      body: const _ContactsList(),
    );
  }
}

class _ContactsList extends StatelessWidget {
  const _ContactsList();

  @override
  Widget build(BuildContext context) {
    final nearbyDevices = context.watch(nearbyDevicesProvider);
    final favorites = context.watch(favoritesProvider);
    final devices = nearbyDevices.allDevices.values.toList();

    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无联系人',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final favoriteDevices = devices.where((d) {
      return favorites.any((f) => f.fingerprint == d.fingerprint);
    }).toList();

    final otherDevices = devices.where((d) {
      return !favorites.any((f) => f.fingerprint == d.fingerprint);
    }).toList();

    return ListView(
      children: [
        if (favoriteDevices.isNotEmpty) ...[
          _buildSectionHeader('星标朋友'),
          ...favoriteDevices.map((device) => _ContactTile(device: device)),
        ],
        _buildSectionHeader('全部设备'),
        ...otherDevices.map((device) => _ContactTile(device: device)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: WeChatColors.chatBackground,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final Device device;

  const _ContactTile({required this.device});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch(favoritesProvider);
    final isFavorite = favorites.any((f) => f.fingerprint == device.fingerprint);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: WeChatColors.primary,
        radius: 20,
        child: Icon(
          device.deviceType.icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        device.alias,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        device.deviceModel ?? device.deviceType.name,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: isFavorite
          ? const Icon(Icons.star, color: Colors.amber, size: 20)
          : null,
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
