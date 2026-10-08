import 'package:ecommerce_app_task/core/utils/app_string.dart';
import 'package:ecommerce_app_task/features/products/provider/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app_task/core/utils/size_config.dart';
import 'package:ecommerce_app_task/features/products/presentation/product_listing_page.dart'; // ProductCard yahin hai

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sc = SizeConfig.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.favoritesTitle)),
      body: SafeArea(
        child: Consumer<FavoritesProvider>(
          builder: (context, favs, _) {
            final items = favs.favorites;

            if (items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border, size: 56),
                    SizedBox(height: 12),
                    Text(AppStrings.noFavorites),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.fromLTRB(
                sc.hPadding,
                sc.height * 0.01,
                sc.hPadding,
                sc.gap,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: sc.gridColumns,
                mainAxisSpacing: sc.gap * 0.3,
                crossAxisSpacing: sc.gap * 0.3,
                childAspectRatio: 0.72,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final product = items[index];
                return ProductCard(
                  key: ValueKey(product.id),
                  product: product,
                  isFavorite: true, // is page mein sab liked hain
                  onFavoriteTap: () => favs.toggle(product), // unlike = list se hat jaayega
                );
              },
            );
          },
        ),
      ),
    );
  }
}