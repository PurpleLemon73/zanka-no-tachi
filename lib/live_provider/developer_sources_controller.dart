import 'package:flutter/foundation.dart';

import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';
import '../canonical/domain/matching.dart';
import 'live_provider_repository.dart';
import 'provider_adapter.dart';
import 'provider_registry.dart';

class DeveloperSourcesController extends ChangeNotifier {
  DeveloperSourcesController(this.repository);

  final LiveProviderRepository repository;
  final Map<ProviderId, ProviderHealth> health = {};
  List<ProviderListingItem> results = const [];
  List<CanonicalMedia> persisted = const [];
  CanonicalMediaInspection? inspection;
  List<MatchCandidate> candidates = const [];
  CanonicalMediaId? mergeSourceId;
  CanonicalMediaId? mergeTargetId;
  MergeResult? lastMerge;
  ProviderId selectedProvider = const ProviderId('mangaworld');
  bool busy = false;
  String? diagnostic;

  List<ProviderConfig> get providers => repository.providers;

  Future<void> initialize() async {
    await repository.loadPersistedProviderConfiguration();
    await reloadPersisted();
  }

  Future<void> reloadPersisted() async {
    persisted = await repository.persistedMedia();
    if (persisted.length >= 2) {
      mergeSourceId ??= persisted[1].id;
      mergeTargetId ??= persisted.first.id;
    }
    if (!persisted.any((media) => media.id == mergeSourceId)) {
      mergeSourceId = null;
    }
    if (!persisted.any((media) => media.id == mergeTargetId)) {
      mergeTargetId = null;
    }
    notifyListeners();
  }

  Future<void> check(ProviderId providerId) async {
    await _run(() async {
      health[providerId] = await repository.check(providerId);
    });
  }

  Future<void> loadCatalog(ProviderId providerId) async {
    selectedProvider = providerId;
    await _run(() async {
      results = (await repository.catalog(providerId)).items;
    });
  }

  Future<void> search(String query) async {
    await _run(() async {
      results = (await repository.search(selectedProvider, query)).items;
    });
  }

  Future<void> ingest(ProviderListingItem item) async {
    await _run(() async {
      final result = await repository.ingestDetail(item);
      persisted = await repository.persistedMedia();
      inspection = await repository.inspect(result.media.id);
      diagnostic = result.created
          ? 'Created ${result.media.id.value}'
          : 'Refreshed ${result.media.id.value} without duplication';
    });
  }

  Future<void> inspect(CanonicalMediaId id) async {
    await _run(() async {
      inspection = await repository.inspect(id);
    });
  }

  void selectMergeSource(CanonicalMediaId? id) {
    mergeSourceId = id;
    notifyListeners();
  }

  void selectMergeTarget(CanonicalMediaId? id) {
    mergeTargetId = id;
    notifyListeners();
  }

  Future<void> showCandidates() async {
    final sourceId = mergeSourceId;
    if (sourceId == null) {
      diagnostic = 'Select a source canonical media item first';
      notifyListeners();
      return;
    }
    await _run(() async {
      candidates = await repository.candidatesFor(sourceId);
      diagnostic = candidates.isEmpty
          ? 'No non-rejected candidates found'
          : '${candidates.length} reviewed candidate(s); no automatic merge';
    });
  }

  Future<void> seedSyntheticScenarios() async {
    await _run(() async {
      await repository.seedSyntheticReconciliationScenarios();
      persisted = await repository.persistedMedia();
      mergeSourceId = const CanonicalMediaId('m3-berserk-b');
      mergeTargetId = const CanonicalMediaId('m3-berserk-a');
      diagnostic =
          'Seeded idempotent M3 manga and anime reconciliation scenarios';
    });
  }

  Future<void> mergeSelected() async {
    final sourceId = mergeSourceId;
    final targetId = mergeTargetId;
    if (sourceId == null || targetId == null || sourceId == targetId) {
      diagnostic = 'Select two different active canonical media items';
      notifyListeners();
      return;
    }
    await _run(() async {
      lastMerge = await repository.mergeCanonicalMedia(
        sourceId: sourceId,
        targetId: targetId,
      );
      persisted = await repository.persistedMedia();
      inspection = await repository.inspect(sourceId);
      candidates = const [];
      mergeSourceId = null;
      mergeTargetId = targetId;
      diagnostic =
          'Merged ${sourceId.value} → ${targetId.value}; old ID resolves to target';
    });
  }

  Future<void> undoLastMerge() async {
    final merge = lastMerge;
    if (merge == null) {
      diagnostic = 'No merge from this harness session can be undone';
      notifyListeners();
      return;
    }
    await _run(() async {
      await repository.undoMerge(merge.auditId);
      persisted = await repository.persistedMedia();
      inspection = await repository.inspect(merge.retiredId);
      mergeSourceId = merge.retiredId;
      mergeTargetId = merge.survivingId;
      lastMerge = null;
      diagnostic =
          'Undo restored ${merge.retiredId.value} as an active identity';
    });
  }

  void selectProvider(ProviderId providerId) {
    selectedProvider = providerId;
    notifyListeners();
  }

  Future<void> configureBaseUrl(ProviderId providerId, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      diagnostic = 'Base URL must be an absolute HTTP(S) URL';
      notifyListeners();
      return;
    }
    final current = repository.registry.require(providerId);
    await repository.persistProvider(current.copyWith(baseUrl: uri));
    diagnostic = 'Updated ${current.displayName} base URL';
    notifyListeners();
  }

  Future<void> setEnabled(ProviderId providerId, bool enabled) async {
    final current = repository.registry.require(providerId);
    await repository.persistProvider(current.copyWith(enabled: enabled));
    health.remove(providerId);
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    busy = true;
    diagnostic = null;
    notifyListeners();
    try {
      await action();
    } on Object catch (error) {
      diagnostic = error.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
