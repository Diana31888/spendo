// Expense model - defines the structure of a single expense entry
// currency field stores which currency was used for this expense

class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String date;
  final String currency; // e.g. TRY, EUR, RON

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.currency = 'TRY',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
      'currency': currency,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
      currency: map['currency'] ?? 'TRY',
    );
  }
}