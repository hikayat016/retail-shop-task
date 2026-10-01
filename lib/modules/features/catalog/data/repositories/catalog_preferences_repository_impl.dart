import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/catalog_preferences_repository.dart';

class CatalogPreferencesRepositoryImpl implements CatalogPreferencesRepository {
  const CatalogPreferencesRepositoryImpl(this._preferences);

  static const _favoriteIdsKey = 'catalog.favorite_ids';
  static const _recentSearchesKey = 'catalog.recent_searches';

  final SharedPreferences _preferences;

  @override
  Future<Set<int>> getFavoriteIds() async =>
      (_preferences.getStringList(_favoriteIdsKey) ?? const [])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();

  @override
  Future<void> setFavorite(int productId, {required bool isFavorite}) async {
    final favorites = await getFavoriteIds();
    if (isFavorite) {
      favorites.add(productId);
    } else {
      favorites.remove(productId);
    }
    await _preferences.setStringList(
      _favoriteIdsKey,
      favorites.map((id) => id.toString()).toList(growable: false),
    );
  }

  @override
  Future<List<String>> getRecentSearches() async =>
      _preferences.getStringList(_recentSearchesKey) ?? const [];

  @override
  Future<void> addRecentSearch(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;

    final searches = await getRecentSearches();
    final updated = [
      normalizedQuery,
      ...searches.where(
        (item) => item.toLowerCase() != normalizedQuery.toLowerCase(),
      ),
    ].take(catalogRecentSearchLimit).toList(growable: false);
    await _preferences.setStringList(_recentSearchesKey, updated);
  }

  @override
  Future<void> clearRecentSearches() async {
    await _preferences.remove(_recentSearchesKey);
  }
}
