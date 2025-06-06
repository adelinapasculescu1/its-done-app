class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final List<String> friends;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.friends = const [],
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      friends: List<String>.from(data['friends'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'friends': friends,
    };
  }
}