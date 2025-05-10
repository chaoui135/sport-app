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
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Panier'),
        backgroundColor: Color(0xFF1C1C1E), // Couleur de fond de la barre d'applications
      ),
      body: Container(
        color: Color(0xFF121212), // Couleur de fond noir-gris
        child: widget.cart.items.isEmpty
            ? Center(child: Text('Votre panier est vide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)))
            : ListView.builder(
          itemCount: widget.cart.items.length,
          itemBuilder: (context, index) {
            final item = widget.cart.items[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              elevation: 4,
              color: Colors.grey[850], // Couleur de la carte
              child: ListTile(
                leading: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text('Prix: ${item.price.toStringAsFixed(2)}€ x ${item.quantity}', style: TextStyle(color: Colors.white70)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.red),
                      onPressed: () {
                        _updateQuantity(item, -1);
                      },
                    ),
                    Text(item.quantity.toString(), style: TextStyle(color: Colors.white)),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        _updateQuantity(item, 1);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeItem(item);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF1C1C1E), // Couleur de fond de la barre inférieure
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: ${widget.cart.totalPrice.toStringAsFixed(2)}€', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ElevatedButton(
                onPressed: () {
                  _processPayment(context);
                },
                child: Text('Payer'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
        item.quantity += change; // Met à jour la quantité
      } else {
        _removeItem(item); // Retire l'article si la quantité devient 0
      }
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      widget.cart.removeItem(item); // Appel à la méthode removeItem
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} retiré du panier')),
    );
  }

  void _processPayment(BuildContext context) {
    // Implémentez la logique de paiement ici
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Paiement traité avec succès!')),
    );
  }
}
