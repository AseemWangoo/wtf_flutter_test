import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  test('assignedMembersProvider returns DK for Aarav', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final members = container.read(
      assignedMembersProvider(AppConstants.aaravUserId),
    );
    expect(members, hasLength(1));
    expect(members.first.id, AppConstants.dkUserId);
  });

  test('assignedMembersProvider returns empty for unknown trainer', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(assignedMembersProvider('unknown')),
      isEmpty,
    );
  });
}
