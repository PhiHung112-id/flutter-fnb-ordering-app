class ProductModel {
  final int id;
  final String title;
  final String category;
  final String type; // food hoáº·c drink
  final double price;
  final String description;
  final String thumbnail;
  final List<String> images;
  final double rating;
  final bool isPopular;

  ProductModel({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.price,
    required this.description,
    required this.thumbnail,
    required this.images,
    required this.rating,
    required this.isPopular,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      type: map['type'] ?? 'food',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      rating: (map['rating'] ?? 4.5).toDouble(),
      isPopular: map['isPopular'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'type': type,
      'price': price,
      'description': description,
      'thumbnail': thumbnail,
      'images': images,
      'rating': rating,
      'isPopular': isPopular,
    };
  }
}


