/// A feature included in a membership tier.
class Feature {
  const Feature({required this.id, required this.name});
  final String id;
  final String name;

  /// Creates a feature from the supplied JSON data.
  factory Feature.fromJson(Map<String, dynamic> json) =>
      Feature(id: json['id'] as String, name: json['name'] as String);
}

/// A membership tier and its included features.
class Membership {
  const Membership(
      {required this.id, required this.name, required this.features});
  final String id;
  final String name;
  final List<Feature> features;

  /// Creates a membership from the supplied JSON data.
  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
        id: json['id'] as String,
        name: json['name'] as String,
        features: (json['features'] as List)
            .map((item) => Feature.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

/// A locally stored member profile.
class MemberUser {
  const MemberUser(
      {required this.id,
      required this.name,
      required this.email,
      required this.membershipId});
  final String id;
  final String name;
  final String email;
  final String membershipId;

  /// Returns a copy with an optionally changed membership tier.
  MemberUser copyWith({String? membershipId}) => MemberUser(
        id: id,
        name: name,
        email: email,
        membershipId: membershipId ?? this.membershipId,
      );

  /// Serializes the profile for local persistence.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'membershipId': membershipId,
      };

  /// Creates a profile from persisted JSON data.
  factory MemberUser.fromJson(Map<String, dynamic> json) => MemberUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        membershipId: json['membershipId'] as String,
      );
}
