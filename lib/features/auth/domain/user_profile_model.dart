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
  /// Note: We exclude 'id' since it's stored as the document ID, not a field.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'createdAt':
          FieldValue.serverTimestamp(), // Let Firestore handle the timestamp
    };
  }

  /// Alternative toJson method that preserves the DateTime for immediate use
  /// Use this when you need the actual DateTime value right after creation
  Map<String, dynamic> toJsonWithDateTime() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a UserProfile object from a Firestore document snapshot.
  factory UserProfile.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    // Handle case where document exists but has no data
    if (data == null) {
      throw Exception('Document exists but contains no data');
    }

    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      // Handle potential null timestamp during creation before server populates it
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Creates a UserProfile object from a regular DocumentSnapshot (without generics)
  /// Useful for compatibility with different snapshot types
  factory UserProfile.fromSnapshotGeneric(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Document exists but contains no data');
    }

    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Creates a copy of this UserProfile with updated fields
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ email.hashCode ^ createdAt.hashCode;
  }
}
