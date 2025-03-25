import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new user document
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error creating user in Firestore: $e');
      rethrow;
    }
  }

  // Create a new user document with the default 'user' role (overload for backward compatibility)
  Future<void> createNewUser(String uid, String email,
      {String role = 'user', String? name, String? photoUrl}) async {
    try {
      final UserModel user = UserModel(
        uid: uid,
        email: email,
        role: role,
        name: name,
        photoUrl: photoUrl,
      );
      await createUser(user);
    } catch (e) {
      print('Error creating new user: $e');
      rethrow;
    }
  }

  // Get user data including role
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user role (admin use only)
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
      });
    } catch (e) {
      print('Error updating user role: $e');
      rethrow;
    }
  }

  // Get all users (admin use only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }
}
