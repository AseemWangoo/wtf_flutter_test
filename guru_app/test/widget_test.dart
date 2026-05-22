import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guru_app/app.dart';

void main() {
  testWidgets('Guru app shows setup home', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GuruApp()));
    expect(find.text('Setup complete'), findsOneWidget);
    expect(find.textContaining('DK'), findsOneWidget);
  });
}
