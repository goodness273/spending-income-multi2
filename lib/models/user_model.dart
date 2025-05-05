import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final List<String> categories;
  final DateTime createdAt;
  final Map<String, dynamic>? settings;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    List<String>? categories,
    DateTime? createdAt,
    this.settings,
  }) : this.categories =
           categories ??
           [
             'Food',
             'Transport',
             'Entertainment',
             'Bills',
             'Shopping',
             'Health',
             'Education',
             'Salary',
             'Gift',
             'Other',
           ],
       this.createdAt = createdAt ?? DateTime.now();

  // Convert a UserModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'categories': categories,
      'createdAt': Timestamp.fromDate(createdAt),
      'settings': settings ?? {},
    };
  }

  // Create a UserModel from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      categories: List<String>.from(map['categories'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      settings: map['settings'],
    );
  }

  // Create a UserModel from a DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  // Create a copy with some fields changed
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    List<String>? categories,
    DateTime? createdAt,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
    );
  }
}
