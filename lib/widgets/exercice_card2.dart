// lib/widgets/exercice_card2.dart
import 'package:flutter/material.dart';

class ExerciceCard2 extends StatelessWidget {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final VoidCallback onAddToCart;

  const ExerciceCard2({
    Key? key,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image en haut, ratio 1.2
              AspectRatio(
                aspectRatio: 1.2,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image,
                    size: 48,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),

              // Informations produit
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${price.toStringAsFixed(2)} €',
                      style: textTheme.bodyLarge
                          ?.copyWith(color: cs.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bouton + cercle en coin
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: cs.primaryContainer,
              shape: const CircleBorder(),
              elevation: 2,
              child: IconButton(
                icon: Icon(Icons.add, color: cs.onPrimaryContainer),
                onPressed: onAddToCart,
                tooltip: 'Ajouter au panier',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
