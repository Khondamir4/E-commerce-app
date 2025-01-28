class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    this.imagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      quantity: json['quantity'],
      imagePath: json['image_path'],
    );
  }
}
