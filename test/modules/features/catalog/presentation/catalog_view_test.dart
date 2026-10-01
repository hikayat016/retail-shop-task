import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retail_shop_catalog/app/providers/providers.dart';
import 'package:retail_shop_catalog/core/network/api_response.dart';
import 'package:retail_shop_catalog/modules/features/catalog/data/models/product_model.dart';
import 'package:retail_shop_catalog/modules/features/catalog/domain/repositories/catalog_preferences_repository.dart';
import 'package:retail_shop_catalog/modules/features/catalog/domain/repositories/product_repository.dart';
import 'package:retail_shop_catalog/modules/features/catalog/presentation/catalog_view.dart';

void main() {
  testWidgets('loads the first page after the widget tree mounts', (
    tester,
  ) async {
    final preferences = _FakeCatalogPreferencesRepository();
    final products = _FakeProductRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(products),
          catalogPreferencesRepositoryProvider.overrideWith(
            (ref) async => preferences,
          ),
        ],
        child: const MaterialApp(home: CatalogView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test product'), findsOneWidget);
    expect(products.requests, 1);
  });

  testWidgets(
    'shows and clears recent searches while the search field is focused',
    (tester) async {
      final preferences = _FakeCatalogPreferencesRepository()
        ..recentSearches.add('Essence');
      final products = _FakeProductRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productRepositoryProvider.overrideWithValue(products),
            catalogPreferencesRepositoryProvider.overrideWith(
              (ref) async => preferences,
            ),
          ],
          child: const MaterialApp(home: CatalogView()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();

      expect(find.text('Recent searches'), findsOneWidget);
      expect(find.text('Essence'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
      await tester.tap(find.text('Essence'));
      await tester.pumpAndSettle();

      expect(products.searchQueries.last, 'Essence');

      await tester.tap(find.byType(SearchBar));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(preferences.recentSearches, isEmpty);
      expect(find.byType(ActionChip), findsNothing);
    },
  );
}

class _FakeProductRepository implements ProductRepository {
  var requests = 0;
  final List<String> searchQueries = [];

  @override
  Future<ListResponse<ProductModel>> getProducts({
    required int limit,
    required int skip,
    String query = '',
  }) async {
    requests++;
    searchQueries.add(query);
    final items = query.isEmpty
        ? [const ProductModel(id: 1, title: 'Test product', price: 12.5)]
        : const <ProductModel>[];
    return ListResponse<ProductModel>(
      items: items,
      pagination: PaginationMeta(total: items.length, skip: skip, limit: limit),
    );
  }

  @override
  Future<ProductModel> getProduct(int id) async =>
      const ProductModel(id: 1, title: 'Test product', price: 12.5);
}

class _FakeCatalogPreferencesRepository
    implements CatalogPreferencesRepository {
  final List<String> recentSearches = [];

  @override
  Future<Set<int>> getFavoriteIds() async => {};

  @override
  Future<List<String>> getRecentSearches() async => [...recentSearches];

  @override
  Future<void> setFavorite(int productId, {required bool isFavorite}) async {}

  @override
  Future<void> addRecentSearch(String query) async {}

  @override
  Future<void> clearRecentSearches() async => recentSearches.clear();
}
