class Product {
  final int id;
  final String title;
  final String category;
  final double price;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'ID': id, 'Title': title, 'Category': category, 'Price': price};
  }
}
