import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class UserProfile {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  /// Converts a UserProfile object into a Map<String, dynamic> for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'createdAt':
          FieldValue.serverTimestamp(), // Let Firestore handle the timestamp
    };
  }

  /// Creates a UserProfile object from a Firestore document snapshot.
  factory UserProfile.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      // Handle potential null timestamp during creation before server populates it
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
