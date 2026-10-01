> Part of `READMEFIRST/`. See [README.md](README.md) for the index.

# Architecture Notes

This guide explains how the catalogue is put together and where to start when changing it. It assumes basic Dart and Flutter familiarity, but explains the architecture terms as they appear.

## The short version

The screen draws the UI and forwards user actions. A Riverpod ViewModel handles those actions and owns the current screen state. Repositories hide where data comes from: the product repository talks to DummyJSON, while the preferences repository saves favorites and recent searches on the device.

```text
User action
  -> View (widgets)
  -> ViewModel (state + work)
  -> Repository contract (what data is needed)
  -> Repository implementation (how data is obtained)
  -> GenericApiService / SharedPreferences
  -> DummyJSON / device storage
```

The result travels back up the same path: the ViewModel publishes new state, and Riverpod rebuilds the widgets that are watching that state.

## Why Riverpod and Freezed

This project follows the supplied SuperDev Flutter architecture template, which uses Riverpod code generation and Freezed.

- **Riverpod** manages objects the app needs and lets widgets observe state. A generated provider is a managed access point to an object, such as a repository or ViewModel. The app can replace a provider with a fake in a test, so tests do not need the real network or device storage.
- **The ViewModel** is a Riverpod `Notifier`. It exposes named actions such as `loadInitial`, `applySearch`, `loadMore`, and `toggleFavorite`. It contains the workflow, but not widget layout or navigation.
- **Freezed** generates immutable state and `copyWith`. Instead of changing one field in a shared state object, the ViewModel creates a new state value with the requested fields changed. This makes related changes, such as updating the products and loading flag together, easier to reason about.
- **Code generation** creates provider and model support files from annotated Dart source. Those generated files are required to compile, but should never be edited directly. Change the annotated source and regenerate instead.

## What each layer does

| Layer | In this app | Responsibility |
| --- | --- | --- |
| Presentation | `presentation/catalog_view.dart`, `catalog_viewmodel.dart`, `catalog_state.dart`, `product_detail_view.dart` | Shows screens, handles interaction, and describes the state the screen needs. It does not make HTTP requests or parse JSON. |
| Domain | `domain/repositories/` | Defines repository contracts: the operations the feature needs, without choosing HTTP or storage details. |
| Data | `data/repositories/`, `data/models/product_model.dart` | Implements those contracts, converts API JSON into typed product models, and saves preferences. |
| App composition | `lib/app/providers/providers.dart`, `lib/app/navigation/` | Connects implementations to contracts and defines app navigation. |
| Core infrastructure | `lib/core/network/`, `lib/core/providers/`, `lib/core/theme/` | Provides reusable networking, platform dependencies, and Material 3 themes. |

Keeping these jobs separate has a practical benefit: a screen can change without rewriting the API parser, and the API can be faked in a test without rendering a real server response.

## One request, step by step

When the catalogue opens:

1. [`main.dart`](../lib/main.dart) starts Flutter inside a Riverpod `ProviderScope`. This makes app providers available below it.
2. [`RetailShopApp`](../lib/app/app.dart) creates the Material app. [`PageRouter`](../lib/app/navigation/application/router.dart) maps the initial route to `CatalogView`.
3. [`CatalogView`](../lib/modules/features/catalog/presentation/catalog_view.dart) schedules its initial load after the first frame. This timing matters: loading changes provider state, and Riverpod 3 does not allow that update while Flutter is mounting a widget in `initState`.
4. [`CatalogViewModel`](../lib/modules/features/catalog/presentation/catalog_viewmodel.dart) marks the state as loading, restores saved favorites and recent searches, then asks `ProductRepository` for 20 products.
5. The `ProductRepository` contract describes the request. `ProductRepositoryImpl` chooses `/products` or `/products/search` and supplies `limit`, `skip`, and the search query to `GenericApiService`.
6. `GenericApiService` uses the configured Dio client to make the HTTPS request. It reads DummyJSON's `products`, `total`, `skip`, and `limit` fields and calls the explicit decoder to create `ProductModel` objects. Network failures become `ApiException` with a user-facing message.
7. The ViewModel stores the returned products in a new `CatalogState`. The view watches the provider, rebuilds, and displays the product rows.

The separation is intentional: the ViewModel asks for typed products, not a URL or a `Map`; the repository owns the endpoint; and the network service owns Dio and response parsing.

## State, searching, and pagination

[`CatalogState`](../lib/modules/features/catalog/presentation/catalog_state.dart) is the catalogue screen's complete snapshot. It includes products, query, favorites, recent searches, loading flags, end-of-list status, and user-facing errors. The view reads this state and calls ViewModel methods; it does not keep a second copy of business state locally.

The API uses offset pagination. Every request asks for `limit: 20`; `skip` is the number of products already loaded. For example, the first request uses `skip: 0`, and the next uses `skip: 20`. The ViewModel blocks duplicate load-more calls while another request is active and stops when DummyJSON reports no more results.

Typing in the search field waits briefly before applying the query. Submitting it also saves it to recent searches. A new query clears the old result list and starts from `skip: 0`. Refresh keeps the current list visible until the fresh first page arrives. Each first-page request gets a version number; if a newer search or refresh starts first, an older response is ignored instead of overwriting the newer results.

## Local preferences

`CatalogPreferencesRepository` is the contract for favorites and recent searches. `CatalogPreferencesRepositoryImpl` stores favorite product IDs and the five most recent queries in SharedPreferences. New searches are placed first, case-insensitive duplicates are removed and moved to the top, and the search panel offers an action to clear the stored history. App wiring provides that implementation through Riverpod. On startup, saved favorites and searches are restored before the API call, so they remain available if the network is offline.

These preferences are ordinary UI data, not credentials or personal information. SharedPreferences is not encrypted; do not store passwords, tokens, or sensitive user data there.

## Navigation and theme

The product row asks `PageRouter` to open `AppRoute.productDetail` and passes a typed `ProductModel`. The router creates `ProductDetailView`; it does not pass unparsed JSON or an integer that the screen must use to make another request. The detail screen shows the product images, description, price, rating, and stock.

`AppTheme` creates light and dark Material 3 themes from a seed color. Feature widgets use `Theme.of(context)` roles for text and colors instead of hardcoding colors in screens. The detail layout adapts to the available width: it stacks the image and information on narrow screens and places them side by side on wider screens.

## Where to make common changes

| Change | Start here |
| --- | --- |
| Change loading, search, pagination, or favorite behavior | [`catalog_viewmodel.dart`](../lib/modules/features/catalog/presentation/catalog_viewmodel.dart) |
| Add or remove a field shown for a product | [`product_model.dart`](../lib/modules/features/catalog/data/models/product_model.dart), then regenerate code |
| Change product endpoints or JSON mapping | [`product_repository_impl.dart`](../lib/modules/features/catalog/data/repositories/product_repository_impl.dart) |
| Change how favorites or search history are stored | [`catalog_preferences_repository_impl.dart`](../lib/modules/features/catalog/data/repositories/catalog_preferences_repository_impl.dart) |
| Change the catalogue or detail layout | [`catalog_view.dart`](../lib/modules/features/catalog/presentation/catalog_view.dart) or [`product_detail_view.dart`](../lib/modules/features/catalog/presentation/product_detail_view.dart) |
| Wire a new repository or infrastructure service | [`providers.dart`](../lib/app/providers/providers.dart) |
| Change the app's colors or theme behavior | [`app_theme.dart`](../lib/core/theme/app_theme.dart) |

## Generated code and verification

After changing a Freezed model or a Riverpod annotation, run:

```powershell
fvm dart run build_runner build
fvm dart analyze
fvm flutter test
```

The build-runner output includes `*.g.dart` and `*.freezed.dart` files next to their source. Do not hand-edit those generated files.

## Current verification

Dependency resolution and code generation succeed. All 18 Flutter tests pass. `fvm dart analyze` reports no errors and one non-blocking style info in the copied theme guard. The current debug APK was smoke-tested on a Samsung SM A526B running Android 14 for startup, catalogue loading, search, detail navigation, recent-search rerun and clear, clear persistence after relaunch, favorite restoration, and pagination. The five-item cap and case-insensitive duplicate promotion are also covered by automated tests. Browser interaction and iOS device behavior have not been verified.