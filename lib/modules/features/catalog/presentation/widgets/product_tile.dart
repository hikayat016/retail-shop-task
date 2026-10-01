import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    required this.product,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onTap,
    super.key,
  });

  final ProductModel product;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.outlined(
      child: ListTile(
        minVerticalPadding: 12,
        leading: SizedBox.square(
          dimension: 76,
          child: Image.network(
            product.thumbnail,
            fit: BoxFit.cover,
            semanticLabel: product.title,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        title: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('\$${product.price.toStringAsFixed(2)}'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 18, color: colorScheme.tertiary),
                  const SizedBox(width: 4),
                  Text(product.rating.toStringAsFixed(1)),
                ],
              ),
            ],
          ),
        ),
        trailing: IconButton(
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          onPressed: onFavoritePressed,
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? colorScheme.primary : null,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}