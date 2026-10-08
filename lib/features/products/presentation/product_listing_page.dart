import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app_task/core/utils/app_string.dart';
import 'package:ecommerce_app_task/core/utils/size_config.dart';
import 'package:ecommerce_app_task/features/products/data/product_model.dart';
import 'package:ecommerce_app_task/features/products/presentation/product_detail_page.dart';
import 'package:ecommerce_app_task/features/products/provider/favorite_provider.dart';
import 'package:ecommerce_app_task/features/products/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ProductListingPage extends StatefulWidget {
  const ProductListingPage({super.key});

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {


  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;



  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(query: '');
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      // Naye search par list top se dikhe
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
      context.read<ProductProvider>().loadProducts(query: value.trim());
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<ProductProvider>().loadMore();
    }
  }

  void _fillScreenIfNeeded() {
    if (!mounted || !_scrollController.hasClients) return;
    final provider = context.read<ProductProvider>();
    if (_scrollController.position.maxScrollExtent <= 0 &&
        provider.hasMore &&
        !provider.isLoading &&
        !provider.isLoadingMore) {
      provider.loadMore();
    }
  }


  @override
  Widget build(BuildContext context) {
    final sc = SizeConfig.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.navProduct)),
        body: SafeArea(
          child: getHomeTab(sc)
        ),
      ),
    );
  }


  Widget getHomeTab(SizeConfig sc) {
    return Column(
      children: [
        getSearchBar(sc),
        Expanded(
          child: getProductGrid(sc),
        ),
      ],
    );
  }

  Widget getSearchBar(SizeConfig sc) {
    return Padding(
      padding: EdgeInsets.only(
        right: sc.width * 0.04,
        left: sc.width * 0.04,
        top: sc.height * 0.01,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {}); // clear (X) button dikhane/chhupane ke liye
          _onSearchChanged(value);
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? IconButton(
            onPressed: () {},
            tooltip: 'Filter',
            icon: const Icon(Icons.tune_rounded),
          )
              : IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              setState(() {});
              _onSearchChanged('');
            },
          ),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }




  Widget getProductGrid(SizeConfig sc) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        // Pehla page load ho raha hai
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error aur list khaali
        if (provider.error != null && provider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(provider.error!),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: provider.loadProducts,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _fillScreenIfNeeded());

        return RefreshIndicator(
          onRefresh: provider.refreshProducts,
          child: CustomScrollView(
            controller: _scrollController,
            // Zaroori: warna kam items par pull-to-refresh kaam nahi karta
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  sc.hPadding,
                  sc.height * 0.01,
                  sc.hPadding,
                  sc.gap,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: sc.gridColumns,
                    mainAxisSpacing: sc.gap * 0.3,
                    crossAxisSpacing: sc.gap * 0.3,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final product = provider.products[index];
                      // Sirf ye card rebuild hoga jab uska like badle
                      return Consumer<FavoritesProvider>(
                        builder: (context, favs, _) => ProductCard(
                          key: ValueKey(product.id),
                          product: product,
                          isFavorite: favs.isFavorite(product.id),
                          onFavoriteTap: () => favs.toggle(product),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder:(_)=> ProductDetailPage(product: product)));
                          },
                        ),
                      );
                    },
                    childCount: provider.products.length,
                  ),
                ),
              ),

              // Neeche ka loader (jab tak next 10 aa rahe hain)
              if (provider.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),

              // Sab products aa gaye
              if (!provider.hasMore && provider.products.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('End of the List')),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }


}


class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const ProductCard({
    super.key,
    required this.product,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: product.thumbnail,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton.filledTonal(
                      onPressed: onFavoriteTap,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(product.rating.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}