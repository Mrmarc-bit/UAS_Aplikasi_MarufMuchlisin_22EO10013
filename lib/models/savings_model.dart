import 'dart:convert';

class SavingsRecord {
  final String id;
  final double amount;
  final String note;
  final DateTime date;

  SavingsRecord({
    required this.id,
    required this.amount,
    required this.note,
    required this.date,
  });

  // Create a copy with updated values
  SavingsRecord copyWith({
    String? id,
    double? amount,
    String? note,
    DateTime? date,
  }) {
    return SavingsRecord(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  // Convert to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  // Create from Map for deserialization
  factory SavingsRecord.fromMap(Map<String, dynamic> map) {
    return SavingsRecord(
      id: map['id'],
      amount: map['amount'],
      note: map['note'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SavingsRecord.fromJson(String source) => 
      SavingsRecord.fromMap(json.decode(source));
      
  @override
  String toString() {
    return 'SavingsRecord(id: $id, amount: $amount, note: $note, date: $date)';
  }
}
