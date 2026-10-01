import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retail_shop_catalog/app/providers/providers.dart';
import 'package:retail_shop_catalog/core/network/api_exception.dart';
import 'package:retail_shop_catalog/core/network/api_response.dart';
import 'package:retail_shop_catalog/modules/features/catalog/data/models/product_model.dart';
import 'package:retail_shop_catalog/modules/features/catalog/domain/repositories/catalog_preferences_repository.dart';
import 'package:retail_shop_catalog/modules/features/catalog/domain/repositories/product_repository.dart';
import 'package:retail_shop_catalog/modules/features/catalog/presentation/catalog_viewmodel.dart';

void main() {
  late _FakeProductRepository productRepository;
  late _FakePreferencesRepository preferences;
  late ProviderContainer container;

  setUp(() {
    productRepository = _FakeProductRepository();
    preferences = _FakePreferencesRepository();
    container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(productRepository),
        catalogPreferencesRepositoryProvider.overrideWith(
          (ref) async => preferences,
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  test(
    'loads the first page and restores saved favorites and searches',
    () async {
      final products = List.generate(20, (index) => _product(index + 1));
      productRepository.responses[''] = {
        0: _page(products, total: 21, skip: 0),
      };
      preferences.favoriteIds.add(2);
      preferences.recentSearches.add('phone');

      final viewModel = container.read(catalogViewModelProvider.notifier);
      await viewModel.loadInitial();

      final state = container.read(catalogViewModelProvider);
      expect(state.products, hasLength(20));
      expect(state.favoriteIds, contains(2));
      expect(state.recentSearches, ['phone']);
      expect(state.hasReachedEnd, isFalse);
      expect(productRepository.requests.single, ('', 0, 20));
    },
  );

  test('loads another page using the current item count as skip', () async {
    productRepository.responses[''] = {
      0: _page(
        List.generate(20, (index) => _product(index + 1)),
        total: 21,
        skip: 0,
      ),
      20: _page([_product(21)], total: 21, skip: 20),
    };
    final viewModel = container.read(catalogViewModelProvider.notifier);
    await viewModel.loadInitial();
    await viewModel.loadMore();

    final state = container.read(catalogViewModelProvider);
    expect(state.products, hasLength(21));
    expect(state.hasReachedEnd, isTrue);
    expect(productRepository.requests.last, ('', 20, 20));
  });

  test('search applies the query from the first page', () async {
    productRepository.responses[''] = {
      0: _page(
        List.generate(20, (index) => _product(index + 1)),
        total: 21,
        skip: 0,
      ),
      20: _page([_product(21)], total: 21, skip: 20),
    };
    productRepository.responses['watch'] = {
      0: _page([_product(8)], total: 1, skip: 0),
    };
    final viewModel = container.read(catalogViewModelProvider.notifier);
    await viewModel.loadInitial();
    await viewModel.loadMore();
    final search = viewModel.applySearch('watch');
    expect(container.read(catalogViewModelProvider).isInitialLoading, isTrue);
    expect(container.read(catalogViewModelProvider).products, isEmpty);
    await search;

    final state = container.read(catalogViewModelProvider);
    expect(state.searchQuery, 'watch');
    expect(state.products.map((product) => product.id), [8]);
    expect(productRepository.requests.last, ('watch', 0, 20));
  });

  test(
    'persists favorites and keeps recent searches unique and newest first',
    () async {
      productRepository.responses[''] = {0: _page([], total: 0, skip: 0)};
      final viewModel = container.read(catalogViewModelProvider.notifier);
      await viewModel.loadInitial();
      await viewModel.toggleFavorite(_product(7));
      await viewModel.recordSearch('Wireless headphones');
      await viewModel.recordSearch('wireless headphones');

      expect(preferences.favoriteIds, contains(7));
      expect(preferences.recentSearches, ['wireless headphones']);
      expect(container.read(catalogViewModelProvider).favoriteIds, contains(7));
    },
  );

  test(
    'keeps five recent searches, moves duplicates to the top, and clears history',
    () async {
      productRepository.responses[''] = {0: _page([], total: 0, skip: 0)};
      final viewModel = container.read(catalogViewModelProvider.notifier);
      await viewModel.loadInitial();

      for (var index = 1; index <= 6; index++) {
        await viewModel.recordSearch('Search $index');
      }
      await viewModel.recordSearch('SEARCH 4');

      expect(container.read(catalogViewModelProvider).recentSearches, [
        'SEARCH 4',
        'Search 6',
        'Search 5',
        'Search 3',
        'Search 2',
      ]);
      expect(preferences.recentSearches, hasLength(catalogRecentSearchLimit));

      await viewModel.clearRecentSearches();

      expect(container.read(catalogViewModelProvider).recentSearches, isEmpty);
      expect(preferences.recentSearches, isEmpty);
    },
  );

  test('exposes an offline error with retry-ready state', () async {
    productRepository.failure = const ApiException(
      userMessage:
          'No internet connection. Check your connection and try again.',
      isNetworkError: true,
    );

    final viewModel = container.read(catalogViewModelProvider.notifier);
    await viewModel.loadInitial();
    await viewModel.loadMore();

    final state = container.read(catalogViewModelProvider);
    expect(state.isInitialLoading, isFalse);
    expect(state.isNetworkError, isTrue);
    expect(state.errorMessage, contains('No internet connection'));
    expect(productRepository.requests, hasLength(1));
  });

  test(
    'keeps products and retries refresh instead of loading another page',
    () async {
      productRepository.responses[''] = {
        0: _page([_product(1)], total: 21, skip: 0),
      };
      final viewModel = container.read(catalogViewModelProvider.notifier);
      await viewModel.loadInitial();
      productRepository.failure = const ApiException(
        userMessage:
            'No internet connection. Check your connection and try again.',
        isNetworkError: true,
      );

      await viewModel.refresh();
      await viewModel.loadMore();

      final state = container.read(catalogViewModelProvider);
      expect(state.products, hasLength(1));
      expect(state.isRefreshError, isTrue);
      expect(productRepository.requests, hasLength(2));
    },
  );
}

ProductModel _product(int id) =>
    ProductModel(id: id, title: 'Product $id', price: id.toDouble());

ListResponse<ProductModel> _page(
  List<ProductModel> items, {
  required int total,
  required int skip,
}) => ListResponse<ProductModel>(
  items: items,
  pagination: PaginationMeta(total: total, skip: skip, limit: 20),
);

class _FakeProductRepository implements ProductRepository {
  final Map<String, Map<int, ListResponse<ProductModel>>> responses = {};
  final List<(String, int, int)> requests = [];
  Object? failure;

  @override
  Future<ListResponse<ProductModel>> getProducts({
    required int limit,
    required int skip,
    String query = '',
  }) async {
    requests.add((query, skip, limit));
    if (failure case final error?) throw error;
    return responses[query]?[skip] ?? _page([], total: 0, skip: skip);
  }

  @override
  Future<ProductModel> getProduct(int id) async => _product(id);
}

class _FakePreferencesRepository implements CatalogPreferencesRepository {
  final Set<int> favoriteIds = {};
  final List<String> recentSearches = [];

  @override
  Future<Set<int>> getFavoriteIds() async => {...favoriteIds};

  @override
  Future<List<String>> getRecentSearches() async => [...recentSearches];

  @override
  Future<void> setFavorite(int productId, {required bool isFavorite}) async {
    if (isFavorite) {
      favoriteIds.add(productId);
    } else {
      favoriteIds.remove(productId);
    }
  }

  @override
  Future<void> addRecentSearch(String query) async {
    recentSearches.removeWhere(
      (item) => item.toLowerCase() == query.toLowerCase(),
    );
    recentSearches.insert(0, query);
    if (recentSearches.length > catalogRecentSearchLimit) {
      recentSearches.removeRange(
        catalogRecentSearchLimit,
        recentSearches.length,
      );
    }
  }

  @override
  Future<void> clearRecentSearches() async => recentSearches.clear();
}
