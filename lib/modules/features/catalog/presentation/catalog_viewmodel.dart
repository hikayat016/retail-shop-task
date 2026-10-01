import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/providers/providers.dart';
import '../../../../core/network/api_exception.dart';
import '../data/models/product_model.dart';
import '../domain/repositories/catalog_preferences_repository.dart';
import 'catalog_state.dart';

part 'catalog_viewmodel.g.dart';

const catalogPageSize = 20;

@riverpod
class CatalogViewModel extends _$CatalogViewModel {
  var _requestVersion = 0;

  @override
  CatalogState build() => const CatalogState();

  Future<void> loadInitial() async {
    await _loadFirstPage(query: state.searchQuery, clearProducts: true);
  }

  Future<void> applySearch(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery == state.searchQuery && state.products.isNotEmpty) {
      return;
    }
    await _loadFirstPage(query: normalizedQuery, clearProducts: true);
  }

  Future<void> refresh() async {
    await _loadFirstPage(
      query: state.searchQuery,
      clearProducts: false,
      refreshing: true,
    );
  }

  Future<void> loadMore() async {
    if (state.isInitialLoading ||
        state.isRefreshing ||
        state.isLoadingMore ||
        state.products.isEmpty ||
        state.isRefreshError ||
        state.hasReachedEnd) {
      return;
    }

    final requestVersion = _requestVersion;
    final query = state.searchQuery;
    state = state.copyWith(
      isLoadingMore: true,
      errorMessage: '',
      isNetworkError: false,
      isRefreshError: false,
    );

    try {
      final response = await ref
          .read(productRepositoryProvider)
          .getProducts(
            limit: catalogPageSize,
            skip: state.products.length,
            query: query,
          );
      if (requestVersion != _requestVersion) return;

      final existingIds = state.products.map((product) => product.id).toSet();
      final newProducts = response.items
          .where((product) => existingIds.add(product.id))
          .toList(growable: false);
      state = state.copyWith(
        products: [...state.products, ...newProducts],
        isLoadingMore: false,
        hasReachedEnd: !response.pagination.hasMore || response.items.isEmpty,
      );
    } on ApiException catch (error) {
      if (requestVersion != _requestVersion) return;
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.userMessage,
        isNetworkError: error.isNetworkError,
        isRefreshError: false,
      );
    } catch (_) {
      if (requestVersion != _requestVersion) return;
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'We could not load more products. Please try again.',
      );
    }
  }

  Future<void> toggleFavorite(ProductModel product) async {
    final isFavorite = !state.favoriteIds.contains(product.id);
    final preferences = await ref.read(
      catalogPreferencesRepositoryProvider.future,
    );
    await preferences.setFavorite(product.id, isFavorite: isFavorite);

    final favorites = {...state.favoriteIds};
    if (isFavorite) {
      favorites.add(product.id);
    } else {
      favorites.remove(product.id);
    }
    state = state.copyWith(favoriteIds: favorites);
  }

  Future<void> recordSearch(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;

    final preferences = await ref.read(
      catalogPreferencesRepositoryProvider.future,
    );
    await preferences.addRecentSearch(normalizedQuery);
    final updatedSearches = [
      normalizedQuery,
      ...state.recentSearches.where(
        (item) => item.toLowerCase() != normalizedQuery.toLowerCase(),
      ),
    ].take(catalogRecentSearchLimit).toList(growable: false);
    state = state.copyWith(recentSearches: updatedSearches);
  }

  Future<void> clearRecentSearches() async {
    final preferences = await ref.read(
      catalogPreferencesRepositoryProvider.future,
    );
    await preferences.clearRecentSearches();
    state = state.copyWith(recentSearches: const []);
  }

  Future<void> _loadFirstPage({
    required String query,
    required bool clearProducts,
    bool refreshing = false,
  }) async {
    final requestVersion = ++_requestVersion;
    state = state.copyWith(
      searchQuery: query,
      isInitialLoading: clearProducts || (refreshing && state.products.isEmpty),
      isRefreshing: refreshing && state.products.isNotEmpty,
      isLoadingMore: false,
      hasReachedEnd: false,
      isRefreshError: false,
      products: clearProducts ? const [] : state.products,
      errorMessage: '',
      isNetworkError: false,
    );

    try {
      final preferences = await ref.read(
        catalogPreferencesRepositoryProvider.future,
      );
      final favoriteIds = await preferences.getFavoriteIds();
      final recentSearches = await preferences.getRecentSearches();
      if (requestVersion != _requestVersion) return;
      state = state.copyWith(
        favoriteIds: favoriteIds,
        recentSearches: recentSearches,
      );

      final response = await ref
          .read(productRepositoryProvider)
          .getProducts(limit: catalogPageSize, skip: 0, query: query);
      if (requestVersion != _requestVersion) return;

      state = state.copyWith(
        products: response.items,
        isInitialLoading: false,
        isRefreshing: false,
        hasReachedEnd: !response.pagination.hasMore || response.items.isEmpty,
      );
    } on ApiException catch (error) {
      if (requestVersion != _requestVersion) return;
      state = state.copyWith(
        isInitialLoading: false,
        isRefreshing: false,
        errorMessage: error.userMessage,
        isNetworkError: error.isNetworkError,
        isRefreshError: refreshing,
      );
    } catch (_) {
      if (requestVersion != _requestVersion) return;
      state = state.copyWith(
        isInitialLoading: false,
        isRefreshing: false,
        errorMessage: 'We could not load products. Please try again.',
        isRefreshError: refreshing,
      );
    }
  }
}
