import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trainer_app/app.dart';

void main() {
  testWidgets('Trainer app shows setup home', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TrainerApp()));
    expect(find.text('Setup complete'), findsOneWidget);
    expect(find.textContaining('Aarav'), findsOneWidget);
  });
}
