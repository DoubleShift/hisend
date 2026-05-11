import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/state/server/receive_session_state.dart';
import 'package:localsend_app/provider/favorites_provider.dart';
import 'package:localsend_app/provider/network/server/server_provider.dart';
import 'package:localsend_app/util/device_type_ext.dart';
import 'package:localsend_app/util/favorites.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class HuaweiReceivePage extends StatefulWidget {
  final ViewProvider<dynamic> vm;

  const HuaweiReceivePage(this.vm, {super.key});

  @override
  State<HuaweiReceivePage> createState() => _HuaweiReceivePageState();
}

class _HuaweiReceivePageState extends State<HuaweiReceivePage> with Refena {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder(
      provider: (ref) => widget.vm,
      dispose: (ref) {
        ref.dispose(widget.vm);
      },
      builder: (context, vm) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('接收文件'),
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
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: HuaweiColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            vm.sender.deviceType.icon,
                            color: HuaweiColors.primary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ref.watch(favoritesProvider.select((s) => s.findDevice(vm.sender)))?.alias ?? vm.sender.alias,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        if (vm.sender.deviceModel != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            vm.sender.deviceModel!,
                            style: TextStyle(color: HuaweiColors.textSecondary, fontSize: 14),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: HuaweiColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.download_outlined, color: HuaweiColors.primary, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                vm.message != null
                                    ? (vm.isLink ? t.receivePage.subTitleLink : t.receivePage.subTitleMessage)
                                    : t.receivePage.subTitle(n: vm.files.length),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            vm.onDecline();
                            context.pop();
                          },
                          icon: const Icon(Icons.close),
                          label: Text(t.general.decline),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: HuaweiColors.error,
                            side: const BorderSide(color: HuaweiColors.error),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => vm.onAccept(),
                          icon: const Icon(Icons.check),
                          label: Text(t.general.accept),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
