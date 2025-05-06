enum TransactionType { spending, income }

class Transaction {
  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? description;
  final String? vendorOrSource;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
    this.vendorOrSource,
  });

  // Helper to convert to map for storage (e.g., Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name, // Store enum as string
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'vendorOrSource': vendorOrSource,
    };
  }

  // Helper to create from map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      amount: map['amount'] as double,
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
      vendorOrSource: map['vendorOrSource'] as String?,
    );
  }
} 