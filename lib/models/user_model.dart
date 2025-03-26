class UserModel {
  final String uid;
  final String email;
  final String role;
  final String? name;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user', // Default role is user
      name: map['name'],
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}
