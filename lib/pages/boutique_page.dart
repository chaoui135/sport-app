// lib/pages/boutique_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../pages/cart_page.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final res = await http.get(Uri.parse('https://fitness-api.onrender.com/api/products'));

    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List;
      setState(() {
        _products = list;
        _filtered = list;
      });
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${p['name']} ajouté !')),
    );
  }

  void _goCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartPage(cart: _cart)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 56 + 48,     // titre (56) + recherche (48)
            collapsedHeight: 56,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            toolbarHeight: 56,
            title: Text('Shop', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: _goCart,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    onChanged: (v) {
                      _search = v.toLowerCase();
                      _applyFilter();
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Rechercher…',
                      hintStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Chips de filtres
          SliverPersistentHeader(
            pinned: true,
            delegate: _FiltersHeader(_categories, _filter, _toggleCat),
          ),

          // Grille des produits
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                  final p = _filtered[i];
                  return _ProductCard(
                    product: p,
                    onAdd: () => _addToCart(p),
                  );
                },
                childCount: _filtered.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Header collant pour les chips
class _FiltersHeader extends SliverPersistentHeaderDelegate {
  final List<String> cats;
  final Set<String> sel;
  final void Function(String) onToggle;

  _FiltersHeader(this.cats, this.sel, this.onToggle);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (_, i) {
          final c = cats[i];
          return FilterChip(
            label: Text(c),
            selected: sel.contains(c),
            onSelected: (_) => onToggle(c),
            selectedColor: Theme.of(context).colorScheme.secondaryContainer,
            showCheckmark: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: cats.length,
      ),
    );
  }

  @override
  double get maxExtent => 56;
  @override
  double get minExtent => 56;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => true;
}

// Carte produit modernisée
class _ProductCard extends StatelessWidget {
  final dynamic product;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext ctx) {
    final cs        = Theme.of(ctx).colorScheme;
    final textTheme = Theme.of(ctx).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: cs.shadow,
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.2,
                child: Image.network(
                  product['imageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image,
                    size: 48,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(product['price'] as num).toStringAsFixed(2)} €',
                      style: textTheme.bodyLarge
                          ?.copyWith(color: cs.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: FloatingActionButton.small(
              heroTag: null,
              elevation: 2,
              backgroundColor: cs.primaryContainer,
              onPressed: onAdd,
              child: Icon(Icons.add, color: cs.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
