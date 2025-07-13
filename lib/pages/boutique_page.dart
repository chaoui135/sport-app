import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../pages/cart_page.dart';
import '../services/api_config.dart';

class BoutiquePage extends StatefulWidget {
  @override
  _BoutiquePageState createState() => _BoutiquePageState();
}

class _BoutiquePageState extends State<BoutiquePage> {
  List<dynamic> _products = [];
  List<dynamic> _filtered = [];
  String _search = '';
  final List<String> _categories = ['MMA','Muscu','Boxe','Judo','Foot'];
  final Set<String> _filter = {};
  final Cart _cart = Cart();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _loading = true);
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/products'));
    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List;
      setState(() {
        _products = list;
        _filtered = list;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filtered = _products.where((p) {
        final name = (p['name'] as String).toLowerCase();
        final desc = (p['description'] as String).toLowerCase();
        final cat  = p['category'] as String;
        final matchSearch = name.contains(_search) || desc.contains(_search);
        final matchCat    = _filter.isEmpty || _filter.contains(cat);
        return matchSearch && matchCat;
      }).toList();
    });
  }

  void _toggleCat(String c) {
    setState(() {
      if (_filter.contains(c)) _filter.remove(c);
      else _filter.add(c);
      _applyFilter();
    });
  }

  void _addToCart(dynamic p) {
    final price = (p['price'] is int
        ? (p['price'] as int).toDouble()
        : p['price'] as double);
    final item = CartItem(
      id:          p['_id'],
      name:        p['name'],
      description: p['description'],
      price:       price,
      imageUrl:    p['imageUrl'],
    );
    _cart.addItem(item);
    setState(() {}); // Pour refresh le badge sur produit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p['name']} ajouté au panier !'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.teal[700],
      ),
    );
  }

  void _goCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartPage(cart: _cart)),
    );
    setState(() {}); // Pour refresh badge après retour
  }

  int _getQuantity(String id) {
    final found = _cart.items.where((e) => e.id == id);
    return found.isNotEmpty ? found.first.quantity : 0;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final columns = mq.size.width > 700 ? 4 : mq.size.width > 480 ? 3 : 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Shop', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 1)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.teal[900]),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: Colors.teal[900], size: 26),
                onPressed: _goCart,
                tooltip: "Voir le panier",
              ),
              if (_cart.items.isNotEmpty)
                Positioned(
                  right: 7, top: 9,
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.teal[700],
                      shape: BoxShape.circle,
                    ),
                    child: Text('${_cart.items.length}', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Recherche
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              child: TextField(
                onChanged: (v) {
                  _search = v.toLowerCase();
                  _applyFilter();
                },
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Rechercher…',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.search, color: Colors.teal),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 18),
                ),
              ),
            ),
            // Filtres
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: FilterChip(
                      label: Text(cat, style: TextStyle(fontWeight: FontWeight.w500)),
                      selected: _filter.contains(cat),
                      onSelected: (_) => _toggleCat(cat),
                      selectedColor: Colors.teal[100],
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.teal,
                      labelStyle: TextStyle(
                          color: _filter.contains(cat)
                              ? Colors.teal[900]
                              : Colors.black87
                      ),
                      shape: StadiumBorder(
                          side: BorderSide(color: Colors.teal.shade100)),
                    ),
                  )).toList(),
                ),
              ),
            ),
            // Grille responsive dans Expanded
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: Colors.teal))
                  : _filtered.isEmpty
                  ? Center(child: Text('Aucun produit trouvé', style: TextStyle(color: Colors.grey[500])))
                  : GridView.builder(
                padding: EdgeInsets.only(
                    left: 14, right: 14, top: 6, bottom: 95
                ), // bottom pour FAB !
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final p = _filtered[i];
                  final q = _getQuantity(p['_id']);
                  return _ProductCard(
                    product: p,
                    onAdd: () => _addToCart(p),
                    quantity: q,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _cart.items.isNotEmpty
          ? FloatingActionButton.extended(
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        icon: Icon(Icons.shopping_cart),
        label: Text('Panier (${_cart.items.length})'),
        onPressed: _goCart,
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ========================
// Carte produit
// ========================
class _ProductCard extends StatelessWidget {
  final dynamic product;
  final VoidCallback onAdd;
  final int quantity;

  const _ProductCard({required this.product, required this.onAdd, this.quantity = 0});

  @override
  Widget build(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    final textTheme = Theme.of(ctx).textTheme;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 5,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onAdd,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1.15,
                  child: product['imageUrl'] != null && product['imageUrl'].toString().isNotEmpty
                      ? Image.network(
                    product['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image,
                      size: 46,
                      color: cs.outline,
                    ),
                  )
                      : Icon(Icons.shopping_bag, size: 48, color: cs.outline),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom du produit UNIQUEMENT
                        Text(
                          product['name'],
                          style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Text(
                              '${(product['price'] as num).toStringAsFixed(2)} €',
                              style: textTheme.titleMedium?.copyWith(
                                  color: Colors.teal[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15
                              ),
                            ),
                            Spacer(),
                            // Bouton Info (description)
                            IconButton(
                              icon: Icon(Icons.info_outline, color: Colors.teal[400], size: 21),
                              splashRadius: 18,
                              onPressed: () {
                                showDialog(
                                  context: ctx,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(product['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                                    content: Text(
                                      product['description'] ?? "Pas de description.",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('Fermer'),
                                        onPressed: () => Navigator.pop(ctx),
                                      )
                                    ],
                                  ),
                                );
                              },
                              tooltip: 'Description',
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.teal[700], size: 26),
                              splashRadius: 21,
                              onPressed: onAdd,
                              tooltip: 'Ajouter au panier',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Badge quantité
            if (quantity > 0)
              Positioned(
                right: 18,
                top: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                  decoration: BoxDecoration(
                    color: Colors.teal[700],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: Text('$quantity',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
