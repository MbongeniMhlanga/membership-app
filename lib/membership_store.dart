import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Owns membership data, the signed-in session, and local persistence.
class MembershipStore extends ChangeNotifier {
  static const _usersKey = 'users';
  static const _seededKey = 'seeded';
  final List<Membership> memberships = [];
  List<MemberUser> users = [];
  MemberUser? currentUser;
  late SharedPreferences _prefs;

  /// Resolves the signed-in user's current membership.
  Membership? get currentMembership =>
      currentUser == null ? null : membershipFor(currentUser!.membershipId);

  /// Finds a membership tier by its stable identifier.
  Membership? membershipFor(String id) {
    for (final membership in memberships) {
      if (membership.id == id) {
        return membership;
      }
    }
    return null;
  }

  /// Loads membership definitions and seeds profiles exactly once.
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final membershipData =
        jsonDecode(await rootBundle.loadString('docs/memberships.json'))
            as List;
    memberships.addAll(membershipData
        .map((item) => Membership.fromJson(item as Map<String, dynamic>)));
    if (!(_prefs.getBool(_seededKey) ?? false)) {
      final userData =
          jsonDecode(await rootBundle.loadString('docs/users.json')) as List;
      users = userData
          .map((item) => MemberUser.fromJson(item as Map<String, dynamic>))
          .toList();
      await _saveUsers();
      await _prefs.setBool(_seededKey, true);
    } else {
      users = (_prefs.getStringList(_usersKey) ?? [])
          .map((item) =>
              MemberUser.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    }
  }

  /// Signs in the profile matching an email address, or returns an error.
  Future<String?> signIn(String email) async {
    final normalized = email.trim().toLowerCase();
    MemberUser? found;
    for (final user in users) {
      if (user.email.toLowerCase() == normalized) {
        found = user;
        break;
      }
    }
    if (found == null) return 'No profile found for that email address.';
    currentUser = found;
    notifyListeners();
    return null;
  }

  /// Creates and persists a new profile, preventing duplicate emails.
  Future<String?> signUp(String name, String email, String membershipId) async {
    final normalized = email.trim().toLowerCase();
    if (users.any((user) => user.email.toLowerCase() == normalized)) {
      return 'That email address is already registered.';
    }
    final user = MemberUser(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        email: normalized,
        membershipId: membershipId);
    users = [...users, user];
    await _saveUsers();
    currentUser = user;
    notifyListeners();
    return null;
  }

  /// Applies and persists an upgrade for the signed-in profile.
  Future<void> upgrade(String membershipId) async {
    if (currentUser == null) return;
    final updated = currentUser!.copyWith(membershipId: membershipId);
    users =
        users.map((user) => user.id == updated.id ? updated : user).toList();
    currentUser = updated;
    await _saveUsers();
    notifyListeners();
  }

  /// Permanently removes the signed-in profile and ends the session.
  Future<void> deleteCurrentUser() async {
    if (currentUser == null) return;
    users = users.where((user) => user.id != currentUser!.id).toList();
    currentUser = null;
    await _saveUsers();
    notifyListeners();
  }

  /// Ends the current session without deleting the profile.
  void signOut() {
    currentUser = null;
    notifyListeners();
  }

  /// Writes every profile as a JSON string in SharedPreferences.
  Future<void> _saveUsers() => _prefs.setStringList(
      _usersKey, users.map((user) => jsonEncode(user.toJson())).toList());
}
