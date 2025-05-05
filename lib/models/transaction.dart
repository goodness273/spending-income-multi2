import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum TransactionType { expense, income }

class Transaction {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionType type;
  final String category;
  final String userId;

  Transaction({
    String? id,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
    required this.category,
    required this.userId,
  }) : id = id ?? const Uuid().v4();

  // Convert a Transaction into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'type': type.toString().split('.').last,
      'category': category,
      'userId': userId,
    };
  }

  // Create a Transaction from a Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      date: (map['date'] as Timestamp).toDate(),
      type:
          map['type'] == 'income'
              ? TransactionType.income
              : TransactionType.expense,
      category: map['category'],
      userId: map['userId'],
    );
  }

  // Create a Transaction from a DocumentSnapshot
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaction.fromMap(data);
  }

  // Create a copy with some fields changed
  Transaction copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? date,
    TransactionType? type,
    String? category,
    String? userId,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      userId: userId ?? this.userId,
    );
  }
}
