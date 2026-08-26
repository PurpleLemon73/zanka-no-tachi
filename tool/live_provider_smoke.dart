import 'dart:io';

import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/live_provider/provider_adapter.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';

Future<void> main(List<String> arguments) async {
  final registry = ProviderRegistry.defaults();
  final transport = HttpProviderTransport(maxTransientRetries: 0);
  try {
    for (final config in registry.all) {
      final adapter = switch (config.mediaKind) {
        CanonicalMediaKind.manga => MangaWorldLiveAdapter(
          config: config,
          transport: transport,
        ),
        CanonicalMediaKind.anime => AnimeWorldLiveAdapter(
          config: config,
          transport: transport,
        ),
      };
      final health = await adapter.checkHealth();
      stdout.writeln(
        '${config.displayName}: ${health.state.name} — '
        '${health.diagnostic ?? 'no diagnostic'}',
      );
      if (arguments.contains('--search')) {
        final query = config.mediaKind == CanonicalMediaKind.manga
            ? 'MAD'
            : 'Fullmetal Alchemist';
        final result = await adapter.search(query);
        stdout.writeln(
          '${config.displayName} search "$query": ${result.items.length} items — '
          '${result.items.take(3).map((item) => item.title).join(' | ')}',
        );
      }
    }
  } finally {
    transport.close();
  }
}
