import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app_task/core/utils/app_string.dart';
import 'package:ecommerce_app_task/core/utils/size_config.dart';
import 'package:ecommerce_app_task/features/products/data/product_model.dart';
import 'package:ecommerce_app_task/features/products/presentation/favorite_page.dart';
import 'package:ecommerce_app_task/features/products/presentation/product_detail_page.dart';
import 'package:ecommerce_app_task/features/products/presentation/product_listing_page.dart';
import 'package:ecommerce_app_task/features/products/presentation/profile_page.dart';
import 'package:ecommerce_app_task/features/products/provider/favorite_provider.dart';
import 'package:ecommerce_app_task/features/products/provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // setState ki jagah ValueNotifier: sirf zaroori widget rebuild hoga
  final ValueNotifier<int> _currentTab = ValueNotifier(0);
  final ValueNotifier<int> _selectedCategory = ValueNotifier(0);

  static const _categories = [
    ('All', Icons.grid_view_rounded),
    ('Electronics', Icons.devices_rounded),
    ('Fashion', Icons.checkroom_rounded),
    ('Home', Icons.home_rounded),
    ('Beauty', Icons.face_retouching_natural),
  ];

  final Set<int> _visitedTabs = {0};
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadProducts(query: '');
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _currentTab.dispose();
    _selectedCategory.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<HomeProvider>().loadProducts(query: value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final sc = SizeConfig.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: ValueListenableBuilder<int>(

            valueListenable: _currentTab,
            child: getHomeTab(sc),
            builder: (_, index, homeTab) {
              _visitedTabs.add(index);
             return  IndexedStack(
                index: index,
                children: [
                  homeTab!,
                  _visitedTabs.contains(1)
                      ? const ProductListingPage()
                      : const SizedBox.shrink(),
                  FavoritesPage(),
                  ProfilePage(),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: getBottomNav(),
      ),
    );
  }

  // ---------------- Home tab ----------------

  Widget getHomeTab(SizeConfig sc) {
    return RefreshIndicator(
      onRefresh: () => context.read<HomeProvider>().refreshProducts(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: sc.hPadding),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  getHeader(sc),
                  getSearchBar(sc),
                  getBanner(sc),
                  // getCategories(sc),
                  getSectionTitle(sc),
                ],
              ),
            ),
          ),
          getProductGrid(sc),
        ],
      ),
    );
  }

  Widget getHeader(SizeConfig sc) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: sc.gap),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Shopper 👋',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: () {},
            tooltip: AppStrings.notifications,
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }

  Widget getSearchBar(SizeConfig sc) {
    return Padding(
      padding: EdgeInsets.only(top: sc.gap),
      // controller sunta hai, to clear (X) button ke liye setState nahi chahiye
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (_, value, __) => TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
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
      ),
    );
  }

  Widget getBanner(SizeConfig sc) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(top: sc.gap),
      child: Container(
        padding: EdgeInsets.all(sc.shortest * 0.05),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Big Deals',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Up to 50% OFF',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimary,
                    ),
                  ),
                  SizedBox(height: sc.gap),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.onPrimary,
                      foregroundColor: scheme.primary,
                    ),
                    child: const Text('Shop Now'),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.headphones_rounded,
              size: sc.shortest * 0.28,
              color: scheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget getCategories(SizeConfig sc) {
    final circle = (sc.shortest * 0.14).clamp(48.0, 64.0);

    return Padding(
      padding: EdgeInsets.only(top: sc.gap),
      child: SizedBox(
        height: circle + 36,
        // Sirf category list rebuild hogi, poori screen nahi
        child: ValueListenableBuilder<int>(
          valueListenable: _selectedCategory,
          builder: (_, selected, __) {
            final scheme = Theme.of(context).colorScheme;
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => SizedBox(width: sc.hPadding),
              itemBuilder: (_, i) {
                final isSelected = i == selected;
                return GestureDetector(
                  onTap: () => _selectedCategory.value = i,
                  child: Column(
                    children: [
                      Container(
                        height: circle,
                        width: circle,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? scheme.primary
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _categories[i].$2,
                          color: isSelected
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _categories[i].$1,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget getSectionTitle(SizeConfig sc) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: sc.gap, bottom: sc.gap * 0.6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Consumer<HomeProvider>(
              builder: (context, home, _) => Text(
                home.query.isEmpty
                    ? 'Popular Products'
                    : 'Results for "${home.query}"',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => _currentTab.value = 1, // Product tab
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }

  Widget getProductGrid(SizeConfig sc) {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        // Loading
        if (home.isLoading) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sc.gap * 3),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Error aur list khaali
        if (home.error != null && home.products.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sc.gap * 2),
              child: Column(
                children: [
                  Text(home.error!),
                  Padding(
                    padding: EdgeInsets.only(top: sc.gap * 0.6),
                    child: ElevatedButton(
                      onPressed: () => home.loadProducts(),
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (home.products.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sc.gap * 2),
              child: Center(
                child: Text('"${home.query}" No Result found!'),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(sc.hPadding, 0, sc.hPadding, sc.gap),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: sc.gridColumns,
              mainAxisSpacing: sc.gap * 0.6,
              crossAxisSpacing: sc.gap * 0.6,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final product = home.products[index];
                return Consumer<FavoritesProvider>(
                  builder: (context, favs, _) => ProductCard(
                    key: ValueKey(product.id),
                    product: product,
                    isFavorite: favs.isFavorite(product.id),
                    onFavoriteTap: () => favs.toggle(product),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: product),
                      ),
                    ),
                  ),
                );
              },
              childCount: home.products.length,
            ),
          ),
        );
      },
    );
  }

  // ---------------- Other tabs / nav ----------------

  Widget getPlaceholderTab(String title) {
    return Center(child: Text('$title (coming soon)'));
  }

  Widget getBottomNav() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentTab,
      builder: (_, index, __) => NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => _currentTab.value = i,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: AppStrings.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.store_mall_directory_outlined),
            label: AppStrings.navProduct,
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: AppStrings.navFavorites,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: AppStrings.navProfile,
          ),
        ],
      ),
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