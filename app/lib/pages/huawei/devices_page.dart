import 'package:common/model/device.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/pages/huawei/chat_page.dart';
import 'package:localsend_app/provider/favorites_provider.dart';
import 'package:localsend_app/provider/network/nearby_devices_provider.dart';
import 'package:localsend_app/util/device_type_ext.dart';
import 'package:refena_flutter/refena_flutter.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HiSend'),
      ),
      body: const _DevicesList(),
    );
  }
}

class _DevicesList extends StatelessWidget {
  const _DevicesList();

  @override
  Widget build(BuildContext context) {
    final nearbyDevices = context.watch(nearbyDevicesProvider);
    final favorites = context.watch(favoritesProvider);

    if (nearbyDevices.allDevices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices,
              size: 72,
              color: HuaweiColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              '正在发现附近设备...',
              style: TextStyle(
                color: HuaweiColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '确保设备在同一局域网内',
              style: TextStyle(
                color: HuaweiColors.textTertiary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final devices = nearbyDevices.allDevices.values.toList();
    final favoriteDevices = devices.where((d) {
      return favorites.any((f) => f.fingerprint == d.fingerprint);
    }).toList();
    final otherDevices = devices.where((d) {
      return !favorites.any((f) => f.fingerprint == d.fingerprint);
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (favoriteDevices.isNotEmpty) ...[
          _buildSectionHeader(context, '星标设备'),
          ...favoriteDevices.map((device) => _DeviceCard(device: device, isFavorite: true)),
          const SizedBox(height: 8),
        ],
        _buildSectionHeader(context, favoriteDevices.isNotEmpty ? '其他设备' : '附近设备'),
        ...otherDevices.map((device) => _DeviceCard(device: device, isFavorite: false)),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: HuaweiColors.textTertiary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final Device device;
  final bool isFavorite;

  const _DeviceCard({required this.device, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatPage(device: device),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: HuaweiColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  device.deviceType.icon,
                  color: HuaweiColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            device.alias,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isFavorite) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.star, color: Colors.amber[600], size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.deviceModel ?? device.deviceType.name,
                      style: TextStyle(
                        color: HuaweiColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: HuaweiColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
