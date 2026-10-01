---
name: flutter-add-paginated-list
description: >-
  Adds paginated, searchable, filterable list flows in the BESTINET Flutter architecture. Use when
  implementing infinite scroll, pull-to-refresh, server-side paging, search, filters, or list reload
  behavior with Riverpod Notifiers, Freezed state, repositories, and GenericApiService.
---

# Flutter Add Paginated List

## Use When

- A screen loads pages from an API.
- A list supports refresh, search, filters, sorting, or load-more.
- The same paging pattern appears in more than one module.

## Required Architecture

- Read `flutter-bestinet-core` first.
- Keep the widget passive: it renders state and calls ViewModel methods.
- Put paging state in a Freezed state object or equivalent immutable state.
- Put API calls in the repository and use `GenericApiService.getList<T>` (or `postList<T>`) with an explicit
  `listDecoder`; read `ListResponse.items` and `ListResponse.pagination` (`PaginationMeta`).
- Keep search/filter query objects typed. Do not pass raw maps upward to the ViewModel.

## Recommended State Shape

Use a state shape equivalent to:

```dart
const factory ListState<T>({
  @Default(false) bool isInitialLoading,
  @Default(false) bool isRefreshing,
  @Default(false) bool isLoadingMore,
  @Default(false) bool hasReachedEnd,
  @Default(1) int page,
  @Default([]) List<T> items,
  @Default('') String searchTerm,
  @Default('') String errorMessage,
}) = _ListState<T>;
```

Feature states can inline these fields rather than introducing a shared generic type. Promote a
shared pagination abstraction only after two modules use the same pattern.

## ViewModel Rules

- `loadInitial()` resets page, clears stale errors, and replaces items.
- `refresh()` reloads page 1 without losing the current list until the response returns.
- `loadMore()` is a no-op when already loading or when `hasReachedEnd` is true.
- `applySearch()` or `applyFilter()` resets paging and reloads page 1.
- Every async transition must set all related loading flags atomically with `copyWith`.

## Repository Rules

- Repositories return a typed page result such as `PageResult<T>`.
- Page result should include `items`, `page`, and either `hasMore`, `totalPages`, or `totalCount`.
- DTOs stay in `data/models/`; domain/list items exposed to the UI are typed models.
- Empty pages are valid. They must not be treated as errors.

## Widget Rules

- Use `RefreshIndicator` for pull-to-refresh when appropriate.
- Trigger `loadMore()` from scroll extent checks or pagination controls, not from `build()` directly.
- Show first-load, empty, error, and incremental loading states separately.
- Keep row widgets stable and extract repeated list item UI into `presentation/widgets/`.
- M3: rows are `ListTile`s (or `Card`s in a feed/grid), first load uses `CircularProgressIndicator` or
  a skeleton, incremental load a `LinearProgressIndicator`/footer spinner, filters are `FilterChip`s
  or a `SegmentedButton`, search is `SearchAnchor`/`SearchBar`. On expanded width switch to a grid or
  list-detail layout (`flutter-bestinet-core/references/m3-design.md` §8–§9).

## Avoid

- Calling APIs from widgets.
- Mutating list instances in place.
- Resetting user filters on refresh unless explicitly requested.
- Showing developer error messages in the UI.
