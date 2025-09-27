class CartItem {
  final String id;
  final String name;
  final String? image;
  final int basePrice;
  final String size;
  final int quantity;
  final String restaurant;
  final String category;
  final String? description;

  CartItem({
    required this.id,
    required this.name,
    this.image,
    required this.basePrice,
    required this.size,
    required this.quantity,
    required this.restaurant,
    required this.category,
    this.description,
  });

  // Price is same for all sizes
  int get price => basePrice;

  int get totalPrice => price * quantity;

  CartItem copyWith({
    String? id,
    String? name,
    String? image,
    int? basePrice,
    String? size,
    int? quantity,
    String? restaurant,
    String? category,
    String? description,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      basePrice: basePrice ?? this.basePrice,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      restaurant: restaurant ?? this.restaurant,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'basePrice': basePrice,
      'size': size,
      'quantity': quantity,
      'restaurant': restaurant,
      'category': category,
      'description': description,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      basePrice: json['basePrice'],
      size: json['size'],
      quantity: json['quantity'],
      restaurant: json['restaurant'],
      category: json['category'],
      description: json['description'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.id == id &&
        other.size == size;
  }

  @override
  int get hashCode => id.hashCode ^ size.hashCode;
}
