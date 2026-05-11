import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/persistence/color_mode.dart';
import 'package:localsend_app/pages/huawei/language_page.dart';
import 'package:localsend_app/pages/huawei/network_interfaces_page.dart';
import 'package:localsend_app/pages/language_page.dart' show AppLocaleExt;
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_app/widget/dialogs/encryption_disabled_notice.dart';
import 'package:localsend_app/widget/dialogs/pin_dialog.dart';
import 'package:localsend_app/widget/dialogs/quick_save_from_favorites_notice.dart';
import 'package:localsend_app/widget/dialogs/quick_save_notice.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class HuaweiSettingsPage extends StatelessWidget {
  const HuaweiSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch(settingsProvider);
    final ref = context.ref;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settingsTab.title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSection(context, t.settingsTab.general.title, [
            _buildDropdownItem<ThemeMode>(
              context: context,
              icon: Icons.brightness_6_outlined,
              iconColor: HuaweiColors.primary,
              title: t.settingsTab.general.brightness,
              value: settings.theme,
              items: ThemeMode.values,
              labelBuilder: (m) => m.humanName,
              onChanged: (mode) async {
                await ref.notifier(settingsProvider).setTheme(mode);
              },
            ),
            _buildDropdownItem<ColorMode>(
              context: context,
              icon: Icons.palette_outlined,
              iconColor: Colors.purple,
              title: t.settingsTab.general.color,
              value: settings.colorMode,
              items: ColorMode.values,
              labelBuilder: (c) => c.humanName,
              onChanged: (mode) async {
                await ref.notifier(settingsProvider).setColorMode(mode);
              },
            ),
            _buildNavigationItem(
              icon: Icons.language,
              iconColor: Colors.blue,
              title: t.settingsTab.general.language,
              subtitle: settings.locale?.humanName ?? t.settingsTab.general.languageOptions.system,
              onTap: () async {
                await context.push(() => const HuaweiLanguagePage());
              },
            ),
            _buildSwitchItem(
              context: context,
              icon: Icons.animation_outlined,
              iconColor: Colors.orange,
              title: t.settingsTab.general.animations,
              value: settings.enableAnimations,
              onChanged: (b) async {
                await ref.notifier(settingsProvider).setEnableAnimations(b);
              },
            ),
          ]),
          _buildSection(context, t.settingsTab.receive.title, [
            _buildSwitchItem(
              context: context,
              icon: Icons.bolt,
              iconColor: HuaweiColors.success,
              title: t.settingsTab.receive.quickSave,
              value: settings.quickSave,
              onChanged: (b) async {
                final old = settings.quickSave;
                await ref.notifier(settingsProvider).setQuickSave(b);
                if (!old && b && context.mounted) {
                  await QuickSaveNotice.open(context);
                }
              },
            ),
            _buildSwitchItem(
              context: context,
              icon: Icons.star_outline,
              iconColor: Colors.amber,
              title: t.settingsTab.receive.quickSaveFromFavorites,
              value: settings.quickSaveFromFavorites,
              onChanged: (b) async {
                final old = settings.quickSaveFromFavorites;
                await ref.notifier(settingsProvider).setQuickSaveFromFavorites(b);
                if (!old && b && context.mounted) {
                  await QuickSaveFromFavoritesNotice.open(context);
                }
              },
            ),
            _buildSwitchItem(
              context: context,
              icon: Icons.lock_outline,
              iconColor: HuaweiColors.error,
              title: t.settingsTab.receive.requirePin,
              value: settings.receivePin != null,
              onChanged: (b) async {
                if (settings.receivePin != null) {
                  await ref.notifier(settingsProvider).setReceivePin(null);
                } else {
                  final newPin = await showDialog<String>(
                    context: context,
                    builder: (_) => const PinDialog(obscureText: false, generateRandom: false),
                  );
                  if (newPin != null && newPin.isNotEmpty) {
                    await ref.notifier(settingsProvider).setReceivePin(newPin);
                  }
                }
              },
            ),
            _buildSwitchItem(
              context: context,
              icon: Icons.check_circle_outline,
              iconColor: HuaweiColors.primary,
              title: t.settingsTab.receive.autoFinish,
              value: settings.autoFinish,
              onChanged: (b) async {
                await ref.notifier(settingsProvider).setAutoFinish(b);
              },
            ),
            _buildSwitchItem(
              context: context,
              icon: Icons.history,
              iconColor: Colors.teal,
              title: t.settingsTab.receive.saveToHistory,
              value: settings.saveToHistory,
              onChanged: (b) async {
                await ref.notifier(settingsProvider).setSaveToHistory(b);
              },
            ),
          ]),
          _buildSection(context, t.settingsTab.network.title, [
            _buildNavigationItem(
              icon: Icons.wifi_outlined,
              iconColor: HuaweiColors.primary,
              title: t.settingsTab.network.alias,
              subtitle: settings.alias,
              onTap: () => _showAliasEditDialog(context, settings.alias),
            ),
            _buildSwitchItem(
              context: context,
              icon: Icons.https_outlined,
              iconColor: HuaweiColors.success,
              title: t.settingsTab.network.encryption,
              value: settings.https,
              onChanged: (b) async {
                final old = settings.https;
                await ref.notifier(settingsProvider).setHttps(b);
                if (old && !b && context.mounted) {
                  await EncryptionDisabledNotice.open(context);
                }
              },
            ),
            _buildNavigationItem(
              icon: Icons.lan_outlined,
              iconColor: Colors.indigo,
              title: t.settingsTab.network.network,
              subtitle: settings.networkWhitelist != null || settings.networkBlacklist != null
                  ? t.settingsTab.network.networkOptions.filtered
                  : t.settingsTab.network.networkOptions.all,
              onTap: () async {
                await context.push(() => const HuaweiNetworkInterfacesPage());
              },
            ),
          ]),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'HiSend v1.0',
              style: TextStyle(color: HuaweiColors.textTertiary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showAliasEditDialog(BuildContext context, String currentAlias) {
    final controller = TextEditingController(text: currentAlias);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.settingsTab.network.alias),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: t.settingsTab.network.alias,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.general.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAlias = controller.text.trim();
              if (newAlias.isNotEmpty) {
                await context.ref.notifier(settingsProvider).setAlias(newAlias);
              }
              Navigator.pop(ctx);
            },
            child: Text(t.general.confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: HuaweiColors.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
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
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  if (subtitle != null)
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

  Widget _buildDropdownItem<T>({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onChanged,
  }) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: Text(title),
            children: items.map((item) {
              return SimpleDialogOption(
                onPressed: () {
                  onChanged(item);
                  Navigator.pop(ctx);
                },
                child: Row(
                  children: [
                    if (item == value)
                      Icon(Icons.check, color: HuaweiColors.primary, size: 20)
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 8),
                    Text(labelBuilder(item)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
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
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  Text(labelBuilder(value), style: TextStyle(color: HuaweiColors.textTertiary, fontSize: 12)),
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

extension on ThemeMode {
  String get humanName {
    switch (this) {
      case ThemeMode.system:
        return t.settingsTab.general.brightnessOptions.system;
      case ThemeMode.light:
        return t.settingsTab.general.brightnessOptions.light;
      case ThemeMode.dark:
        return t.settingsTab.general.brightnessOptions.dark;
    }
  }
}

extension on ColorMode {
  String get humanName {
    return switch (this) {
      ColorMode.system => t.settingsTab.general.colorOptions.system,
      ColorMode.localsend => t.appName,
      ColorMode.oled => t.settingsTab.general.colorOptions.oled,
      ColorMode.yaru => 'Yaru',
      ColorMode.huawei => 'Huawei',
    };
  }
}
