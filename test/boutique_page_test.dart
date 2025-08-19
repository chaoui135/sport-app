import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fitvista/pages/boutique_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: ".env"); // OU ".env" si tu n’as pas de fichier test
  });

  testWidgets('BoutiquePage contient un champ de recherche', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: BoutiquePage()));
    expect(find.byType(TextField), findsOneWidget);
  });
}
