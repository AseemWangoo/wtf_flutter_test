import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guru_app/app.dart';
import 'package:shared/shared.dart';
import 'package:shared/testing/fake_auth_service.dart';

void main() {
  testWidgets('Guru app shows onboarding when not complete', (WidgetTester tester) async {
    final fakeAuth = FakeAuthService(onboardingComplete: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          guruAuthServiceProvider.overrideWithValue(fakeAuth),
        ],
        child: const GuruApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Welcome'), findsOneWidget);
  });
}
