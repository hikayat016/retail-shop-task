// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(genericApiService)
final genericApiServiceProvider = GenericApiServiceProvider._();

final class GenericApiServiceProvider
    extends
        $FunctionalProvider<
          GenericApiService,
          GenericApiService,
          GenericApiService
        >
    with $Provider<GenericApiService> {
  GenericApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'genericApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$genericApiServiceHash();

  @$internal
  @override
  $ProviderElement<GenericApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GenericApiService create(Ref ref) {
    return genericApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GenericApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GenericApiService>(value),
    );
  }
}

String _$genericApiServiceHash() => r'06a1171a8f95e515cd7e34bcfd41e829ae92e26a';

@ProviderFor(productRepository)
final productRepositoryProvider = ProductRepositoryProvider._();

final class ProductRepositoryProvider
    extends
        $FunctionalProvider<
          ProductRepository,
          ProductRepository,
          ProductRepository
        >
    with $Provider<ProductRepository> {
  ProductRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProductRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProductRepository create(Ref ref) {
    return productRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductRepository>(value),
    );
  }
}

String _$productRepositoryHash() => r'a03ba75d4882f631937e2da5363304c22377170b';

@ProviderFor(catalogPreferencesRepository)
final catalogPreferencesRepositoryProvider =
    CatalogPreferencesRepositoryProvider._();

final class CatalogPreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<CatalogPreferencesRepository>,
          CatalogPreferencesRepository,
          FutureOr<CatalogPreferencesRepository>
        >
    with
        $FutureModifier<CatalogPreferencesRepository>,
        $FutureProvider<CatalogPreferencesRepository> {
  CatalogPreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogPreferencesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogPreferencesRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<CatalogPreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CatalogPreferencesRepository> create(Ref ref) {
    return catalogPreferencesRepository(ref);
  }
}

String _$catalogPreferencesRepositoryHash() =>
    r'5602bee84812d1b1f00398b0c1648cf35222897a';
