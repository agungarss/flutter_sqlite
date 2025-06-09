class Item {
  int? id; // id bisa null jika objek belum disimpan di database
  String name;
  String description;
  double price;
  String imageUrl;
  int stock;
  String category;

  Item({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.category,
  });

  // Konversi Item menjadi Map. Kunci harus sesuai dengan nama kolom di database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'category': category,
    };
  }

  // Konversi Map menjadi Item.
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      stock: (map['stock'] ?? 0).toInt(),
      category: map['category'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Item{id: $id, name: $name, description: $description, price: $price, imageUrl: $imageUrl, stock: $stock, category: $category}';
  }
}
