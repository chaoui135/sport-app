// lib/models/cart.dart
import 'cart_item.dart';

class Cart {
  List<CartItem> items = [];

  void addItem(CartItem item) {
    final existingItemIndex = items.indexWhere((cartItem) => cartItem.id == item.id);
    if (existingItemIndex >= 0) {
      items[existingItemIndex].quantity += 1; // Augmente la quantité
    } else {
      items.add(item);
    }
  }

  void removeItem(CartItem item) {
    items.remove(item);
  }

  double get totalPrice {
    return items.fold(0, (total, current) => total + (current.price * current.quantity));
  }
}
