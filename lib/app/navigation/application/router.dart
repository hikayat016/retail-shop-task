import 'package:flutter/material.dart';

import '../../../modules/features/catalog/data/models/product_model.dart';
import '../../../modules/features/catalog/presentation/catalog_view.dart';
import '../../../modules/features/catalog/presentation/product_detail_view.dart';

enum AppRoute { catalog, productDetail }

abstract final class PageRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppRoute.catalog.name) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const CatalogView(),
      );
    }

    if (settings.name == AppRoute.productDetail.name) {
      final product = settings.arguments! as ProductModel;
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => ProductDetailView(product: product),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const _UnknownRouteView(),
    );
  }

  static Future<T?> push<T>(
    BuildContext context,
    AppRoute route, {
    Object? arguments,
  }) =>
      Navigator.of(context).pushNamed<T>(route.name, arguments: arguments);
}

class _UnknownRouteView extends StatelessWidget {
  const _UnknownRouteView();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Page not found')),
      );
}