const catalogRecentSearchLimit = 5;

abstract interface class CatalogPreferencesRepository {
  Future<Set<int>> getFavoriteIds();

  Future<void> setFavorite(int productId, {required bool isFavorite});

  Future<List<String>> getRecentSearches();

  Future<void> addRecentSearch(String query);

  Future<void> clearRecentSearches();
}
