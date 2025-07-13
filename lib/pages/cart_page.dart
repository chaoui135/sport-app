import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';

class CartPage extends StatefulWidget {
  final Cart cart;
  CartPage({required this.cart});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.cart.items.isEmpty;
    final total = widget.cart.totalPrice;
    final mq = MediaQuery.of(context);
    final iconSize = mq.size.width < 350 ? 22.0 : 28.0;
    final fontSize = mq.size.width < 350 ? 14.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mon Panier', style: TextStyle(color: Colors.teal[900], fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.teal[900]),
        elevation: 1,
        centerTitle: true,
      ),
      body: isEmpty
          ? Center(
        child: Text('Votre panier est vide',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[500])),
      )
          : SafeArea(
        bottom: false,
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: mq.padding.bottom + 130, top: 12),
          itemCount: widget.cart.items.length,
          itemBuilder: (context, index) {
            final item = widget.cart.items[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 7, horizontal: 18),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              color: Colors.white,
              child: ListTile(
                leading: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item.imageUrl != null && item.imageUrl.isNotEmpty
                          ? Image.network(
                        item.imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.image, color: Colors.grey, size: iconSize),
                      )
                          : Icon(Icons.shopping_bag, size: iconSize, color: Colors.teal[200]),
                    ),
                    if (item.quantity > 1)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.teal[700],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(item.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize)),
                subtitle: Text(
                  'Prix: ${item.price.toStringAsFixed(2)} € x ${item.quantity}',
                  style: TextStyle(color: Colors.teal[800], fontSize: fontSize-1),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: Colors.teal, size: iconSize),
                      onPressed: () => _updateQuantity(item, -1),
                      splashRadius: 20,
                    ),
                    Text(item.quantity.toString(),
                        style: TextStyle(fontSize: fontSize-1, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.teal, size: iconSize),
                      onPressed: () => _updateQuantity(item, 1),
                      splashRadius: 20,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: iconSize),
                      onPressed: () => _removeItem(item),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: isEmpty
          ? null
          : SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(18, 10, 18, 18 + mq.padding.bottom),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Total: ${total.toStringAsFixed(2)} €',
                  style: TextStyle(fontSize: fontSize+2, fontWeight: FontWeight.bold, color: Colors.teal[900]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _processPayment(context),
                icon: Icon(Icons.credit_card, size: fontSize+2),
                label: Text('Payer', style: TextStyle(fontSize: fontSize)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  foregroundColor: Colors.white,
                  elevation: 7,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 13, horizontal: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateQuantity(CartItem item, int change) {
    setState(() {
      if (item.quantity + change > 0) {
        item.quantity += change;
      } else {
        _removeItem(item);
      }
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      widget.cart.removeItem(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} retiré du panier'),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _processPayment(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paiement traité avec succès !'),
        backgroundColor: Colors.teal[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {
      widget.cart.items.clear();
    });
  }
}
