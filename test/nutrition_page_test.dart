import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitvista/pages/nutrition_page.dart';

void main() {
  testWidgets('NutritionPage UI loads and displays basic elements', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: NutritionPage(),
      ),
    );

    // Laisser le widget s'initialiser
    await tester.pumpAndSettle();

    // Vérifie les sections de la page
    expect(find.text('Calcul IMC & Besoins'), findsOneWidget);
    expect(find.text('Vos Mesures'), findsOneWidget);
    expect(find.text('Vos Objectifs'), findsOneWidget);
    expect(find.text('CALCULER'), findsOneWidget);
    expect(find.text('Recettes Santé'), findsOneWidget);

    // Vérifie la présence des champs de texte
    expect(find.widgetWithText(TextField, 'Poids (kg)'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Taille (cm)'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Âge (ans)'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Niveau d’activité (1.2–1.9)'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Poids cible (kg)'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Activité cible (jours/semaine)'), findsOneWidget);

    // Vérifie les boutons dans l'AppBar
    expect(find.byIcon(Icons.list_alt), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);

    // Vérifie le champ de recherche de recettes
    expect(find.byType(TextField).last, findsOneWidget);
  });
}
