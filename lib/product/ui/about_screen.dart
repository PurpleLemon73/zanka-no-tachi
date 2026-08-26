import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_identity.dart';
import '../../app/local_diagnostics.dart';
import 'onboarding_screen.dart';

class AboutZankaScreen extends StatelessWidget {
  const AboutZankaScreen({super.key, required this.diagnostics});
  final LocalDiagnostics diagnostics;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About & Help')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppIdentity.displayName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  '${AppIdentity.shortDescription}\nVersion ${AppIdentity.version}+${AppIdentity.buildNumber}',
                ),
                const SizedBox(height: 20),
                const Text(AppIdentity.disclaimer),
                const Divider(height: 32),
                ListTile(
                  key: const Key('reopen-onboarding'),
                  leading: const Icon(Icons.help_outline),
                  title: const Text('How Zanka works'),
                  subtitle: const Text('Reopen the short introduction.'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OnboardingScreen(
                        reopened: true,
                        onComplete: () async {},
                      ),
                    ),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Open-source repository'),
                  subtitle: SelectableText(AppIdentity.repositoryUrl),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Open-source licenses'),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppIdentity.displayName,
                    applicationVersion: AppIdentity.version,
                  ),
                ),
                const Divider(height: 32),
                Text(
                  'Local diagnostics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'Recent redacted records stay on this device and are never sent automatically.',
                ),
                FutureBuilder<List<DiagnosticRecord>>(
                  future: diagnostics.records(),
                  builder: (context, snapshot) => Text(
                    '${snapshot.data?.length ?? 0} bounded record(s)',
                    key: const Key('diagnostic-count'),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('copy-diagnostics'),
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text: await diagnostics.redactedReport(),
                          ),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Redacted diagnostics copied.'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy report'),
                    ),
                    OutlinedButton.icon(
                      key: const Key('clear-diagnostics'),
                      onPressed: () async {
                        await diagnostics.clear();
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('Clear diagnostics'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
