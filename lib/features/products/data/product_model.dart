import 'package:ecommerce_app_task/core/utils/constants.dart';

class Dimensions {
  final double width, height, depth;
  const Dimensions({this.width = 0, this.height = 0, this.depth = 0});

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
    width: (json[Constant.WIDTH] as num?)?.toDouble() ?? 0,
    height: (json[Constant.HEIGHT] as num?)?.toDouble() ?? 0,
    depth: (json[Constant.DEPTH] as num?)?.toDouble() ?? 0,
  );
}

class Review {
  final int rating;
  final String comment, date, reviewerName, reviewerEmail;

  const Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    rating: (json[Constant.RATING] as num?)?.toInt() ?? 0,
    comment: json[Constant.COMMENT] ?? '',
    date: json[Constant.DATE] ?? '',
    reviewerName: json[Constant.REVIEWER_NAME] ?? '',
    reviewerEmail: json[Constant.REVIEWER_EMAIL] ?? '',
  );
}

class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final String brand;
  final String category;
  final String thumbnail;
  final List<String> images;

  // Naye (optional)
  final int stock;
  final List<String> tags;
  final String sku;
  final double weight;
  final Dimensions? dimensions;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final List<Review> reviews;
  final String returnPolicy;
  final int minimumOrderQuantity;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
    this.stock = 0,
    this.tags = const [],
    this.sku = '',
    this.weight = 0,
    this.dimensions,
    this.warrantyInformation = '',
    this.shippingInformation = '',
    this.availabilityStatus = '',
    this.reviews = const [],
    this.returnPolicy = '',
    this.minimumOrderQuantity = 1,
  });

  double get discountedPrice => price * (1 - discountPercentage / 100);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json[Constant.ID] as int,
      title: json[Constant.TITLE] ?? '',
      description: json[Constant.DESCRIPTION] ?? '',
      price: (json[Constant.PRICE] as num).toDouble(),
      discountPercentage: (json[Constant.DISCOUNTPERCENTAGE] as num?)?.toDouble() ?? 0,
      rating: (json[Constant.RATING] as num?)?.toDouble() ?? 0,
      brand: json[Constant.BRAND] ?? '', // groceries mein nahi hota
      category: json[Constant.CATEGORY] ?? '',
      thumbnail: json[Constant.THUMBNAIL] ?? '',
      images: List<String>.from(json[Constant.IMAGES] ?? []),
      stock: (json[Constant.STOCK] as num?)?.toInt() ?? 0,
      tags: List<String>.from(json[Constant.TAGS] ?? []),
      sku: json[Constant.SKU] ?? '',
      weight: (json[Constant.WEIGHT] as num?)?.toDouble() ?? 0,
      dimensions: json[Constant.DIMENSIONS] != null
          ? Dimensions.fromJson(json[Constant.DIMENSIONS])
          : null,
      warrantyInformation: json[Constant.WARENTYINFORMATIONS] ?? '',
      shippingInformation: json[Constant.SHIPPINGINFORMATIONS] ?? '',
      availabilityStatus: json[Constant.AVAILABIITYSTATUS] ?? '',
      reviews: (json[Constant.REVIEWS] as List? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),
      returnPolicy: json[Constant.RETURNPOLICY] ?? '',
      minimumOrderQuantity:
      (json[Constant.MINIMUM_ORDER_QUANTITY] as num?)?.toInt() ?? 1,
    );
  }
}