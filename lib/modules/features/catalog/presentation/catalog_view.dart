import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation/application/router.dart';
import 'catalog_viewmodel.dart';
import 'widgets/product_tile.dart';

class CatalogView extends ConsumerStatefulWidget {
  const CatalogView({super.key});

  @override
  ConsumerState<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends ConsumerState<CatalogView> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(catalogViewModelProvider.notifier).loadInitial());
      }
    });
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
    _searchDebounce?.cancel();
    final query = _searchController.text;
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(ref.read(catalogViewModelProvider.notifier).applySearch(query));
    });
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 480) {
      unawaited(ref.read(catalogViewModelProvider.notifier).loadMore());
    }
  }

  void _submitSearch(String query) {
    _searchDebounce?.cancel();
    final viewModel = ref.read(catalogViewModelProvider.notifier);
    unawaited(viewModel.recordSearch(query));
    unawaited(viewModel.applySearch(query));
    _searchFocusNode.unfocus();
  }

  void _selectRecentSearch(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
    _submitSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogViewModelProvider);
    final viewModel = ref.read(catalogViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Product catalogue')),
      body: RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildSearchBar()),
                if (_searchFocusNode.hasFocus &&
                    state.recentSearches.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildRecentSearches(context, state.recentSearches),
                  ),
                if (state.isInitialLoading && state.products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.errorMessage.isNotEmpty &&
                    state.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildMessageState(
                      context,
                      icon: state.isNetworkError
                          ? Icons.wifi_off_rounded
                          : Icons.error_outline_rounded,
                      title: state.isNetworkError
                          ? 'You are offline'
                          : 'Could not load products',
                      message: state.errorMessage,
                      actionLabel: 'Try again',
                      onAction: viewModel.refresh,
                    ),
                  )
                else if (!state.isInitialLoading && state.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildMessageState(
                      context,
                      icon: Icons.search_off_rounded,
                      title: state.searchQuery.isEmpty
                          ? 'No products yet'
                          : 'No matches found',
                      message: state.searchQuery.isEmpty
                          ? 'Pull down to try loading the catalogue again.'
                          : 'Try another product name.',
                      actionLabel: state.searchQuery.isEmpty
                          ? 'Retry'
                          : 'Clear search',
                      onAction: state.searchQuery.isEmpty
                          ? viewModel.refresh
                          : () async => _searchController.clear(),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    sliver: SliverList.builder(
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ProductTile(
                            product: product,
                            isFavorite: state.favoriteIds.contains(product.id),
                            onFavoritePressed: () =>
                                unawaited(viewModel.toggleFavorite(product)),
                            onTap: () => PageRouter.push<void>(
                              context,
                              AppRoute.productDetail,
                              arguments: product,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (state.errorMessage.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildInlineError(
                        state.errorMessage,
                        state.isRefreshError
                            ? viewModel.refresh
                            : viewModel.loadMore,
                        state.isRefreshError
                            ? 'Retry refresh'
                            : 'Retry loading more',
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: SearchBar(
      controller: _searchController,
      focusNode: _searchFocusNode,
      hintText: 'Search products',
      leading: const Icon(Icons.search_rounded),
      onTap: () => setState(() {}),
      onChanged: (_) {},
      onSubmitted: _submitSearch,
      trailing: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            tooltip: 'Clear search',
            onPressed: _searchController.clear,
            icon: const Icon(Icons.close_rounded),
          ),
      ],
    ),
  );

  Widget _buildRecentSearches(BuildContext context, List<String> searches) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent searches',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => unawaited(
                    ref
                        .read(catalogViewModelProvider.notifier)
                        .clearRecentSearches(),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: searches
                  .map(
                    (query) => ActionChip(
                      avatar: const Icon(Icons.history_rounded),
                      label: Text(query),
                      onPressed: () => _selectRecentSearch(query),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      );

  Widget _buildMessageState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required Future<void> Function() onAction,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => unawaited(onAction()),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError(
    String message,
    Future<void> Function() retry,
    String actionLabel,
  ) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        TextButton.icon(
          onPressed: () => unawaited(retry()),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(actionLabel),
        ),
      ],
    ),
  );
}
