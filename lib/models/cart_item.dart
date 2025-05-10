// lib/models/cart_item.dart
class CartItem {
  final String id;
  final String name;
  final String description;
  double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}
