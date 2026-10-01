import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/generic_api_service.dart';
import '../../core/providers/providers.dart';
import '../../modules/features/catalog/data/repositories/catalog_preferences_repository_impl.dart';
import '../../modules/features/catalog/data/repositories/product_repository_impl.dart';
import '../../modules/features/catalog/domain/repositories/catalog_preferences_repository.dart';
import '../../modules/features/catalog/domain/repositories/product_repository.dart';

part 'providers.g.dart';

@riverpod
GenericApiService genericApiService(Ref ref) =>
    GenericApiService(ref.watch(dioProvider));

@riverpod
ProductRepository productRepository(Ref ref) =>
    ProductRepositoryImpl(ref.watch(genericApiServiceProvider));

@riverpod
Future<CatalogPreferencesRepository> catalogPreferencesRepository(Ref ref) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return CatalogPreferencesRepositoryImpl(preferences);
}