import 'package:flutter/material.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/state/purchase_state.dart';
import 'package:localsend_app/pages/donation/donation_page_vm.dart';
import 'package:localsend_app/widget/custom_basic_appbar.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder(
      provider: (ref) => donationPageNoopVmProvider,
      builder: (context, vm) {
        return Scaffold(
          appBar: basicLocalSendAppbar(t.donationPage.title),
          body: Stack(
            children: [
              ResponsiveListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Text(
                      t.donationPage.info,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 50),
                  const _LinkDonation(),
                ],
              ),
              if (vm.pending)
                Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LinkDonation extends StatelessWidget {
  const _LinkDonation();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        TextButton.icon(
          onPressed: () async {
            await launchUrl(Uri.parse('https://github.com/sponsors/Tienisto'), mode: LaunchMode.externalApplication);
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('Github'),
        ),
        TextButton.icon(
          onPressed: () async {
            await launchUrl(Uri.parse('https://ko-fi.com/tienisto'), mode: LaunchMode.externalApplication);
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('Ko-fi'),
        ),
      ],
    );
  }
}
