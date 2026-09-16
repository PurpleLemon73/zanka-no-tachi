import 'package:flutter/material.dart';

import '../../canonical/domain/identifiers.dart';
import '../product_controller.dart';
import 'design_system.dart';
import 'settings_visuals.dart';

/// Real source configuration, independent of developer diagnostics.
class SourceSettingsPage extends StatelessWidget {
  const SourceSettingsPage({super.key, required this.controller});
  final ProductController controller;

  Future<void> _editAddress(BuildContext context, ProviderId id) async {
    var address = controller.repository.live.registry
        .require(id)
        .baseUrl
        .toString();
    final form = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Source address'),
        scrollable: true,
        content: Form(
          key: form,
          child: TextFormField(
            key: const Key('source-address-input'),
            initialValue: address,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Base URL'),
            onChanged: (value) => address = value.trim(),
            validator: (value) {
              final uri = Uri.tryParse(value?.trim() ?? '');
              return uri == null ||
                      uri.host.isEmpty ||
                      !const ['https', 'http'].contains(uri.scheme) ||
                      uri.userInfo.isNotEmpty ||
                      uri.hasQuery ||
                      uri.hasFragment
                  ? 'Enter an HTTP(S) address without credentials, query or fragment.'
                  : null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, address);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    try {
      await controller.setProviderBaseUrl(id, Uri.parse(result));
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the source address. Please retry.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => SettingsDetailPage(
    title: 'Sources',
    description: 'Choose where discovery begins.',
    child: AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final provider in controller.providers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.travel_explore_outlined),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.displayName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${provider.mediaKind.name} · ${provider.baseUrl.host}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        key: ValueKey('setting-provider-${provider.id.value}'),
                        value: provider.enabled,
                        onChanged: (value) =>
                            controller.setProviderEnabled(provider.id, value),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    key: ValueKey('source-address-${provider.id.value}'),
                    onPressed: () => _editAddress(context, provider.id),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit address'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 22),
          ZankaSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Source fallback',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Per-media preference first, then available sources in stable order.',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
