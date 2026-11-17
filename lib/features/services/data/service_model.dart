class CategoryModel {
  final int id;
  final String name;
  final String slug;

  const CategoryModel({required this.id, required this.name, required this.slug});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] as int,
    name: json['name'] as String,
    slug: (json['slug'] as String?) ?? '',
  );
}

class ServiceModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String? imageUrl;
  final bool isFeatured;
  final CategoryModel? category;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.imageUrl,
    this.isFeatured = false,
    this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
    id: json['id'] as int,
    name: json['name'] as String,
    description: (json['description'] as String?) ?? '',
    // Laravel returns decimals as strings like "25.00"
    price: double.parse(json['price'].toString()),
    durationMinutes: json['duration_minutes'] as int,
    imageUrl: json['image_url'] as String?,
    isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
    category: json['category'] is Map
        ? CategoryModel.fromJson(Map<String, dynamic>.from(json['category'] as Map))
        : null,
  );

  String get priceLabel => '\$${price.toStringAsFixed(2)}';

  String get durationLabel {
    if (durationMinutes < 60) return '$durationMinutes min';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}