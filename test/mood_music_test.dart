import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fitvista/pages/mood_music_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });

  testWidgets('MoodMusicPage affiche la question principale', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MoodMusicPage(),
      ),
    );

    expect(find.text("Comment te sens-tu aujourd'hui ?"), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(5));
  });
}
