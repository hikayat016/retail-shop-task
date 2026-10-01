import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'navigation/application/router.dart';

class RetailShopApp extends StatelessWidget {
  const RetailShopApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Retail Shop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        initialRoute: AppRoute.catalog.name,
        onGenerateRoute: PageRouter.onGenerateRoute,
      );
}