import 'dart:async';

import 'package:common/model/device.dart';
import 'package:common/model/session_status.dart';
import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/device_info_provider.dart';
import 'package:localsend_app/provider/favorites_provider.dart';
import 'package:localsend_app/provider/network/send_provider.dart';
import 'package:localsend_app/util/device_type_ext.dart';
import 'package:localsend_app/util/favorites.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class HuaweiSendPage extends StatefulWidget {
  final String sessionId;

  const HuaweiSendPage({required this.sessionId, super.key});

  @override
  State<HuaweiSendPage> createState() => _HuaweiSendPageState();
}

class _HuaweiSendPageState extends State<HuaweiSendPage> with Refena {
  Device? _myDevice;
  Device? _targetDevice;

  void _cancel() {
    final myDevice = ref.read(deviceFullInfoProvider);
    final sendState = ref.read(sendProvider)[widget.sessionId];
    if (sendState == null) return;

    setState(() {
      _myDevice = myDevice;
      _targetDevice = sendState.target;
    });
    ref.notifier(sendProvider).cancelSession(widget.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    final sendState = ref.watch(
      sendProvider.select((state) => state[widget.sessionId]),
    );

    if (sendState == null && _myDevice == null && _targetDevice == null) {
      return const Scaffold(body: SizedBox());
    }

    final myDevice = ref.watch(deviceFullInfoProvider);
    final targetDevice = sendState?.target ?? _targetDevice!;
    final targetFavoriteEntry = ref.watch(favoritesProvider.select((state) => state.findDevice(targetDevice)));
    final waiting = sendState?.status == SessionStatus.waiting;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _cancel();
      },
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.sendPage.waiting),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: HuaweiColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(myDevice.deviceType.icon, color: HuaweiColors.primary, size: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(myDevice.alias, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 24),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: HuaweiColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.arrow_downward, color: HuaweiColors.primary),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: HuaweiColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(targetDevice.deviceType.icon, color: HuaweiColors.primary, size: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        targetFavoriteEntry?.alias ?? targetDevice.alias,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      if (sendState != null)
                        _buildStatusText(context, sendState.status),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _cancel();
                      context.pop();
                    },
                    icon: Icon(waiting ? Icons.close : Icons.check_circle),
                    label: Text(waiting ? t.general.cancel : t.general.close),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText(BuildContext context, SessionStatus status) {
    return switch (status) {
      SessionStatus.waiting => Column(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 12),
            Text(t.sendPage.waiting, style: TextStyle(color: HuaweiColors.textSecondary, fontSize: 14)),
          ],
        ),
      SessionStatus.declined => Text(t.sendPage.rejected, style: const TextStyle(color: HuaweiColors.error, fontSize: 14)),
      SessionStatus.tooManyAttempts => Text(t.sendPage.tooManyAttempts, style: const TextStyle(color: HuaweiColors.error, fontSize: 14)),
      SessionStatus.recipientBusy => Text(t.sendPage.busy, style: const TextStyle(color: Colors.orange, fontSize: 14)),
      SessionStatus.finishedWithErrors => Text(t.general.error, style: const TextStyle(color: HuaweiColors.error, fontSize: 14)),
      _ => const SizedBox(),
    };
  }
}
