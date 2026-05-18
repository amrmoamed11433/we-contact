const Object _noDateChange = Object();

class Customer {
  const Customer({
    required this.id,
    required this.groupId,
    required this.name,
    required this.phone,
    required this.gigabytes,
    required this.price,
    required this.isPaid,
    required this.lastPaidDate,
    required this.notes,
    required this.isActive,
  });

  final String id;
  final String groupId;
  final String name;
  final String phone;
  final double gigabytes;
  final double price;
  final bool isPaid;
  final DateTime? lastPaidDate;
  final String notes;
  final bool isActive;

  Customer copyWith({
    String? id,
    String? groupId,
    String? name,
    String? phone,
    double? gigabytes,
    double? price,
    bool? isPaid,
    Object? lastPaidDate = _noDateChange,
    String? notes,
    bool? isActive,
  }) {
    return Customer(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gigabytes: gigabytes ?? this.gigabytes,
      price: price ?? this.price,
      isPaid: isPaid ?? this.isPaid,
      lastPaidDate: identical(lastPaidDate, _noDateChange)
          ? this.lastPaidDate
          : lastPaidDate as DateTime?,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'name': name,
      'phone': phone,
      'gigabytes': gigabytes,
      'price': price,
      'isPaid': isPaid,
      'lastPaidDate': lastPaidDate?.toIso8601String(),
      'notes': notes,
      'isActive': isActive,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    final rawPaidDate = map['lastPaidDate'];
    return Customer(
      id: map['id'] as String,
      groupId: map['groupId'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      gigabytes: (map['gigabytes'] as num).toDouble(),
      price: (map['price'] as num).toDouble(),
      isPaid: map['isPaid'] as bool,
      lastPaidDate: rawPaidDate == null ? null : DateTime.parse(rawPaidDate as String),
      notes: (map['notes'] as String?) ?? '',
      isActive: (map['isActive'] as bool?) ?? true,
    );
  }
}
