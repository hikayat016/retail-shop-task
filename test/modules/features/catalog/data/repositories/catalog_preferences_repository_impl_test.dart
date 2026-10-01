import 'package:flutter_test/flutter_test.dart';
import 'package:retail_shop_catalog/modules/features/catalog/data/repositories/catalog_preferences_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'persists only five unique searches with the latest search first',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final repository = CatalogPreferencesRepositoryImpl(preferences);

      for (var index = 1; index <= 6; index++) {
        await repository.addRecentSearch('Search $index');
      }
      await repository.addRecentSearch('SEARCH 4');

      expect(await repository.getRecentSearches(), [
        'SEARCH 4',
        'Search 6',
        'Search 5',
        'Search 3',
        'Search 2',
      ]);

      await repository.clearRecentSearches();

      expect(await repository.getRecentSearches(), isEmpty);
    },
  );
}
