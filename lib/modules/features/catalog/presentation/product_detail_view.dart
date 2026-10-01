import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_viewmodel.dart';
import '../data/models/product_model.dart';

class ProductDetailView extends ConsumerWidget {
  const ProductDetailView({required this.product, super.key});

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogViewModelProvider);
    final isFavorite = state.favoriteIds.contains(product.id);
    final images = product.images.isEmpty ? [product.thumbnail] : product.images;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () => ref
                .read(catalogViewModelProvider.notifier)
                .toggleFavorite(product),
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 840;
          final imageGallery = _ProductGallery(images: images, title: product.title);
          final productInformation = _ProductInformation(product: product);

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: imageGallery),
                            const SizedBox(width: 32),
                            Expanded(flex: 6, child: productInformation),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [imageGallery, const SizedBox(height: 24), productInformation],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductGallery extends StatelessWidget {
  const _ProductGallery({required this.images, required this.title});

  final List<String> images;
  final String title;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 1.1,
        child: PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) => _ProductImage(
            imageUrl: images[index],
            semanticLabel: '$title image ${index + 1}',
          ),
        ),
      );
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl, required this.semanticLabel});

  final String imageUrl;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainerLow,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        semanticLabel: semanticLabel,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.category.isNotEmpty)
          Text(product.category.toUpperCase(), style: textTheme.labelLarge),
        const SizedBox(height: 8),
        Text(product.title, style: textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text('\$${product.price.toStringAsFixed(2)}', style: textTheme.headlineMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.star_rounded, color: colorScheme.tertiary),
            const SizedBox(width: 6),
            Text(product.rating.toStringAsFixed(1), style: textTheme.titleMedium),
            const SizedBox(width: 16),
            Icon(Icons.inventory_2_outlined, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text('${product.stock} in stock'),
          ],
        ),
        const SizedBox(height: 24),
        Text('Description', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(product.description, style: textTheme.bodyLarge),
      ],
    );
  }
}