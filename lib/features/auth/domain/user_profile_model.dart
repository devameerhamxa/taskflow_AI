import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  final String uid;
  final String name;
  final String email;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
  });

  // A factory constructor to create a UserProfile from a Firestore document.
  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? 'No Name',
      email: data['email'] ?? 'No Email',
    );
  }
}
