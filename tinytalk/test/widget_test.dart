import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tinytalk/app/app.dart';

void main() {
  testWidgets('BabyHabla shows welcome, then language, then categories',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: TinyTalkApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Comenzar'), findsOneWidget);

    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    expect(find.text('Elige tu idioma'), findsOneWidget);
    expect(find.text('Espa\u00f1ol'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('What do you want to learn?'), findsOneWidget);
    expect(find.text('Animals'), findsOneWidget);
  });
}
