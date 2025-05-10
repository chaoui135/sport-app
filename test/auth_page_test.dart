import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitvista/pages/auth_page.dart';

void main() {
  testWidgets('AuthPage smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AuthPage()));

    // Vérifiez que le titre de l'AppBar est "Connexion"
    expect(find.text('Connexion'), findsOneWidget);

    // Vérifiez que les champs de formulaire sont présents
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Vérifiez que le bouton de connexion est présent
    expect(find.text('Se connecter'), findsOneWidget);

    // Vérifiez que le bouton de basculement vers l'inscription est présent
    expect(find.text('Créer un compte'), findsOneWidget);
  });

  testWidgets('AuthPage inscription test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AuthPage()));

    // Basculez vers l'écran d'inscription
    await tester.tap(find.text('Créer un compte'));
    await tester.pump();

    // Vérifiez que le titre de l'AppBar est "Inscription"
    expect(find.text('Inscription'), findsOneWidget);

    // Vérifiez que les champs de formulaire sont présents
    expect(find.byType(TextFormField), findsNWidgets(3));

    // Vérifiez que le bouton d'inscription est présent
    expect(find.text("S'inscrire"), findsOneWidget);

    // Vérifiez que le bouton de basculement vers la connexion est présent
    expect(find.text('J\'ai déjà un compte'), findsOneWidget);
  });
}
