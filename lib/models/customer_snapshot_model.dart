import 'customer_model.dart';

class CustomerSnapshot {
  const CustomerSnapshot({
    required this.name,
    required this.phone,
    required this.gigabytes,
    required this.price,
    required this.isPaid,
    required this.paidDate,
    required this.notes,
  });

  final String name;
  final String phone;
  final double gigabytes;
  final double price;
  final bool isPaid;
  final DateTime? paidDate;
  final String notes;

  factory CustomerSnapshot.fromCustomer(Customer customer) {
    return CustomerSnapshot(
      name: customer.name,
      phone: customer.phone,
      gigabytes: customer.gigabytes,
      price: customer.price,
      isPaid: customer.isPaid,
      paidDate: customer.lastPaidDate,
      notes: customer.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'gigabytes': gigabytes,
      'price': price,
      'isPaid': isPaid,
      'paidDate': paidDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory CustomerSnapshot.fromMap(Map<String, dynamic> map) {
    final rawPaidDate = map['paidDate'];
    return CustomerSnapshot(
      name: map['name'] as String,
      phone: map['phone'] as String,
      gigabytes: (map['gigabytes'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
      isPaid: map['isPaid'] as bool,
      paidDate: rawPaidDate == null ? null : DateTime.parse(rawPaidDate as String),
      notes: (map['notes'] as String?) ?? '',
    );
  }
}
