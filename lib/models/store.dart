
class Store {
  final String name;
  final String imageUrl;
  final int id;

  Store({required this.name, required this.imageUrl, required this.id});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      name: json['name'],
      imageUrl: json['image_url'],
      id: json['id'],
    );
  }
}
