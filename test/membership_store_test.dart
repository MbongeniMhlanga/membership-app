import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:membership_app/membership_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MembershipStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = MembershipStore();
    await store.load();
  });

  test('seeds all supplied profiles and membership tiers once', () {
    expect(store.users, hasLength(5));
    expect(store.memberships.map((membership) => membership.id),
        containsAll(['starter', 'plus', 'premium']));
  });

  test('validates sign-up fields and duplicate emails', () async {
    expect(await store.signUp('', 'new@example.com', 'starter'), isNotNull);
    expect(await store.signUp('New User', '', 'starter'), isNotNull);
    expect(
        await store.signUp('New User', 'invalid-email', 'starter'), isNotNull);
    expect(
        await store.signUp('New User', 'new@example.com', 'starter'), isNull);
    expect(await store.signUp('Another User', 'NEW@example.com', 'plus'),
        isNotNull);
  });

  test('upgrades and deletes only the signed-in profile', () async {
    expect(await store.signIn('naledi.mokoena@example.com'), isNull);
    await store.upgrade('premium');
    expect(store.currentMembership?.id, 'premium');
    await store.deleteCurrentUser();
    expect(await store.signIn('naledi.mokoena@example.com'), isNotNull);
    expect(await store.signIn('thabo.dlamini@example.com'), isNull);
  });
}
