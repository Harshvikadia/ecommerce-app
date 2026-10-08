import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app_task/core/utils/app_string.dart';
import 'package:ecommerce_app_task/core/utils/size_config.dart';
import 'package:ecommerce_app_task/features/products/data/product_model.dart';
import 'package:ecommerce_app_task/features/products/provider/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Sirf dots rebuild honge, poora page nahi
  final ValueNotifier<int> _imageIndex = ValueNotifier(0);

  Product get p => widget.product;

  @override
  void dispose() {
    _imageIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sc = SizeConfig.of(context);
    final theme = Theme.of(context);
    final specRows = getSpecRows();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getImageGallery(sc, theme),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sc.hPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getSpaced(sc, getTitleSection(theme)),
                        getSpaced(sc, getPriceSection(theme)),
                        getSpaced(sc, getStockSection(theme)),
                        if (p.tags.isNotEmpty)
                          getSpaced(sc, getTagsSection()),
                        getSpaced(sc, getDescription(theme)),
                        getSpaced(sc, getInfoTiles(sc, theme)),
                        if (specRows.isNotEmpty)
                          getSpaced(sc, getSpecsCard(theme, specRows)),
                        if (p.reviews.isNotEmpty) ...[
                          getSpaced(sc, getRatingSummary(theme)),
                          ...p.reviews.map(
                                (r) => Padding(
                              padding: EdgeInsets.only(top: sc.gap * 0.3),
                              child: getReviewCard(theme, r),
                            ),
                          ),
                        ],
                        Padding(padding: EdgeInsets.only(bottom: sc.gap)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          getBottomBar(sc, theme),
        ],
      ),
    );
  }

  // ---------------- Common helpers ----------------

  // Har section ke upar gap (SizedBox ki jagah Padding)
  Widget getSpaced(SizeConfig sc, Widget child) {
    return Padding(
      padding: EdgeInsets.only(top: sc.gap),
      child: child,
    );
  }

  Widget getSectionTitle(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---------------- Image gallery ----------------

  Widget getImageGallery(SizeConfig sc, ThemeData theme) {
    final images = p.images.isNotEmpty ? p.images : [p.thumbnail];

    return Container(
      height: sc.height * 0.42,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => _imageIndex.value = i,
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: images[i],
              fit: BoxFit.contain,
              placeholder: (_, __) =>
              const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) =>
              const Icon(Icons.image_not_supported, size: 48),
            ),
          ),
          getGalleryButtons(sc),
          if (images.length > 1) getGalleryDots(theme, images.length),
        ],
      ),
    );
  }

  Widget getGalleryButtons(SizeConfig sc) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sc.hPadding * 0.5,
          vertical: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            Consumer<FavoritesProvider>(
              builder: (context, favs, _) {
                final isFav = favs.isFavorite(p.id);
                return IconButton.filledTonal(
                  onPressed: () => favs.toggle(p),
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getGalleryDots(ThemeData theme, int count) {
    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: ValueListenableBuilder<int>(
        valueListenable: _imageIndex,
        builder: (_, index, __) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            count,
                (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 8,
              width: i == index ? 22 : 8,
              decoration: BoxDecoration(
                color: i == index
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Title / brand / category ----------------

  Widget getTitleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Chip(
              label: Text(p.category.toUpperCase()),
              visualDensity: VisualDensity.compact,
            ),
            if (p.brand.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  p.brand,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        Text(
          p.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ---------------- Price + discount + rating ----------------

  Widget getPriceSection(ThemeData theme) {
    final hasDiscount = p.discountPercentage > 0;

    return Row(
      children: [
        Text(
          '\$${p.discountedPrice.toStringAsFixed(2)}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        if (hasDiscount) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '\$${p.price.toStringAsFixed(2)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${p.discountPercentage.toStringAsFixed(0)}% OFF',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        const Spacer(),
        const Icon(Icons.star, color: Colors.amber),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            p.rating.toStringAsFixed(1),
            style: theme.textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  // ---------------- Stock ----------------

  Widget getStockSection(ThemeData theme) {
    final stock = p.stock;
    final Color color =
    stock == 0 ? Colors.red : (stock <= 10 ? Colors.orange : Colors.green);
    final label = p.availabilityStatus.isNotEmpty
        ? p.availabilityStatus
        : (stock > 0 ? 'In Stock' : 'Out of Stock');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  stock > 0 ? Icons.check_circle : Icons.cancel,
                  color: color,
                  size: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text('$stock units left', style: theme.textTheme.bodySmall),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (stock / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  color: color,
                  backgroundColor: color.withOpacity(0.15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Tags ----------------

  Widget getTagsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: p.tags
          .map(
            (t) => Chip(
          avatar: const Icon(Icons.sell_outlined, size: 16),
          label: Text(t),
          visualDensity: VisualDensity.compact,
        ),
      )
          .toList(),
    );
  }

  // ---------------- Description ----------------

  Widget getDescription(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getSectionTitle(theme, AppStrings.description),
        Text(p.description, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  // ---------------- Warranty / Shipping / Return / Min order ----------------

  Widget getInfoTiles(SizeConfig sc, ThemeData theme) {
    final gap = sc.gap * 0.6;

    final items = <(IconData, String, String)>[
      if (p.warrantyInformation.isNotEmpty)
        (Icons.verified_user_outlined, AppStrings.warranty, p.warrantyInformation),
      if (p.shippingInformation.isNotEmpty)
        (Icons.local_shipping_outlined,AppStrings.shipping, p.shippingInformation),
      if (p.returnPolicy.isNotEmpty)
        (Icons.assignment_return_outlined, AppStrings.returns, p.returnPolicy),
      (
      Icons.shopping_basket_outlined,
      AppStrings.minOrder,
      '${p.minimumOrderQuantity} unit(s)',
      ),
    ];

    // 2-2 ki rows banao (width calculate karne ki zaroorat nahi, Expanded se barabar)
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final hasSecond = i + 1 < items.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : gap),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: getInfoTile(theme, items[i])),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: gap),
                    child: hasSecond
                        ? getInfoTile(theme, items[i + 1])
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget getInfoTile(ThemeData theme, (IconData, String, String) item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.$1, color: theme.colorScheme.primary),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              item.$2,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            item.$3,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Specs (SKU, weight, dimensions) ----------------

  List<MapEntry<String, String>> getSpecRows() {
    final d = p.dimensions;
    return [
      if (p.sku.isNotEmpty) MapEntry('SKU', p.sku),
      if (p.weight > 0) MapEntry('Weight', '${p.weight}'),
      if (d != null)
        MapEntry('Dimensions', '${d.width} x ${d.height} x ${d.depth}'),
    ];
  }

  Widget getSpecsCard(ThemeData theme, List<MapEntry<String, String>> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getSectionTitle(theme, 'Specifications'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: rows
                  .map(
                    (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          r.key,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          r.value,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Rating summary (star-wise bars) ----------------

  Widget getRatingSummary(ThemeData theme) {
    final reviews = p.reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getSectionTitle(theme, 'Reviews (${reviews.length})'),
        Row(
          children: [
            Column(
              children: [
                Text(
                  p.rating.toStringAsFixed(1),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                        (i) => Icon(
                      i < p.rating.round() ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            // Expanded(
            //   child: Padding(
            //     padding: const EdgeInsets.only(left: 16),
            //     child: Column(
            //       children:
            //       [5, 4, 3, 2, 1].map((star) => getStarBar(theme, star)).toList(),
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget getStarBar(ThemeData theme, int star) {
    final reviews = p.reviews;
    final count = reviews.where((r) => r.rating == star).length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$star', style: theme.textTheme.labelSmall),
          const Icon(Icons.star, size: 12, color: Colors.amber),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: reviews.isEmpty ? 0 : count / reviews.length,
                  minHeight: 6,
                ),
              ),
            ),
          ),
          Text('$count', style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }

  // ---------------- Single review ----------------

  Widget getReviewCard(ThemeData theme, Review review) {
    final initial = review.reviewerName.isNotEmpty
        ? review.reviewerName[0].toUpperCase()
        : '?';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 16, child: Text(initial)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.reviewerName,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          review.date.split('T').first,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...List.generate(
                  5,
                      (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(review.comment),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Bottom Add to Cart bar ----------------

  Widget getBottomBar(SizeConfig sc, ThemeData theme) {
    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sc.hPadding,
            vertical: sc.gap * 0.6,
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total', style: theme.textTheme.labelMedium),
                  Text(
                    '\$${p.discountedPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: sc.gap),
                  child: FilledButton.icon(
                    onPressed: p.stock > 0 ? () {} : null,
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: Text(p.stock > 0 ? AppStrings.addToCart : AppStrings.outOfStock),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}