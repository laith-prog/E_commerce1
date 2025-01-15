class Product {
  final String name;
  final String imageUrl;
  final int id;

  Product({required this.name, required this.imageUrl, required this.id});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      imageUrl: json['image_url'],
      id: json['id'],
    );
  }
}
