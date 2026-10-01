// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CatalogViewModel)
final catalogViewModelProvider = CatalogViewModelProvider._();

final class CatalogViewModelProvider
    extends $NotifierProvider<CatalogViewModel, CatalogState> {
  CatalogViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogViewModelHash();

  @$internal
  @override
  CatalogViewModel create() => CatalogViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogState>(value),
    );
  }
}

String _$catalogViewModelHash() => r'9457076b34372687d34109c35014528939e05594';

abstract class _$CatalogViewModel extends $Notifier<CatalogState> {
  CatalogState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CatalogState, CatalogState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CatalogState, CatalogState>,
              CatalogState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
