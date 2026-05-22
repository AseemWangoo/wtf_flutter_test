import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';
import 'package:shared/testing/fake_auth_service.dart';
import 'package:trainer_app/app.dart';

void main() {
  testWidgets('Trainer app shows login when logged out', (WidgetTester tester) async {
    final fakeAuth = FakeAuthService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trainerAuthServiceProvider.overrideWithValue(fakeAuth),
        ],
        child: const TrainerApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Continue as Aarav'), findsOneWidget);
  });
}
