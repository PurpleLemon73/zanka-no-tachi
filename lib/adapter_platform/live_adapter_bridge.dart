import '../live_provider/provider_adapter.dart';
import '../live_provider/provider_errors.dart';
import 'adapter_errors.dart';
import 'adapter_descriptor.dart';
import 'adapter_sdk.dart';

class LiveAdapterSdkBridge
    implements CatalogAdapter, SearchAdapter, DetailsAdapter {
  const LiveAdapterSdkBridge({required this.descriptor, required this.adapter});
  @override
  final AdapterDescriptor descriptor;
  final LiveProviderAdapter adapter;

  @override
  Future<PageResult<ProviderListingItem>> catalog(PageRequest request) =>
      _guard(() async => _result(await adapter.catalog(page: request.page)));

  @override
  Future<PageResult<ProviderListingItem>> search(
    String query,
    PageRequest request,
  ) => _guard(
    () async => _result(await adapter.search(query, page: request.page)),
  );

  @override
  Future<ProviderTitleResult> details(ProviderListingItem item) =>
      _guard(() => adapter.detail(item));

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on ProviderNetworkException catch (error) {
      throw AdapterNetworkError(descriptor.id, error.message, cause: error);
    } on ProviderHttpException catch (error) {
      if (error.statusCode == 429) {
        throw AdapterRateLimitError(descriptor.id, error.message, cause: error);
      }
      throw AdapterHttpError(
        descriptor.id,
        error.message,
        statusCode: error.statusCode,
      );
    } on ProviderParserException catch (error) {
      throw AdapterParseError(descriptor.id, error.message, cause: error);
    } on ProviderConfigurationException catch (error) {
      throw AdapterConfigurationError(
        descriptor.id,
        error.message,
        cause: error,
      );
    } on ProviderDisabledException catch (error) {
      throw AdapterUnavailable(descriptor.id, error.message, cause: error);
    }
  }

  PageResult<ProviderListingItem> _result(ProviderListingPage page) {
    final current = page.currentPage ?? 1;
    final total = page.totalPages ?? current;
    final hasMore = current < total;
    return PageResult(
      items: page.items,
      hasMore: hasMore,
      nextCursor: hasMore ? PaginationCursor('${current + 1}') : null,
    );
  }
}
