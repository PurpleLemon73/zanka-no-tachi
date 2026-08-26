import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/adapter_platform/adapter_sdk.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/product/product_controller.dart';
import 'package:zanka_no_tachi/product/product_models.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';

void main() {
  test('late search responses cannot replace a newer query', () async {
    final live = LiveProviderRepository(
      registry: ProviderRegistry(const []),
      database: CanonicalDatabase(NativeDatabase.memory()),
      transport: const _UnusedTransport(),
    );
    final repository = _ControlledRepository(live);
    final controller = ProductController(repository);

    controller.scheduleSearch('old', immediate: true);
    controller.scheduleSearch('new', immediate: true);
    repository.complete('new', 'New result');
    await Future<void>.delayed(Duration.zero);
    repository.complete('old', 'Old result');
    await Future<void>.delayed(Duration.zero);

    expect(controller.searchQuery, 'new');
    expect(controller.searchResults.single.title, 'New result');
    controller.dispose();
    await live.dispose();
  });

  test('stale load-more response cannot append after a new search', () async {
    final live = LiveProviderRepository(
      registry: ProviderRegistry(const []),
      database: CanonicalDatabase(NativeDatabase.memory()),
      transport: const _UnusedTransport(),
    );
    final repository = _PagedControlledRepository(live);
    final controller = ProductController(repository);

    final first = controller.submitSearch('old');
    repository.complete('old:first', 'Old page 1', hasMore: true);
    await first;
    final more = controller.loadMoreSearch();
    final replacement = controller.submitSearch('new');
    repository.complete('new:first', 'New page 1');
    await replacement;
    repository.complete('old:2', 'Old page 2');
    await more;

    expect(controller.searchResults.single.title, 'New page 1');
    controller.dispose();
    await live.dispose();
  });
}

class _ControlledRepository extends ProductRepository {
  _ControlledRepository(super.live);
  final Map<String, Completer<ProductSearchResponse>> pending = {};

  @override
  Future<ProductSearchResponse> search(
    String query, {
    Set<CanonicalMediaKind> kinds = const {
      CanonicalMediaKind.manga,
      CanonicalMediaKind.anime,
    },
    Map<ProviderId, PaginationCursor> cursors = const {},
  }) => (pending[query] = Completer<ProductSearchResponse>()).future;

  void complete(String query, String title) {
    pending[query]!.complete(
      ProductSearchResponse(
        results: [
          ProductSearchResult(
            title: title,
            kind: CanonicalMediaKind.manga,
            sources: const [],
            canonicalId: CanonicalMediaId(query),
          ),
        ],
        failures: const {},
      ),
    );
  }
}

class _UnusedTransport implements ProviderTransport {
  const _UnusedTransport();
  @override
  Future<ProviderResponse> get(Uri uri) => throw UnimplementedError();
  @override
  void close() {}
}

class _PagedControlledRepository extends ProductRepository {
  _PagedControlledRepository(super.live);
  final Map<String, Completer<ProductSearchResponse>> pending = {};

  @override
  Future<ProductSearchResponse> search(
    String query, {
    Set<CanonicalMediaKind> kinds = const {
      CanonicalMediaKind.manga,
      CanonicalMediaKind.anime,
    },
    Map<ProviderId, PaginationCursor> cursors = const {},
  }) {
    final page = cursors.isEmpty ? 'first' : cursors.values.single.value;
    return (pending['$query:$page'] = Completer<ProductSearchResponse>())
        .future;
  }

  void complete(String key, String title, {bool hasMore = false}) {
    pending[key]!.complete(
      ProductSearchResponse(
        results: [
          ProductSearchResult(
            title: title,
            kind: CanonicalMediaKind.manga,
            sources: const [],
            canonicalId: CanonicalMediaId(title),
          ),
        ],
        failures: const {},
        nextCursors: hasMore
            ? {const ProviderId('fake'): const PaginationCursor('2')}
            : const {},
      ),
    );
  }
}
