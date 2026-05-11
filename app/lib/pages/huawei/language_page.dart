import 'package:flutter/material.dart';
import 'package:localsend_app/config/huawei_theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

class HuaweiLanguagePage extends StatelessWidget {
  const HuaweiLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settingsTab.general.language),
      ),
      body: ListView(
        children: [
          _buildLanguageOption(
            context: context,
            label: t.settingsTab.general.languageOptions.system,
            isSelected: settings.locale == null,
            onTap: () async {
              await context.ref.notifier(settingsProvider).setLocale(null);
            },
          ),
          ...AppLocale.values.map((locale) {
            return _buildLanguageOption(
              context: context,
              label: locale.humanName,
              isSelected: settings.locale == locale,
              onTap: () async {
                await context.ref.notifier(settingsProvider).setLocale(locale);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? HuaweiColors.primary : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: HuaweiColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
