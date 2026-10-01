import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/models/product_model.dart';

part 'catalog_state.freezed.dart';

@freezed
abstract class CatalogState with _$CatalogState {
  const factory CatalogState({
    @Default(false) bool isInitialLoading,
    @Default(false) bool isRefreshing,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasReachedEnd,
    @Default('') String searchQuery,
    @Default([]) List<ProductModel> products,
    @Default(<int>{}) Set<int> favoriteIds,
    @Default([]) List<String> recentSearches,
    @Default('') String errorMessage,
    @Default(false) bool isNetworkError,
    @Default(false) bool isRefreshError,
  }) = _CatalogState;
}